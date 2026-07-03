# .github — shared PR "newspaper" framework (defaults)

Account-wide defaults for Tommy's repos. The PR description format is a
**newspaper / information pyramid** that reads top-to-bottom on an iPad-mini
portrait display. Full rules + voice: [`PR_FRAMEWORK.md`](PR_FRAMEWORK.md).

## What's here
- **`.github/pull_request_template.md`** — the newspaper skeleton. Auto-applies to
  public repos with no template of their own; private repos vendor their own copy.
- **`PR_FRAMEWORK.md`** — the canonical rules + voice (read before writing a body).
- **`.github/workflow-templates/pr-structure-gate.yml`** — the hard, deterministic
  CI gate on the PR description (below).
- **`.github/workflow-templates/pr-style-review.yml`** — the flexible, agentic
  length/style gate (below).

## Two gates, one framework
The old monolithic `pr-newspaper` validator failed on *everything* — structure **and**
subjective length/style — which churned. It's retired. Enforcement is now split into a
hard half and a soft half, each doing the job it's actually good at:

| Gate | File | What it does | Blocks merge? |
|------|------|--------------|:---:|
| **Structure gate** | `pr-structure-gate.yml` | Deterministic regex check that the body has the required newspaper spine — one `#` headline, an italic dek, a `> [!NOTE]` masthead, no heading-level skips, alt text on every image, no unfilled template placeholders. Objective only, so it doesn't churn. | ✅ yes |
| **Style review** | `pr-style-review.yml` | Agentic (Claude Code Action) judgment on the soft rules: length budget (with room to *double* it for genuinely complex code changes), Wired voice, whether mermaid diagrams actually make sense, and linking related open/draft issues. Posts one advisory comment. | ❌ no |

Both are self-contained workflow templates: one-click-selectable from the Actions
"New workflow" UI, and synced into every owned repo by [`scripts/sync.sh`](scripts/sync.sh).
The style review reuses the `CLAUDE_CODE_OAUTH_TOKEN` secret sync already sets.

**Escape hatches:** label a PR `skip-structure-gate` to bypass the hard gate, or
`skip-style-review` to skip the agentic one; bot authors (dependabot) are skipped
automatically. To make the structure gate a *required* check, mark it required in each
repo's branch-protection rules.

## Generation vs enforcement
Generation happens **once**, by the agent that opens/updates a PR (it writes the body
from the full diff). There is no per-push `claude -p` regeneration. For a human push
with no agent, run `~/.claude/pr-framework/refresh_pr.sh <n>` locally. The two gates
above then check what was written — the hard gate deterministically, the style review
with judgment.
