---
name: user-jordan-review
description: >
  Reviews code changes in Jordan's personal review style — conversational, question-based,
  with findings grouped by severity (blocking/suggestion/nit). Supports reviewing a PR
  (by number or URL), a single commit, a branch diff against its merge-base, or a range
  of commits. Use when the user asks for a code review, PR review, diff review, or invokes
  /user-jordan-review. Also trigger when the user says "review this", "review my changes",
  "what do you think of this diff", "look over this branch", "check this PR", or similar
  review-related requests.
argument-hint: "[PR number/URL | commit SHA | branch | commit..range] [focus areas]"
---

# Code Review — Jordan's Style

Before starting, read `references/review-voice.md` (in this skill's directory) to understand
the review voice, comment patterns, severity criteria, and language to use throughout.

## Step 1: Determine Review Mode

Parse `$ARGUMENTS` to figure out what to review. The first non-focus-area argument determines
the mode. Everything else is treated as focus area guidance.

| Input pattern | Mode | Example |
|---------------|------|---------|
| PR number (`^\d+$`) | PR | `1234` |
| GitHub PR URL (`github.com/.*/pull/\d+`) | PR | `https://github.com/org/repo/pull/1234` |
| Hex string 7-40 chars (`^[0-9a-f]{7,40}$`) | Commit | `abc1234` |
| Contains `..` | Range | `abc123..def456` or `main..feature-branch` |
| Branch name | Branch | `feature-branch` |
| No argument / empty | Default | Current branch vs origin/HEAD |

If the input is ambiguous (could be a branch name or SHA prefix), check with `git rev-parse`
to disambiguate. Prefer branch interpretation if both match.

## Step 2: Gather Context

Run the appropriate commands for the detected mode. Gather the diff, metadata, and commit
messages. Use parallel tool calls where possible.

### PR Mode
```bash
# Diff
gh pr diff <N>
# Metadata (title, body, author, files, labels)
gh pr view <N> --json title,body,author,baseRefName,headRefName,files,commits,labels,additions,deletions,changedFiles
# Individual commit messages
gh pr view <N> --json commits --jq '.commits[].messageHeadline'
```

### Commit Mode
```bash
# Diff + metadata in one command
git show <sha>
# Just the stats
git show --stat <sha>
```

### Range Mode
```bash
# Diff
git diff <range>
# Commit log
git log --format="%h %s" <range>
# Stats
git diff --stat <range>
```

### Branch Mode / Default
```bash
# Compute merge base (matches Jordan's git alias: diff-merge-base-origin-HEAD-HEAD)
git diff $(git merge-base origin/HEAD HEAD)..HEAD
# Commit log since fork point
git log --format="%h %s" $(git merge-base origin/HEAD HEAD)..HEAD
# Stats
git diff --stat $(git merge-base origin/HEAD HEAD)..HEAD
```

For branch mode with an explicit branch name, replace `HEAD` with the branch name.

### Read Changed Files

For each changed file, read the full current version using the Read tool. This provides
surrounding context beyond what the diff hunks show — important for understanding whether
a change is consistent with the rest of the file.

For very large files (>1000 lines), focus on the changed regions and 50 lines of context
above and below each hunk.

## Step 3: Load Project Standards

Check for project-specific conventions that the review should enforce. Read these if they
exist (use the Read tool, don't fail if missing):

- `CLAUDE.md` and `AGENTS.md` at the repo root
- `.cursor/rules/` directory for language-specific rules (`.mdc` files)
- `.editorconfig` for formatting standards
- `pyproject.toml` or `setup.cfg` for Python tool configuration (ruff, mypy, etc.)

These provide project-specific context for what "correct" looks like in this codebase.

## Step 4: Triage Files

Not all files deserve equal review depth. Prioritize:

**Deep review** (read fully, check every hunk):
- Logic-bearing source: `.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.rs`, `.java`, `.sql`
- Shell scripts: `.sh`, `.bash`
- Build configuration: `BUILD`, `BUILD.pants`, `Makefile`, `Dockerfile`

**Medium review** (scan for obvious issues):
- Config/infra: `.yaml`, `.yml`, `.toml`, `.json`, `.tf`, `.hcl`
- CI config: `.buildkite/`, `.github/workflows/`

**Light review** (flag but don't line-review):
- Lock files: `package-lock.json`, `yarn.lock`, `poetry.lock`, `Pipfile.lock`
- Auto-generated: migration files, compiled outputs, `__generated__/`
- Large data files

Note in the review output which files received which level of review.

## Step 5: Review Each File

For each file, apply the review checklist below. The order reflects Jordan's actual review
priorities (most frequent comment topics first):

### 5a. Architecture & Design Patterns
- Is there unnecessary duplication? Could code be shared or auto-generated?
- Are abstractions at the right level? (not over-engineered, not under-abstracted)
- Would a different pattern be more appropriate? (dataclass vs dict, enum vs string literal,
  builder pattern, property vs method)
- Are there opportunities for code reuse across the codebase?

### 5b. Build System & Shell Correctness
- Shell variable expansion: `$VAR` vs `$$VAR` (YAML parse-time vs runtime)
- Environment variable propagation across pipeline steps
- Pants target configuration (source roots, dependencies, overrides)
- Buildkite plugin usage and step configuration

### 5c. Type Safety & Naming
- Unnecessary `cast()` calls — can the source type be improved instead?
- `type: ignore` comments — can they be eliminated with better typing?
- Names that could confuse readers (e.g., "ci-token" for something unrelated to CI)
- Function names that don't reflect their actual scope

### 5d. Correctness & Edge Cases
- Logic errors, off-by-one, wrong conditions
- Missing error handling for likely failure modes
- Deployment implications (will this work in all environments?)
- API surface: are function signatures, return types, and error types correct?
- String matching that could have unintended collisions

### 5e. Licensing & Copyright
- Vendored code must have appropriate license headers
- Third-party code must be attributed

### 5f. Documentation Accuracy
- Are existing comments still accurate after this change?
- Could any comments become stale or misleading?
- Are there misleading variable/function names that should be updated?

### 5g. Code Reuse & DRY
- Is similar logic duplicated that could be extracted to a shared function?
- Could a snippet, template, or helper avoid future duplication?
- Are there existing utilities in the codebase that already do what's being written?

### 5h. Testing
- Are new code paths covered by tests?
- Mock patterns: `patch.object()` preferred over string-based `patch()`
- Test placement: are tests in the right file/directory?
- Could parametrize reduce test duplication?

### 5i. Security
- Exposed secrets or credentials
- Missing authentication/authorization checks
- Injection vulnerabilities (SQL, command, template)
- CORS configuration issues
- Permission scoping (too broad?)

### 5j. Cross-File Analysis
This is critical and often missed by automated tools. Trace the implications of changes:
- If a function signature changed, are all callers updated?
- If a config value changed, are all consumers consistent?
- If a new dependency was added, is it properly declared in build files?
- If an API changed, are clients and docs updated?

## Step 6: Format Output

Present the review in this structure:

```
## Review: [title or branch description]

**Scope**: [N files changed, +X/-Y lines] | **Mode**: [PR #123 / commit abc123 / branch x vs origin/HEAD]
**Review depth**: Deep: [list]. Medium: [list]. Skimmed: [list].

### Summary

[1-3 sentences: what this change does, overall assessment, and any high-level concerns]

### Blocking

[Items that should be fixed before merge. Use for objective problems only.]

**`file_path:line_number`** — [concise title]
> [Explanation using Jordan's voice — question-based, educational, explains WHY]
>
> ```python
> # suggested fix if applicable
> ```

### Suggestions

[Improvements that make code better but don't block merge.]

**`file_path:line_number`** — [concise title]
> [Same voice — "Consider...", "I'd suggest...", offers alternatives]

### Nits

[Personal preferences, clearly flagged.]

**`file_path:line_number`** — [concise title]
> Nitpick: [explanation, framed as preference not mandate]

### Looks Good

[Optional — brief callouts of things done well. Only include if genuinely noteworthy.]

---

[Approval recommendation — pick the one that fits:]
- "I'd approve this as-is."
- "I'd approve once the blocking items are addressed."
- "Approved to unblock, but if you could look at my suggestions, that would be great!"
- "I'd want to discuss [X] before this merges."
- "I'm fine merging this as-is, but [suggestion] might be worth a follow-up PR."
```

### Output Rules

- Every finding must include `file_path:line_number` for navigation
- Keep each finding concise — aim for 2-4 sentences of explanation
- Use questions, not directives (per review-voice.md)
- Include code suggestions in fenced blocks with enough surrounding context
- If a finding spans multiple files, list all relevant locations
- For large reviews (>15 findings), add a one-line summary table at the top

## Step 7: Handle Large Diffs

For changes touching >20 files:
1. List all files with change stats in a summary table
2. Identify the 10-15 highest-priority files (most logic changes, most additions)
3. Deep-review those files
4. Scan remaining files for obvious issues only
5. Clearly note: "The following files were skimmed, not deep-reviewed: [list]"

## Additional Focus Areas (optional)

$ARGUMENTS

If focus areas were provided above, prioritize those areas during review. Apply them as
additional weight on top of the standard checklist — don't skip the standard checks entirely,
but spend more time and detail on the requested focus areas.
