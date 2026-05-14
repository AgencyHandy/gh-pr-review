# GH PR Review Checklist

A portable review spec for auditing one or more related GitHub PRs using `gh` (without local checkout).

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

## Codex Setup

### Skill

Place the skill at:

- `~/.agents/skills/gh-pr-review-checklist/SKILL.md`

### Slash Command

Place this prompt file at:

- `~/.codex/prompts/pr-review-gh.md`

Run as:

```text
/prompts:pr-review-gh PRS="https://github.com/org/repo/pull/1 https://github.com/org/repo/pull/2" CONTEXT="..." MODE=full
```

If it does not appear immediately, open a new chat or restart Codex.

## Claude Setup

Claude does not use Codex `SKILL.md` or `/prompts:...` paths directly.

Use one of these:

1. Save the portable prompt as a project/system instruction in Claude.
2. Create a custom slash/quick command in your Claude client (if supported) that injects the same prompt with `PRS`, `CONTEXT`, and optional `MODE`.
3. Paste the Core Prompt manually when needed.

## Any Other Tool

1. Keep the **Core Prompt** as a reusable template.
2. Provide `PRS`, `CONTEXT`, and optional `MODE`.
3. Ensure `gh` access (or equivalent GitHub API access) is available.

## Notes

- This workflow is intentionally review-focused, not auto-fix focused.
- It is optimized for related PR batches in one work unit.
- `blockers-only` is for fast triage; `full` is default and recommended.
