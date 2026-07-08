# Board automation: cradle-to-grave

## Problem Statement

The board (Projects v2 #7) now tracks work from **Idea → Proposal → Draft → Done**, and
PR #17 (robogeosociety/.github#17, ports the project-sync reconciler + `--capture-open`)
keeps items filed into the right column on a schedule. But the lifecycle **stops at
`Done`**. The master Idea (robot-geographical-society#163) asks for *cradle-to-grave*:
issues → PRs → **deployments → releases**. Right now an item hits `Done` when its PR
merges, and nothing records whether that merge ever shipped — no deployment, no release,
no package. Merged-but-never-deployed work looks identical to shipped work.

There's also no way to slice the 250-item board: no saved views by topic label, by
priority, or by repo, so triage means scrolling one giant table.

## Requirements

- Add **Deployment** and **Release** linkage to board #7 so a `Done` item carries its
  shipped artifact (GitHub Deployment / Release / package).
- **Flag** any `Done` item that produced **no** trackable deployment or release, so
  merged-without-ship is visible rather than silent.
- Define a set of scoped **saved board views**: by topic label, by priority, by repo.
- GitHub built-ins first (Deployments API, Releases API, Projects v2 GraphQL); reuse
  the `project-sync` machinery from PR #17 rather than a new system.
- Notifications reuse `discobots` (GH activity → Discord) for "shipped / didn't ship"
  events; durable session/board data patterns reuse `obsidian-automations`.

## Solution

**1. Deploy/Release linkage.** Extend the PR #17 reconciler with a post-`Done` pass:
for each item entering `Done`, query the repo's **Deployments** (`GET
/repos/{o}/{r}/deployments`) and **Releases** (`GET /repos/{o}/{r}/releases`, plus
`git tag` on the merge SHA) reachable from the merged PR's commits. Add two Projects v2
custom fields to #7 — **Deployment** (text/URL) and **Release** (text/URL) — and write
the found artifact URL(s) via GraphQL `updateProjectV2ItemFieldValue`.

**2. Shipped/unshipped flag.** Add a **Shipped** single-select field
(`shipped` / `no-artifact`). When an item reaches `Done` and the deploy/release probe
finds nothing, set `no-artifact` and apply a `no-artifact` label on the source
issue/PR; `discobots` posts a one-line "merged, no deployment/release detected" note.
Items that legitimately ship nothing (docs-only, vault) can be excused with a
`ships-nothing` label the probe honors.

**3. Scoped saved views.** Create Projects v2 **saved views** on #7:
- **By topic** — one filtered table per high-traffic topic label (`cicd`, `maps`,
  `discobots`, `pure-python`, …), `filter: label:<topic>`.
- **By priority** — a board grouped on a new **Priority** single-select (P0–P3).
- **By repo** — a table grouped by the built-in **Repository** field.

Views are declared in a committed `docs/board-views.md` manifest and applied via a
small idempotent `scripts/board-views.py` (Projects v2 GraphQL) so they're
reproducible, not hand-clicked — the same "canonical file → reconcile" discipline the
rest of the repo uses. Python-first (Node/Rust not needed).

## Alternatives

- **Manual view creation in the Projects UI** — fast to start but drifts and isn't
  reproducible; the manifest+script keeps them canonical. UI is fine for one-offs.
- **Infer "shipped" from PR merge alone** — rejected; merge ≠ ship, which is exactly the
  gap this closes.
- **A GitHub Teams plan** unlocks **more Projects v2 insights/charts, workflows, and
  higher automation limits**, which would simplify the shipped/unshipped rollup and
  view automation (built-in project workflows instead of a cron reconciler). Noted as
  the paid simplification.
- **Reuse `obsidian-automations`** to persist a board snapshot for history/audit — a
  good durable-data follow-up (dev-wiki timeline), layered on, not blocking.

## Tasks

- [ ] Add **Deployment**, **Release**, **Shipped**, **Priority** fields to board #7.
- [ ] Extend the PR #17 reconciler with a post-`Done` deploy/release probe (Deployments + Releases APIs).
- [ ] Write found artifact URLs to the Deployment/Release fields via Projects v2 GraphQL.
- [ ] Set `Shipped=no-artifact` + `no-artifact` label when nothing ships; honor `ships-nothing`.
- [ ] Add `docs/board-views.md` manifest + idempotent `scripts/board-views.py`.
- [ ] Create saved views: by topic label, by priority, by repo.
- [ ] `discobots`: post a "merged, no deployment/release detected" note for flagged items.
- [ ] Verify: merge a PR that deploys → fields populate; merge a docs-only PR → flagged (or excused via `ships-nothing`).

## Further Reading

- Master Idea — robot-geographical-society#163
- Board reconciler — robogeosociety/.github#17, robot-geographical-society#161
- Topic labels — robogeosociety/.github#13 (+ Proposal A)
- GitHub Deployments API, Releases API, Projects v2 GraphQL
- Prior art — `discobots` (GH activity → Discord), `obsidian-automations` (durable session/board data)
