#!/usr/bin/env bash
# categorize.sh — build a browsable category overlay of symlinks under $DEV_ROOT/_by/
# from repo-categories.tsv. Repos stay physically flat; _by/ is a pure VIEW.
# Idempotent (rebuilds _by/ each run). bash 3.2 safe. Source of truth: tommyroar/.github/scripts/.
#
#   DEV_ROOT=~/dev ./categorize.sh          # Air
#   DEV_ROOT=/Volumes/dev ./categorize.sh   # mini
# Manifest: repo-categories.tsv next to this script (repo <TAB> topic <TAB> sensitive y/n),
# keyed by GitHub repo name — the script resolves each local dir to its repo via origin URL,
# so mismatched dir names (transit_tracker->transit-tracker-tui) still map correctly.
set -euo pipefail
DEV="${DEV_ROOT:-$HOME/dev}"
HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="${MANIFEST:-$HERE/repo-categories.tsv}"
[ -n "$DEV" ] && [ -d "$DEV" ] || { echo "dev root not found: $DEV" >&2; exit 1; }
[ -f "$MANIFEST" ] || { echo "manifest not found: $MANIFEST" >&2; exit 1; }
shopt -s dotglob nullglob   # so the .github repo dir is seen

slug_of() { printf '%s' "$1" | sed -E 's#\.git$##; s#/$##; s#.*/##'; }

BY="$DEV/_by"
rm -rf "$BY"
mkdir -p "$BY/topic" "$BY/sensitive"

linked=0; unlisted=""
for d in "$DEV"/*/; do
  name=$(basename "$d")
  case "$name" in _by|*.wt|*.clone) continue;; esac
  [ -d "$d/.git" ] || continue
  url=$(git -C "$d" remote get-url origin 2>/dev/null) || continue
  slug=$(slug_of "$url")
  topic=$(awk -F'\t' -v r="$slug" '$1==r{print $2; exit}' "$MANIFEST")
  sens=$(awk -F'\t' -v r="$slug" '$1==r{print $3; exit}' "$MANIFEST")
  if [ -z "$topic" ]; then unlisted="$unlisted $slug"; continue; fi
  mkdir -p "$BY/topic/$topic"
  ln -s "../../../$name" "$BY/topic/$topic/$slug"
  linked=$((linked+1))
  case "$sens" in y|Y) ln -s "../../$name" "$BY/sensitive/$slug";; esac
done

rmdir "$BY/sensitive" 2>/dev/null || true   # drop if nothing flagged on this machine
echo "categorize: linked=$linked  overlay=$BY"
[ -n "$unlisted" ] && echo "  not in manifest (add to repo-categories.tsv):$unlisted" >&2
exit 0
