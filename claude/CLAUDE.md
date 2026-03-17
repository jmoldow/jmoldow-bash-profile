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

When finalizing code that has been edited in this session, polish the code by executing the pipeline defined in the
/polish skill at @~/.claude/skills/polish/SKILL.md .

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
- When in a git repo, if a `Glob` or `Bash(find *)` command can be expressed instead as a `Bash(git ls-files *)`
  command, please prefer the latter, as it is faster and guaranteed to be read-only. **HOWEVER**, note that
  `git ls-files` will only return tracked files. So prefer `git ls-files` if you **know** you are looking for tracked
  files, but do not use `git ls-files` if there is a possibility that you need to discover untracked files.
- Do not run useless `cat` commands. Only use `cat` for: (a) actually concatenating two or more
  files; (b) when there is no standard alternative and Claude's Read tool isn't available; (c) if
  necessary for debugging. For reading a single file, use the Read tool. For piping file contents
  into a command, prefer shell redirection (`< file`) over `cat file |`.

## Searching for Source Files
- When searching for code, exclude virtual environment and build tool directories (.tox, .venv, venv, node_modules, build/, dist/), as they contain copies of source code and generated artifacts that pollute search results.
- When searching specifically for original source files (not generated code or build/runtime artifacts), strongly prefer `git ls-files` (for file discovery by directory/name/glob) or `git grep` (for searching file contents). These automatically exclude all untracked and gitignored directories without needing to explicitly list exclusions.
- Fall back to Glob / Search / Bash(find) / Bash(rg) / Bash(grep) when there is a possibility that you need to discover untracked files, or in other cases where you deem it necessary or beneficial to use those tools instead.

## Environment Constraints
When working with AWS CLI or cloud provider commands, remember that Claude's sandbox does not have access to live AWS credentials or cloud APIs. Generate the commands for the user to run manually instead of attempting to execute them directly.

## Context Loading and Following Agentic Instruction Files
- Start every new `claude` code chat session, as well as every `claude` code chat session resume, by reading and
  following the instructions in @AGENTS.md and all files that it references (especially if it uses @ to reference the
  file) including `*.mdc` files, and reading and following the instructions in @CLAUDE.md and all files that it
  references, and reading and following the instructions in @~/.claude/CLAUDE.md and all files that it references. List
  every file that has been read and loaded.
  - If it exists, read and follow the instructions in @AGENTS_gitignore.md and all files that it references.
  - If it exists, read and follow the instructions in @CLAUDE_gitignore.md and all files that it references.
  - If it exists, read and follow the instructions in @~/.claude/CLAUDE_gitignore.md and all files that it references.
- When asked to "ingest", "load", or "read files into context", read them and confirm readiness — do not summarize or
  analyze unless explicitly asked.
- When loading agent instruction files at session start/resume (CLAUDE.md, AGENTS.md, etc.),
  if one instruction file directs you to read and follow other instruction files but the system
  did not auto-load them, warn the user and list which referenced instruction files were not
  automatically loaded.
- Be careful about adding information to MEMORY.md that is specific to changes that aren't committed to main. This
  information is subject to change as different branches are checked out, or as details of a pending change are
  re-worked. If information does need to be added to MEMORY.md, it would be good if you recorded the timestamp, branch,
  and commit sha at that point in time, and consider re-evaluating the truth of those memories after an appropriate amount
  of time.

## Temporary files
- Write temporary files (not plans or requested work products) to `/tmp/claude/<session-id>/`
  where `<session-id>` is the Claude Code session ID (the UUID used with `claude --resume`).
- Use the `/get-session-id` skill to determine the current session ID.
- This keeps temp files organized per-session and avoids collisions across concurrent sessions.

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
- When editing code, don't prompt one line at a time for the same task. Show at least 4 changed lines per prompt, unless
  there are fewer than 4 remaining lines to change for the current task.

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
- Jordan's ~/.gitconfig has `log.follow = true`. This causes `git log --since=<date>` (with or
  without `--author`) to silently return zero results when no pathspec is given (git 2.47.1 bug).
  Always use `-c log.follow=false` when combining `--since`/`--after` with `git log` without a
  file path. Alternatively, use `--since-as-filter=<date>` instead of `--since=<date>`.
- If the working directory is already the git repo root, and `git` is being run without a Claude sandbox: — do NOT use
  `git -C /path`, just run `git` directly.
- Pager env vars are set to `cat` globally in `~/.claude/settings.json`, so there is no need to
  prefix git commands with `PAGER=cat GIT_PAGER=cat`. Just run git commands directly.
- When suggesting read-only `git` commands, prefer to use those that are pre-approved in `settings.json` instead of
  suggesting equivalents that require my approval. But if the unapproved command is significantly better, then feel free
  to suggest it, and suggest that I grant approval in @~/.claude/settings.json .

## Reading man pages and git help
- `man <page>` and `git help <cmd>` output contains backspace overstriking that breaks grep/search.
- `col -b` strips overstriking but only works on file input, not pipes.
- Working approach:
  1. `man <page> > /tmp/claude/manpage.txt 2>/dev/null`
     (or `git help <cmd> > /tmp/claude/manpage.txt 2>/dev/null`)
  2. `col -b < /tmp/claude/manpage.txt > /tmp/claude/manpage-clean.txt`
  3. Use Grep/Read tools on the clean file.

## Pager environment variables
- Common pager env vars (`PAGER`, `GIT_PAGER`, `MANPAGER`, `BAT_PAGER`, `DELTA_PAGER`,
  `SYSTEMD_PAGER`) are set to `cat` in `~/.claude/settings.json` so that commands produce
  plain output without interactive pagers.

## Programs that require caution
The following common programs can perform destructive or privileged operations.
Use them when appropriate, but be aware of the risks:
- `find` — can execute arbitrary commands via `-exec`, `-execdir`, `-ok`, `-delete`
- `env` — executes arbitrary commands with modified environment
- `xargs` — executes arbitrary commands from stdin
- `date` — can set the system clock (requires superuser)
- `tee` — writes to files (not just stdout)
- `dd` — can write to devices and files
- `tar`, `gzip`, `bzip2`, `zip`, `unzip` — can create/extract/overwrite files
- `kill`, `nice`, `renice` — process control
- `rm`, `rmdir`, `mv`, `cp`, `ln`, `chmod`, `chown` — filesystem write/destructive operations
- `ssh`, `scp`, `rsync` — network/remote access
- `curl`, `wget` — network access (denied in settings)

## Debugging and troubleshooting
- When debugging root causes, state your confidence level for each hypothesis. Do not present a
  hypothesis as the definitive cause until verified.

## Debugging with environment variables
- When a command misbehaves, it's fine to experiment with env var overrides on the command line
  to debug the issue (e.g. `ENVVAR=value command`).
- But once you're confident the problem is solvable with a consistent env var setting, suggest
  adding it to `~/.claude/settings.json` rather than relying on one-off prefixes — env var
  prefixes change the command string and can break Bash permission prefix matching.

## Pants in Claude Code Sandbox
- Pants requires `excludedCommands: ["pants"]` in settings AND unsandboxed fallback (`/sandbox`) to perform `pants run`
- The `os.chmod` on the sandboxer binary cannot be bypassed with env vars or write permissions alone

## Shared AI agent rules in referenced files
- When starting or refreshing a session, read and follow the instructions in the repo's CLAUDE.md for memories, instructions, and contexts, etc.
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
- When the project uses pants: always run `pants --no-dynamic-ui fmt fix lint` before considering changes done (run twice if first run makes changes)
- In general, always run the project's file formatters and linters before considering changes done (run twice if the first run makes changes).

## Python Exception Conventions
- `ValueError`/`TypeError` are for validating inputs, not outputs from third-party libraries
- Use `RuntimeError` for unexpected results from third-party libraries
- Don't use `assert` for runtime validation (Python may optimize out with `-O`)
- Use similar exceptions / exception hierarchies as other Python code in: this file; in sibling files; in direct child
  modules; in direct parent modules; and in direct cousin modules.
- Prefer proactive checking over exception handling for control flow (e.g., use `if key in dict` instead of catching KeyError)
- Prefer not to silently swallow exceptions, except in limited cases where it makes sense and is known to be necessary (e.g., a best-effort attempt where an exception is likely, the exception isn't important, and executing the next line of code is more important than propagating the exception)
- When exception handling is necessary for API compatibility, encapsulate it in a helper function

## Python CLI Conventions
- When writing CLIs that use the `click` library, use `click.echo()` instead of `print()` for output in the CLI layer. This ensures proper output handling, Unicode support, and testing compatibility. This applies only to the CLI layer — shared library code that may be called from non-CLI contexts should not depend on click.

## Python Package Entry Points
- When modifying CLI entry points in Python package metadata (setup.py, setup.cfg, pyproject.toml), the package must be reinstalled (e.g., `uv pip install -e .` or `pip install -e .`) for the changes to take effect.

## Immutable Data Structures
- Prefer immutable data structures with copy-on-write semantics, especially in languages where this is idiomatic (e.g., Python `@dataclass(frozen=True)`, Rust, functional languages). This reduces bugs from unintended mutation and makes code easier to reason about. However, don't be dogmatic — use mutable structures when mutability would be significantly more practical or performant.

## Libre / Free / Open Source (FLOSS) Projects
In this section, when referring to files like LICENSE, README, CONTRIBUTING, or CONTRIBUTORS, the name may be uppercase or lowercase, and may have no file extension or a plaintext extension (.md, .rst, .txt).

Identify projects that are Libre / Free / Open Source (FLOSS) Projects based on existence of a known license in a
top-level LICENSE file or an equivalent top-level file, or mention of the project's FLOSS license in a README file at
the top level or one directory down.

If you aren't sure if the project is or isn't a FLOSS project, feel free to ask. Put my answer into a memory for the
workspace.

By default, you should not generate code, documentation, or commit messages for FLOSS projects. However, it may be
acceptable to do those things, if there is indication that the repo accepts those kinds of tool-assisted contributions.
Check for any positive indicators in a README, CONTRIBUTING, or CONTRIBUTORS file at the top level, one directory down
(e.g. .github/CONTRIBUTING.md), or within a top-level docs/ directory (e.g. docs/docs/about/contributing.md). Also
check for contributing- or contributors-related directories within docs/ (e.g. docs/docs/about/contributing-docs/).
Also check for the existence of AGENTS.md, CLAUDE.md, .claude/, .cursorrules, .cursor/rules/,
.github/copilot-instructions.md, or similar top-level files or directories whose name or contents suggest they provide
instructions to AI coding agents. The convention is evolving — new tools may introduce their own instruction files. Look
for files/directories named after AI tools or containing phrases like "agent", "AI", "LLM", "copilot", or "assistant"
in their name, and read their contents to determine whether tool-assisted contributions to the project are intended (as
opposed to instructions for end-users of the tool).

When in doubt about what the project allows, feel free to ask, and I will make a judgement call. Put my answer into a
memory for the workspace.

When working in a FLOSS project, assume that I am an untrusted external contributor (no push/merge/deploy access)
unless one of the following is true: (1) I explicitly tell you otherwise, (2) I am listed by name or username
(Jordan Moldow, jmoldow) in a CODEOWNERS, MAINTAINERS, or similar file in the repo, or (3) the repo is one where
my maintainer status has been recorded in workspace memory. When acting as an untrusted contributor: do not suggest
pushing directly to the upstream repo — instead, assume a fork-based workflow where I push to my own fork and open PRs
from there (pushing to my fork is fine). Do not reference internal/private repositories or infrastructure, and follow
any contributor guidelines (e.g. fork-based workflow, PR templates, CLA requirements) documented in the project's
contributing guide.

## Dagster skills

If working on Dagster projects:

/plugin marketplace add dagster-io/skills

/plugin install dagster-expert@dagster-skills

## Jordan's Workflow Preferences
- Prefers to review batches of related edits together ("prepare all remaining changes in one patch")
- Will make their own edits directly — watch for file modification notifications and don't revert
- When asked to "reload settings and retry", re-read the settings file then retry the failed operation
- Occasionally suggest improvements to project-dir/CLAUDE.md, project-dir/.claude/settings.json,
  project-dir/.claude/settings.local.json, ~/.claude/projects/project-dir/memory/MEMORY.md, @~/.claude/CLAUDE.md, and
  @~/.claude/settings.json . Use the /suggest-improvements skill.

## Memories
- Claude Code CLI supports a global, user-specific `CLAUDE.md` file (`~/.claude/CLAUDE.md`) that is loaded automatically into every session, regardless of project.
- `~/.profile` IS sourced (via Claude Code's parent process)

### Memories - Claude Code Bash Shell Init
- Claude Code runs bash as non-interactive, non-login (`$-` = `hmtBc`, no `i`, PS1 unset)
- `~/.profile` IS sourced (via Claude Code's parent process)
- `.bashrc` early-returns (non-interactive guard) — settings there don't affect Claude Code
- The `completion-on` function in `.bash_profile` guards completion-related sourcing
