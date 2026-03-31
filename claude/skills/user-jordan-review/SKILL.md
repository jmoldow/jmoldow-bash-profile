---
name: user-jordan-review
description: Reviews files changed vs the default branch (origin/HEAD) for correctness, style, test coverage, and documentation. Findings grouped by severity: blocking, suggestion, nit. Use when the user asks for a code review or invokes /user-jordan-review.
argument-hint: "[focus areas to prioritize, e.g. 'focus on security']"
---

# Code Review

1. Identify all files changed in the current branch vs the default branch (e.g. origin/HEAD)
2. For each file, check:
   - Correctness and edge cases
   - Style consistency with existing code
   - Test coverage gaps
   - Documentation/docstring completeness
   - In general: consistency with all documented standards. Look for standards in the same places as the
     /user-jordan-ingest-floss-project skill.
3. Present findings grouped by severity: blocking, suggestion, nit
4. Keep review concise—no more than 2 sentences per finding

## Additional Focus Areas (optional)

$ARGUMENTS

If focus areas were provided above, prioritize those areas. Otherwise, follow the full workflow.
