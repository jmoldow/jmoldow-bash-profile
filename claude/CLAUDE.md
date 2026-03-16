@AGENTS.md

Note to developers: use AGENTS.md (imported above) for general rules, and use this file
for Claude-specific rules (e.g. permissions).

If I ask you a question that you are not confident in, say "I don't know" instead of making up a false statement.

If I ask you for the answer to a question, just give me the answer. Don't go on a long diatribe.

In general, be succinct. Act like an information retrieval system, and not like we're having a friendly conversation.

When making changes, make sure to use the formatting rules that are relevant based on file pattern matches.

When referring to code in chat, always include a clickable link to the specific line in code you're referring to.

## Skills

Agents should prefer skills over raw MCP use when a skill is available.
When an agent learns something significant or awkward about an existing skill during use, it should suggest an update to the skill file to incorporate that learning.
Skills are living documents that improve through use.

## Projects

Whenever you load a project-specific rules file, make sure to say so.

## Polishing code that has been edited in this session

When finalizing code that has been edited in this session, polish the code by executing this pipeline:
1. Fix any existing docstrings or comments that might be incorrect.
2. Add or enhance docstrings for all public modules/classes/functions/methods, following the documented docstring style
for the programming language. Do the same for any private functions/methods with significant complexity that would be
served by having a docstring. Docstrings should be sufficiently informative, but also not too verbose. If appropriate,
suggest function/method renames that would make them better at self-documenting themselves.
3. Add inline comments explaining non-obvious logic.
4. If the code being updated is of high-level importance within the repository, update any relevant README or other
Markdown (`.md`) files as necessary.
5. Write a conventional commit message summarizing all changes, and commit the final result with the generated commit
message.

## Bash tool usage
- Bash permission rules (e.g. `Bash(logcli:*)`, `Bash(logcli *)`) are prefix-matched against the command string.
  - Always issue allowed commands as standalone calls starting with the binary name so the rule matches.
- Do not wrap commands in shell comments or multi-statement blocks that change what the command string starts with.
- Prefer the built-in `Glob` tool over `find` for file discovery — it is read-only and does not require a permission prompt.
- `find` can execute arbitrary commands via `-exec`, `-execdir`, `-ok`, and `-delete` flags.
  It is a useful tool when those destructive options are not used, but because of their existence
  (and potential for new destructive options in future versions), `find` is not pre-approved —
  each `find` command will be reviewed individually. It is fine to suggest using `find` (including
  with destructive options) when it is the best tool for the job — just ask for permission.
- Do not run useless `cat` commands. Only use `cat` for: (a) actually concatenating two or more
  files; (b) when there is no standard alternative and Claude's Read tool isn't available; (c) if
  necessary for debugging. For reading a single file, use the Read tool. For piping file contents
  into a command, prefer shell redirection (`< file`) over `cat file |`.

## Environment Constraints
When working with AWS CLI or cloud provider commands, remember that Claude's sandbox does not have access to live AWS credentials or cloud APIs. Generate the commands for the user to run manually instead of attempting to execute them directly.

## Context Loading
- Start every new `claude` code chat session, as well as every `claude` code chat session resume, by reading @CLAUDE.md
  and all files that it references (especially if it uses @ to reference the file), and reading @~/.claude/CLAUDE.md and
  all files that it references.
- When asked to "ingest", "load", or "read files into context", read them and confirm readiness — do not summarize or
  analyze unless explicitly asked.
- Be careful about adding information to MEMORY.md that is specific to changes that aren't committed to main. This
  information is subject to change as different branches are checked out, or as details of a pending change are
  re-worked. If information does need to be added to MEMORY.md, it would be good if you recorded the timestamp, branch,
  and commit sha at that point in time, and consider re-evaluating the truth of those memories after an appropriate amount
  of time.

## File Output Rules
Always write output files (documentation, exports, scripts) to the current project directory, never to @/tmp or other system directories unless explicitly asked.

When you wish to edit or overwrite a file outside the project working directory, first check whether it is a symlink
(using `ls -la`). If it is a symlink, ask me whether I would like to instead edit the target file, or whether I would
like to overwrite the symlink with a normal file, or whether I would like to abort. Known symlinks are listed in the
relevant sections below (e.g. bash shell customizations).

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

## git customizations

I have personal customizations to `git` in @~/.gitconfig (also available at `${XDG_CONFIG_HOME}/git/config`, aka
@~/.config/git/config). In particular, I have defined a number of helper aliases. Please learn those aliases, and
suggest using them when it would be worthwhile. In particular, I've found the merge-base related aliases to be extremely
useful.

## bash shell customizations

I have personal customizations to `bash` in @~/.profile, `~/.bash_profile`, and @~/.bashrc. In particular, I have
defined a number of helper aliases and helper functions. Please learn those aliases and functions, and suggest using
them when it would be worthwhile.
- `~/.bash_profile` is a symlink → the real file is @~/git/jmoldow/jmoldow-bash-profile/.bash_profile
- `~/.profile` is a symlink to `~/.bash_profile` (which chains to the above)
- Always edit the symlink target, never the symlink itself
- `.bashrc` early-returns (non-interactive guard) — settings there don't affect Claude Code
- The `completion-on` function in `.bash_profile` guards completion-related sourcing

## Git Diff Commands
- When asked to inspect commit contents: use `git show [<object>...]` (eg `git show HEAD`) or `git diff <commit> <commit>` (eg `git show HEAD~1 HEAD`) to inspect commit contents.
  - Do NOT use `git diff HEAD~1` (unless asked to inspect all changes since previous commit, including uncommitted
    changes) — that compares previous commit to the working tree, including uncommitted changes.
- When asked to inspect all committed changes since a particular commit: use `git diff <commit> HEAD`
  - Do NOT use `git diff <commit>` (unless asked to inspect all changes since previous commit, including uncommitted
    changes) — that compares previous commit to the working tree, including uncommitted changes.
- Consider using my merge-base related aliases from @~/.gitconfig to compute differences from a base branch.

## Other Git Commands
- If the working directory is already the git repo root, and `git` is being run without a Claude sandbox: — do NOT use
  `git -C /path`, just run `git` directly.
- For all `git` commands that might produce more than a screen of output (eg `git diff`, `git show`, `git log`, `git
  branch`, `git ls-files`, `git grep`), use `PAGER=cat GIT_PAGER=cat` environment variable overrides. In fact, it might
  be smart to always use those overrides in all bash sessions. However, if the pager is already set to `cat` / disabled
  in the parent environment, there is no need to explicitly these environment variables for every bash call.
- When suggesting read-only `git` commands, prefer to use those that are pre-approved in `settings.json` instead of
  suggesting equivalents that require my approval. But if the unapproved command is significantly better, then feel free
  to suggest it, and suggest that I grant approval in @~/.claude/settings.json .

## Pants in Claude Code Sandbox
- Pants requires `excludedCommands: ["pants"]` in settings AND unsandboxed fallback (`/sandbox`) to perform `pants run`
- The `os.chmod` on the sandboxer binary cannot be bypassed with env vars or write permissions alone

## Shared AI agent rules in referenced files
- When starting or refreshing a session, read the repo's CLAUDE.md for memories, instructions, and contexts, etc.
- Furthermore, CLAUDE.md might have references to other files or directories. If that is the case, follow those
  file/directory references, read those files, and interpret the memories, instructions, and contexts, etc. that are
  contained in those files, as if they had appeared in CLAUDE.md itself.
- When suggesting new memories to add to the project, don't suggest memories that are already recorded in one of those
  referenced files, unless they are tweaks/modifications to the existing memories. If that is the case, call this out in
  the memory.
- However, it is okay to suggest adding new memories to ~/.claude/CLAUDE.md that might be beneficial to add to all
  sessions across all projects, even if it duplicates a memory in a project-specific memory file, as long as the memory
  would be relevant in other projects that use the same tools / programming language.
- Tests: module-level functions preferred (no classes), but Jordan may keep classes — ask or follow existing pattern
- Mocking: prefer `patch.object()` over string-based `patch()`; use `spec=` or `create_autospec()` with `spec_set=True`
- Always run `pants --no-dynamic-ui fmt fix lint` before considering Python changes done (run twice if first run makes changes)

## Jordan's Workflow Preferences
- Prefers to review batches of related edits together ("prepare all remaining changes in one patch")
- Will make their own edits directly — watch for file modification notifications and don't revert
- When asked to "reload settings and retry", re-read the settings file then retry the failed operation
- Occasionally suggest improvements to project-dir/CLAUDE.md, project-dir/.claude/settings.json,
  project-dir/.claude/settings.local.json, ~/.claude/projects/project-dir/memory/MEMORY.md, @~/.claude/CLAUDE.md, and
  @~/.claude/settings.json .

## Memories
- Claude Code CLI supports a global, user-specific `CLAUDE.md` file (`~/.claude/CLAUDE.md`) that is loaded automatically into every session, regardless of project.
- `~/.profile` IS sourced (via Claude Code's parent process)

### Memories - Claude Code Bash Shell Init
- Claude Code runs bash as non-interactive, non-login (`$-` = `hmtBc`, no `i`, PS1 unset)
- `~/.profile` IS sourced (via Claude Code's parent process)
- `.bashrc` early-returns (non-interactive guard) — settings there don't affect Claude Code
- The `completion-on` function in `.bash_profile` guards completion-related sourcing
