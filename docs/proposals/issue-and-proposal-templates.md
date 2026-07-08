# Issue & proposal templates + template-presence gate

## Problem Statement

New work is created ad hoc. This repo already standardizes **PR bodies** — the
newspaper spine in `PR_FRAMEWORK.md`, enforced by `pr-structure-gate.yml` (hard) and
`pr-style-review.yml` (soft). But **issues** have no template at all, and the
**Proposal PR** shape (the six-section PLAN this very document uses) is a convention
carried only in the master Idea's prose, not in the repo. Result: ideas land as
free-text blobs the board can't triage, and proposals drift in structure.

The master Idea (robot-geographical-society#163) requires that all new work start from
a template (or a blank issue when none fits), and that idea issues fit one iPad screen
with a fixed shape. Nothing provides or checks that today.

## Requirements

- Add `.github/ISSUE_TEMPLATE/idea.md` with exactly
  `## Problem statement` / `## Use cases` / `## Requirements` — one iPad screen.
- Keep a blank-issue path (`config.yml` with `blank_issues_enabled: true`) for work
  that fits no template, per the master Idea.
- Formalize the **Proposal PR** six-section PLAN
  (`## Problem Statement` / `## Requirements` / `## Solution` / `## Alternatives` /
  `## Tasks` / `## Further Reading`) as a repo-level convention doc.
- Add a CI check flagging issues opened without a matching template.
- **Do not duplicate** the PR structure gate — proposal PR bodies still follow
  `PR_FRAMEWORK.md`; this proposal only governs the *plan doc's* section shape and
  references the existing gate rather than re-implementing it.

## Solution

**1. `.github/ISSUE_TEMPLATE/idea.md`** — a front-matter issue-form-lite markdown
template (`name: Idea`, `labels: [machine-task]` default, editable) with the three H2
sections and a one-screen length note. Public repos pick it up automatically from
`.github`; private repos vendor it via `sync.sh`.

**2. `.github/ISSUE_TEMPLATE/config.yml`** — `blank_issues_enabled: true` plus a
contact link pointing to the master Idea, so "no template fits" stays a first-class
path.

**3. Proposal PLAN convention** — a short `docs/proposals/TEMPLATE.md` capturing the
six H2 sections + the 1–3-screen budget, referenced from `README.md`. Proposals are
PRs, so their *body* is still governed by `PR_FRAMEWORK.md` and its structure gate —
this template governs only the committed `docs/proposals/<slug>.md` plan.

**4. `.github/workflow-templates/template-presence-gate.yml`** — on
`issues: [opened]`, a `github-script` check (no secret) that reads the issue body and
warns/fails when it matches **none** of the shipped templates' section spines (e.g.
lacks all of `## Problem statement`/`## Use cases`/`## Requirements`). It posts one
advisory comment and skips bots + a `skip-template-gate` escape hatch. To avoid
churn it defaults to **advisory** (comment only), promotable to blocking per repo —
matching the hard/soft split rationale in `PR_FRAMEWORK.md`. It explicitly defers all
*PR* body checks to `pr-structure-gate.yml`.

Python-first: the matching logic is a small embedded validator (same style as
`pr-structure-gate.yml`'s inline Python), invoked from `github-script`.

## Alternatives

- **GitHub Issue Forms (YAML `.github/ISSUE_TEMPLATE/*.yml`)** — richer, structured
  fields, and the form itself enforces required inputs at creation time, reducing the
  need for a gate. Strong option; deferred because markdown templates match the
  existing `pull_request_template.md` style and are easier to keep one-screen. Worth
  revisiting if the gate churns.
- **A GitHub Teams plan** would allow **org-level** issue templates shared across all
  repos from `.github`, removing the per-repo `sync.sh` vendoring for private repos.
  Noted as the paid simplification.
- **No gate, template only** — templates are only a *prompt*; nothing stops a blank
  issue. The advisory gate is the minimum that keeps the board triage-able.
- **Reuse `obsidian-automations`** template-rendering for issues — over-engineered for
  a three-section form; GitHub-native templates suffice.

## Tasks

- [ ] Add `.github/ISSUE_TEMPLATE/idea.md` (three H2 sections, one-screen note).
- [ ] Add `.github/ISSUE_TEMPLATE/config.yml` (blank issues enabled + Idea contact link).
- [ ] Add `docs/proposals/TEMPLATE.md` (six-section PLAN convention) + link from `README.md`.
- [ ] Author `template-presence-gate.yml` + `.properties.json` (advisory, bot-skip, `skip-template-gate`).
- [ ] Add `skip-template-gate` to `labels.tsv`; add the gate to `sync.sh`'s synced set.
- [ ] Verify: open an issue from the Idea template (passes) and a blank ad-hoc issue (advisory comment fires).

## Further Reading

- Master Idea — robot-geographical-society#163
- PR framework + structure gate — `robogeosociety/.github/PR_FRAMEWORK.md`, `.github/workflow-templates/pr-structure-gate.yml`
- Label taxonomy — robogeosociety/.github#13, #9
- Existing PR template — `.github/pull_request_template.md`
