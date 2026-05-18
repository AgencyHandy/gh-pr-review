---
description: Review one or more related GitHub PRs via gh (tests, migration, edge cases, code quality, UI verification)
---

Review the provided GitHub PR(s) using `gh` only (no local checkout).

Arguments:
$ARGUMENTS

Interpret arguments as:
- `PRS="<url1> <url2> ..."` (required)
- `CONTEXT="<intended fix>"` (required)
- `MODE=full|blockers-only` (optional, default `full`)

Rules:
- Use `gh` / GitHub API data only.
- Do not pull or checkout PR branches locally.
- If multiple PRs are provided, review each individually and then perform cross-PR analysis.
- Always validate migration need and migration correctness when model/schema-impacting changes exist.

Required checks:
1. Changes in existing files and why they matter.
2. Tests added/updated and missing high-risk gaps.
3. Whether migration is needed.
4. Migration correctness vs code+schema/models.
5. Edge cases/regressions.
6. Code quality risks.
7. UI confirmation steps for each issue.

Output format:
## PR Review

### Scope
- PRs reviewed
- Branches
  - <pr link>: base=<baseRefName>, head=<headRefName>
- Mode

### Changes in Existing Files
- file-by-file summary

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
