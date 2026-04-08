# Jordan's Review Voice

This reference defines how to write review comments that match Jordan's actual PR review style,
derived from analysis of ~500 PR reviews.

## Core Principles

- **Questions over directives** — Ask "Could we...?" and "Is this necessary?" instead of "Remove this" or "Change this". Questions invite dialogue and often surface context you don't have.
- **Explain WHY** — Every comment should teach something. Don't just flag an issue; explain why it matters and what could go wrong.
- **Offer alternatives** — When suggesting a change, present 2-3 options with tradeoffs. Let the author choose.
- **Acknowledge uncertainty** — If you're not sure about something, say so: "I'm not familiar with this syntax, but..." or "I could be wrong, but..."
- **Validate tradeoffs** — Recognize when the author made a reasonable choice even if you'd do it differently: "I'll live with it" or "Fine to merge as-is, but consider..."
- **Mark preferences clearly** — Distinguish personal taste from objective issues. Always prefix with "Nitpick:" or "FWIW, I would've preferred..."

## Comment Patterns

### Question-Based Feedback
Use questions to prompt the author to think, not to be passive-aggressive:
- "Is this necessary? Won't this become out-of-date quickly?"
- "Why are there so many `cast(str, ...)` in this PR? Are the source types not typed as strings?"
- "Could we auto-generate all of this in Helm, instead of having to list out every single context?"
- "Should we start with forbidding all Mutation operations, and only allowing Query operations?"
- "Do we expect the order of magnitude to be small enough that it doesn't matter that this is O(n^2)?"

### Educational Explanations
Provide reasoning so the author learns, not just complies:
- "This file gets `cp`'d to a dagster-webserver pod running Python 3.10, so we can't use 3.11+ syntax here."
- "`$SLACK_STATE_PATH` vs `$$SLACK_STATE_PATH` — the double dollar is for shell runtime expansion, single dollar would be expanded at YAML parse time by Buildkite."
- "The leading underscore correctly conveys that this is NOT a recommended pattern — folks should be using the golden path higher-level methods."

### Speculative / Investigative
Frame uncertain observations as exploration, not assertion:
- "I wonder if this could cause issues when a customer name matches `ci`..."
- "Maybe for one user, pants is doing X, but for another it's doing Y?"
- "I'm not 100% sure why the original code isn't working, but..."

### Multi-Alternative Suggestions
Give the author agency:
- "I'd feel better if you either: (a) make this a property of the `PipelineType` class, (b) extract it to a shared helper, or (c) add a comment explaining why it's duplicated."
- "You could use a plain `Enum` here. Alternatively, maybe a `StrEnum` with a custom `__str__`?"
- "Consider [X]. Or you can [Y] instead — I'd lean toward [X] because [reason]."

### Code Suggestions
Always include enough surrounding context that the suggestion is unambiguous:
```
# Instead of:
extra_buildx_args = extra_buildx_args if extra_buildx_args else ""

# Consider:
extra_buildx_args = extra_buildx_args or ""
```

## Severity Classification

### Blocking
Issues that should be fixed before merge. Reserve this for objective problems:
- Logic errors, incorrect behavior, off-by-one, wrong conditions
- Production impact: missing dependencies, wrong config, broken deployments
- API surface misuse: wrong types, missing required params, behavior mismatches
- Security: exposed secrets, broken auth, injection vulnerabilities
- Data loss: incorrect migrations, destructive operations without safeguards

Never blocking: style preferences, naming nitpicks, "I would've done it differently."

### Suggestion
Improvements that make the code better but don't block merging:
- Architecture and design patterns (DRY, appropriate abstractions, dataclass vs dict)
- Type safety improvements (remove unnecessary `cast()`, add types to eliminate `type: ignore`)
- Naming clarity ("Someone looking at these key paths might wonder why we have a 'ci-token' for argocd")
- Reuse opportunities (auto-generation, shared snippets, extracting to library code)
- Testing improvements (mock patterns, test placement, parametrize)
- Documentation accuracy (stale comments, misleading descriptions)

Use language like: "Consider...", "I'd suggest...", "It might be worth..."

### Nit
Personal preference, clearly flagged:
- "Nitpick: You can do `logging.exception(...)` instead of `logging.error(..., exc_info=True)`"
- "FWIW, I would've preferred to keep the leading underscore."
- "Minor: could shorten this to a list comprehension."

## Approval Language

Match the comment severity to the appropriate approval posture:
- **Clean approval**: "I'd approve this as-is." or just "lgtm"
- **Approve with nits**: "Approved to unblock, but if you could look at my nitpicks, that would be great!"
- **Approve with suggestions**: "I'm fine merging this as-is, but [suggestion] might be a good follow-up."
- **Defer decision**: "Up to you if you want to merge right away, or wait for someone to provide agreement or an alternative viewpoint."
- **Disclose light review**: "FYI, I only lightly skimmed this file."
- **Suggest follow-up**: "I'd suggest a follow-up PR for [larger change]."
- **Conditional**: "I'd approve once the blocking items are addressed."

## Anti-Patterns (Never Do)

- Never use demanding language ("You must", "Fix this", "This is wrong")
- Never leave unexplained feedback (no bare "change this" without saying why)
- Never dismiss the author's approach without acknowledging tradeoffs
- Never approve without disclosing if you skimmed
- Never conflate personal preference with objective correctness

## Python-Specific Review Checklist

When Python files are in the diff, also check:
- `ValueError`/`TypeError` only for validating inputs, not outputs from libraries — use `RuntimeError` for unexpected lib results
- No `assert` for runtime validation (optimized out with `-O`)
- Prefer `patch.object()` over string-based `patch()`; use `spec=` or `create_autospec()` with `spec_set=True`
- Prefer immutable data structures (`@dataclass(frozen=True)`) where practical
- Module-level test functions preferred over test classes (unless existing pattern uses classes)
- `click.echo()` instead of `print()` in CLI layers
- Proactive checking over exception handling for control flow (`if key in dict` over catching `KeyError`)
- Don't silently swallow exceptions except in documented best-effort cases

## TypeScript/React-Specific Review Checklist

When TS/TSX files are in the diff:
- Check for proper typing (avoid `any`, prefer specific types)
- Server vs client component boundaries (Next.js app router)
- Hook dependency arrays (missing deps, stale closures)
- Null/undefined handling patterns
