# AHR PR Review Checklist

A portable review spec for auditing one or more related GitHub PRs using `gh` (without local checkout).

Enables you and your AI Agents to systematically review PRs for code quality, correctness, migrations, edge cases, and more, all based on PR data and GitHub API access instead of local code checkout.

> [!IMPORTANT]
> This is a review checklist, not an auto-fix tool. It is designed to identify issues and risks, not to automatically resolve them. And it can make false positives/negatives, so human judgment is still required for the final verdict.

## What This Does

This workflow reviews all provided PRs as one work unit and checks:

1. Changes in existing files
2. Tests added/missing
3. Whether migration is needed
4. Whether migration is correct vs code + schema/models
5. Edge cases/regressions
6. Code quality
7. UI confirmation steps for each issue
8. Branch names for every PR (`base`, `head`)

Default mode is `full`.

## Quick Start

1. Install the skill:

```bash
npx skills add AgencyHandy/ahr --skill "ahr"
```

2. Install slash commands/prompts (global by default):

```bash
curl -fsSL https://raw.githubusercontent.com/AgencyHandy/ahr/main/scripts/install-commands.sh -o /tmp/ahr-install-commands.sh && chmod +x /tmp/ahr-install-commands.sh && /tmp/ahr-install-commands.sh
```

The installer auto-detects Codex, Claude, and OpenCode from your system and installs only for detected tools.
It also respects `CODEX_HOME`, `CLAUDE_CONFIG_DIR`, and `OPENCODE_CONFIG_DIR` when set.
To pin to a release tag, pass `AHR_REF` (example: `AHR_REF=v0.2.1 /tmp/ahr-install-commands.sh`).

3. Run:

```text
Codex: /prompts:ahr PRS="https://github.com/org/repo/pull/1 https://github.com/org/repo/pull/2" CONTEXT="..." MODE=full
Claude/OpenCode: /ahr PRS="https://github.com/org/repo/pull/1 https://github.com/org/repo/pull/2" CONTEXT="..." MODE=full
```

You can run these slash commands in terminal and desktop app environments for the corresponding tool.
Examples: Codex desktop app, Claude Code app/CLI, and OpenCode UI/TUI.

To install command files into the current project instead of home directories:

```bash
curl -fsSL https://raw.githubusercontent.com/AgencyHandy/ahr/main/scripts/install-commands.sh -o /tmp/ahr-install-commands.sh && chmod +x /tmp/ahr-install-commands.sh && /tmp/ahr-install-commands.sh --project
```

## Required Inputs

1. PR links (one or more)
2. Context (intended fix/behavior)

Optional:

1. Mode (`full` or `blockers-only`)

## Output Contract

Use this structure:

```markdown
## PR Review

### Scope
- PRs reviewed: <links>
- Branches:
  - <pr link>: base=<baseRefName>, head=<headRefName>
- Mode: full | blockers-only

### Changes in Existing Files
- <file/path>: <what changed and why it matters>

### Findings (ordered by severity)
1. [severity] <issue>
- Evidence: <file + diff observation>
- Why it matters: <risk>
- UI confirmation steps:
  1. <step>
  2. <step>

### Tests
- Added/updated:
- Missing/high-risk gaps:

### Migration
- Migration needed: yes/no
- Migration present: yes/no
- Correctness vs code+schema/models: valid/invalid/partial
- Notes:

### Edge Cases
- <case + status>

### Overall
- Verdict: approve | request changes | discuss
- Residual risks:
```

## Core Prompt (Portable)

Use this prompt in any assistant/tool:

```text
Using gh CLI, review the provided PR(s) without pulling/checking out locally.

Inputs:
- PRS: <space-separated PR URLs>
- Context: <intended fix>
- Mode: <full|blockers-only> (default full)

Rules:
- Use gh / GitHub API data only.
- Review each PR individually, then do cross-PR analysis for overlap/divergence/conflicting assumptions/order dependencies.
- Always validate migrations when model/schema-impacting changes exist.
- Report branch names (base/head) for each PR.
- If something cannot be verified from PR/repo data, mark as unconfirmed.

Required checks:
1) existing-file changes
2) tests
3) migration needed or not
4) migration correctness vs code+schema/models
5) edge cases/regressions
6) code quality
7) UI confirmation steps per issue

Return output in the documented PR Review format.
```

## Repository Layout

- `skills/ahr/SKILL.md` - skill package for `npx skills add`
- `.codex/prompts/ahr.md` - Codex prompt command source
- `.claude/commands/ahr.md` - Claude command source
- `.opencode/commands/ahr.md` - OpenCode command source
- `scripts/install-commands.sh` - helper installer for command files

## Any Other Tool

1. Keep the **Core Prompt** as a reusable template.
2. Provide `PRS`, `CONTEXT`, and optional `MODE`.
3. Ensure `gh` access (or equivalent GitHub API access) is available.

## Notes

- This workflow is intentionally review-focused, not auto-fix focused.
- It is optimized for related PR batches in one work unit.
- `blockers-only` is for fast triage; `full` is default and recommended.
