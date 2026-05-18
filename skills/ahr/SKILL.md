---
name: ahr
description: Use when the user wants a GitHub PR review via gh CLI (without local checkout), especially for multiple related PRs in one work unit, with a full checklist covering changed files, tests, migration need/correctness, edge cases, code quality, and UI validation steps.
---

# AHR PR Review Checklist

## Purpose

Run a consistent PR audit using `gh` only (no local pull/checkout), with `full` mode as default.

## Inputs

Required:
- PR link(s): one or more GitHub PR URLs
- Context: short statement of intended fix/behavior

Optional:
- mode: `full` (default) or `blockers-only`

## Hard Rules

- Do not pull, checkout, or run local branch diff for the target PR.
- Use `gh`/GitHub API data only.
- If multiple PRs are provided for the same unit of work, review each PR individually and then as a combined set.
- Always run migration validation when backend/data model changes exist.

## Workflow

1. Parse each PR URL into `owner/repo` and PR number.
2. Collect metadata:
   - `gh pr view <number> --repo <owner/repo> --json title,body,baseRefName,headRefName,files,commits`
   - `gh pr diff <number> --repo <owner/repo>`
   - Capture and report `baseRefName` and `headRefName` for each PR
3. Build changed-file summary:
   - Existing files modified
   - New files added
   - Removed files
4. Tests check:
   - Detect new/updated tests
   - Map changed behavior to test coverage
   - Flag missing tests for risky paths
5. Migration need check:
   - From diff, detect model/schema-impacting changes (new fields, type/constraint/index/default/nullable changes, enum/state shifts, relation changes)
   - Decide whether migration is required
6. Migration correctness validation (mandatory when migration exists or should exist):
   - Compare migration operations with actual code/model changes
   - Compare with current schema/model references visible from PR/base/head files via `gh` (for example `db/schema.rb`, model files, schema definitions)
   - Validate naming and data shape alignment
   - Flag mismatches (missing column/index/constraint updates, wrong nullability/default/type, incomplete backfill implications)
7. Edge case/regression scan:
   - State transitions, stale cached/previous values, fallback behavior, feature-flag/template conditional behavior, loading flicker/race, and permission/visibility mismatches
8. Code quality scan:
   - Readability, duplication, dead paths, fragile conditionals, unsafe assumptions, missing guards, error handling
9. For each issue found, provide concrete UI confirmation steps.
10. If multiple related PRs are provided, add cross-PR analysis:
   - overlap/divergence
   - conflicting assumptions
   - ordering/dependency risk between PRs
   - combined regression surface

## Output Format

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

## Default Behavior

- If mode is omitted, use `full`.
- Infer schema/model references from PR contents and repository files accessible through `gh`.
- If something cannot be verified from available PR/repo data, explicitly state it as unconfirmed rather than guessing.
