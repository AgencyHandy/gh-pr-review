---
description: Review one or more related GitHub PRs via gh with full checklist (tests, migrations, edge cases, quality, UI verification)
argument-hint: PRS="<url1> <url2> <url3...>" CONTEXT="<intended fix>" [MODE=full|blockers-only]
---

Using `gh` CLI, review the provided PR(s) without pulling/checking out locally.

Inputs:
- PRS: $PRS
- Context: $CONTEXT
- Mode: $MODE

Rules:
- If MODE is missing/empty, default to `full`.
- Use `gh` / GitHub API data only; do not locally checkout the PR branch.
- If multiple PRs are given, review each PR individually, then do a cross-PR analysis for overlap/divergence/conflicting assumptions/order dependencies.

Required checks:
1. Changes made in existing files (what changed and why it matters).
2. Tests introduced or missing for the changed behavior.
3. Whether migration is required according to code/model/schema changes.
4. Validate migration correctness against code changes and existing schema/models visible from PR/base/head files.
5. Edge cases/regressions introduced by this change.
6. Code quality issues.
7. For each issue, provide clear UI steps to confirm/reproduce.

Output format:
## PR Review

### Scope
- PRs reviewed
- Branches
  - <pr link>: base=<baseRefName>, head=<headRefName>
- Mode

### Changes in Existing Files
- file-by-file change summary

### Findings (ordered by severity)
1. [severity] issue
- Evidence
- Why it matters
- UI confirmation steps

### Tests
- Added/updated
- Missing/high-risk gaps

### Migration
- Migration needed: yes/no
- Migration present: yes/no
- Correctness vs code+schema/models: valid/invalid/partial
- Notes

### Edge Cases
- Case + status

### Overall
- Verdict: approve | request changes | discuss
- Residual risks
