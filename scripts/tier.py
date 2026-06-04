#!/usr/bin/env python3
"""Print the iPad-mini page budget (2 or 4) for a PR from its changed-files JSON.

Input: the JSON from `gh pr view --json files` — {"files":[{path, additions, deletions}, …]}.
The 4-page tier unlocks only on substantial *non-prose* churn (>400 non-prose lines OR
>15 non-prose files); pure-prose edits (.md/.markdown/.mdx/.txt/.rst/.org/.adoc — incl.
Obsidian-vault PRs) don't count, so docs PRs stay at the 2-page default.
"""
import json
import re
import sys

PROSE = re.compile(r"\.(md|markdown|mdx|txt|rst|org|adoc)$", re.I)

data = json.load(open(sys.argv[1], encoding="utf-8"))
files = data.get("files", []) if isinstance(data, dict) else data
nonprose = [f for f in files if not PROSE.search(f.get("path", ""))]
lines = sum((f.get("additions", 0) or 0) + (f.get("deletions", 0) or 0) for f in nonprose)
print(4 if (lines > 400 or len(nonprose) > 15) else 2)
