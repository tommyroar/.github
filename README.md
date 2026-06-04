# .github — shared PR "newspaper" framework

Account-wide defaults + reusable CI for Tommy's repos. The PR description format
is a **newspaper / information pyramid** that reads top-to-bottom on an iPad-mini
portrait display. Full rules: [`PR_FRAMEWORK.md`](PR_FRAMEWORK.md).

## What's here

- **`.github/pull_request_template.md`** — the newspaper skeleton. Auto-applies to
  public repos with no template of their own; private repos vendor their own copy.
- **`.github/workflows/pr-newspaper.yml`** — a **reusable** workflow that validates a
  PR body (readability + page budget) with **no model in the loop**.
- **`scripts/validate_pr.py`** — pure-stdlib validator (height/page budget, structure).
- **`scripts/tier.py`** — sizes the 2- vs 4-page budget from a PR's non-prose churn.
- **`PR_FRAMEWORK.md`** — the canonical rules + voice (read this before writing a body).

## Wire a repo up

Add `.github/workflows/pr-newspaper.yml` to the repo:

```yaml
name: PR newspaper
on:
  pull_request:
    types: [opened, edited, reopened]
jobs:
  newspaper:
    uses: tommyroar/.github/.github/workflows/pr-newspaper.yml@main
```

That's the whole gate — the validator and tiering live here, so fixes land once.
A short "Pull requests" pointer in the repo's `AGENTS.md`/`CLAUDE.md` lets agents
(including Claude Code web, which can't see `~/.claude`) follow the format.

## Generation vs enforcement

Generation happens **once**, by the agent that opens/updates a PR (it writes the
body from the full diff). This repo only **enforces** — there is no per-push
`claude -p` regeneration. For a human push with no agent, run
`~/.claude/pr-framework/refresh_pr.sh <n>` locally.
