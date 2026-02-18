## Environment Constraints
When working with AWS CLI or cloud provider commands, remember that Claude's sandbox does not have access to live AWS credentials or cloud APIs. Generate the commands for the user to run manually instead of attempting to execute them directly.

## File Output Rules
Always write output files (documentation, exports, scripts) to the current project directory, never to /tmp or other system directories unless explicitly asked.

## Output Expectations
When asked to export or reproduce conversation history, provide the full content as requested—do not summarize or truncate unless the user explicitly asks for a summary.

## Working with Claude Code Plans

- For complex multi-step tasks: Start with a complete plan before execution (use EnterPlanMode)
- For well-scoped tasks: Move directly to execution without extended planning overhead
- Always check if a plan is needed before starting — not every task requires full plan mode
- When executing plans: Provide step-by-step summaries periodically to stay oriented (especially after long sessions)

## Claude Code Sandboxing Constraints

- Claude Code runs sandboxed without access to live credentials (AWS, GitHub, etc.)
- For any cloud/API operations: Generate commands for manual execution rather than attempting direct API calls
- When asking for exports or full content, specify the exact format and location.

## Known Friction Patterns

- Claude may hallucinate commands that don't exist in your environment — correct immediately and document in CLAUDE.md
- Claude may write files to wrong locations — always specify exact output path upfront
- Claude may attempt direct API/CLI execution despite sandboxing — ask for command generation instead

## AWS CLI Usage in Claude Code

- Use `AWS_PROFILE=profile-name` environment variable instead of custom shells/wrappers
- Always include `--profile profile-name` flag in AWS CLI commands for explicit clarity
- Example: `AWS_PROFILE=eq-stage aws ssm get-parameter --name '/path' --profile eq-stage`

## Memories
- Claude Code CLI supports a global, user-specific `CLAUDE.md` file (`~/.claude/CLAUDE.md`) that is loaded automatically into every session, regardless of project.
