---
name: user-jordan-polish
description: Finalizes edited code by polishing docs, tests, and READMEs, then committing. Use when the user asks to "polish", "finalize", or "clean up" code, or invokes /user-jordan-polish.
argument-hint: "[focus areas to prioritize, e.g. 'focus on test coverage']"
---

# Polish Script for Review

When finalizing code that has been edited in this session, polish the code by executing this pipeline:

1. Review and fix all docstrings and comments (they might be incorrect) in changed files.
2. Add or enhance docstrings for all public modules/classes/functions/methods, following the documented docstring style
for the programming language. Do the same for any private functions/methods with significant complexity that would be
served by having a docstring. Docstrings should be sufficiently informative, but also not too verbose. If appropriate,
suggest function/method renames that would make them better at self-documenting themselves.
3. Add inline comments explaining non-obvious logic.
4. Update any affected READMEs.
5. If the code being updated is of high-level importance within the repository, update any relevant README or other
Markdown (`.md`) files as necessary.
6. Generate unit tests for any new/modified functions (verify patch targets match actual imports, run tests before presenting).
7. Run all tests to confirm nothing is broken.
8. Ensure consistency with all documented standards. Look for standards in the same places as the /user-jordan-ingest-floss-project skill.
9. Repeat all steps above as necessary.
10. Write a conventional commit message summarizing all changes, and commit the final result with the generated commit
message.

After each step, briefly confirm what was done before proceeding.

## Additional Focus Areas (optional)

$ARGUMENTS

If focus areas were provided above, prioritize those areas. Otherwise, follow the full workflow.
