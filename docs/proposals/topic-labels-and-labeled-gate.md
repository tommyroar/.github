# Topic labels + "everything is labeled" CI gate

## Problem Statement

The org has two axes of labels but only one is canonical. The **process** axis —
task system (`human-task`/`machine-task`/`parked`), the proposal/merge lane, and the
PR-gate bypasses — is codified in `scripts/labels.tsv` and reconciled fleet-wide by
`scripts/labels.sh` (PR #13, building on #9). The **topic/domain** axis — the 15
labels the master Idea names (`cicd`, `automations`, `discobots`, `vite`, `playwright`,
`cloudflare`, `cloudflare-pages`, `github-pages`, `pure-python`, `maps`, `tommybots`,
`atlas`, `obsidian`, `wikis`, `asyncio`) — was hand-provisioned org-wide but lives in
no source of truth. If a repo drifts, nothing heals it; if a new repo is added, the
topic set is absent until someone remembers.

Worse, nothing *enforces* labeling. The master Idea (robot-geographical-society#163)
requires that **every issue and PR carries a label** and that **every issue is a
`human-task` or `machine-task`** — but a blank-labeled issue or PR sails through today,
so the board (Projects v2 #7) silently drifts out of its topic lanes.

## Requirements

- The 15 topic labels become canonical in `scripts/labels.tsv`, under a new
  "Topic / domain" group, so fleet-sync heals them like the process labels.
- A CI gate **fails** any issue or PR that carries **zero** labels.
- Issues must additionally carry `human-task` **or** `machine-task` (kind gate).
- The gate skips `dependabot[bot]`/`github-actions[bot]` and honors a
  `skip-label-gate` escape hatch (mirrors `skip-structure-gate`).
- Reuse the existing `labels.tsv` → `labels.sh` → `fleet-sync.yml` pattern; the gate
  ships as a `workflow-template` and reaches repos via `sync.sh`/`fleet-sync`.
- GitHub built-ins only — no external services, no secrets.

## Solution

**1. Extend `scripts/labels.tsv`** with a `# ── Topic / domain ──` group holding the
15 labels at their already-provisioned colors/descriptions (from the live org set,
e.g. `cicd 1D76DB`, `pure-python 3776AB`, `asyncio BFDADC`). This is additive to
`labels.sh`'s existing reconcile loop — no code change; the next fleet-sync run
converges all 27 repos and reports zero pending changes.

**2. Add `.github/workflow-templates/label-gate.yml`** — a deterministic gate on
`issues: [opened, reopened, labeled, unlabeled]` and
`pull_request: [opened, reopened, labeled, unlabeled, ready_for_review]`. Pure
`actions/github-script` (no secret, no checkout): it reads
`event.issue.labels` / `event.pull_request.labels` and fails when the set is empty;
for issues it also fails unless `human-task` or `machine-task` is present. Skips bot
actors and short-circuits when `skip-label-gate` is applied — the same shape as
`pr-structure-gate.yml`'s `if:` guard.

**3. Wire it into `sync.sh`** as another synced workflow (like the structure/style
gates), so `fleet-sync.yml`'s weekly Monday self-heal installs it in every repo and
provisions `skip-label-gate` via `labels.tsv`.

Python-first: the gate logic is small enough for inline `github-script` (Node is the
only runtime GitHub Actions offers `github-script` in); a Python reference validator
under `scripts/` can back it if the logic grows, matching `pr-structure-gate.yml`'s
embedded-Python style.

## Alternatives

- **Branch-protection "required label"** — GitHub has no native "must have any label"
  rule; label-based required checks don't exist. Rejected.
- **A GitHub Teams plan** would unlock org-level **default labels** (auto-applied to
  new repos) and richer rulesets, removing the need to reconcile the topic set into
  every repo. Noted as the paid simplification; not assumed here.
- **Reuse `discobots`** to nag unlabeled items in Discord — good as a *notification*
  follow-up, but it can't block a merge; the gate must be CI. Kept for later.
- **A single combined gate** merging structure + labels — rejected; separate gates
  don't churn (per `PR_FRAMEWORK.md`'s hard/soft split rationale).

## Tasks

- [ ] Add the `# ── Topic / domain ──` group with all 15 labels to `scripts/labels.tsv`.
- [ ] Dry-run `labels.sh` against one repo (`REPO_ONLY=`) to confirm zero-delta convergence.
- [ ] Author `.github/workflow-templates/label-gate.yml` + `.properties.json`.
- [ ] Add `skip-label-gate` to `labels.tsv` (PR-gate bypass group).
- [ ] Add `label-gate.yml` to the `sync.sh` synced-workflow list.
- [ ] Verify: open a blank-labeled test issue and PR; confirm the gate fails; add a label; confirm it passes.
- [ ] Document the gate + escape hatch in `README.md` alongside the other two gates.

## Further Reading

- Master Idea — robot-geographical-society#163
- Canonical label taxonomy — robogeosociety/.github#13, #9
- PR gates + framework — `robogeosociety/.github/PR_FRAMEWORK.md`, `README.md`
- Board maintainer — robot-geographical-society#161, robogeosociety/.github#17
