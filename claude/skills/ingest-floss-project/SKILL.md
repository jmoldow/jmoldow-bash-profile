---
name: ingest-floss-project
description: Respectfully ingest generic learnings from a FLOSS project's agent instruction files,
respecting its license.
---

# Ingest FLOSS Project

Onboard to a new FLOSS project workspace by identifying its status, inventorying its agent
instruction files, and extracting generic coding insights — all while respecting the project's
license.

## How to Execute

**Step 1: Identify FLOSS status.** Follow the instructions in `~/.claude/CLAUDE.md` under
"Libre / Free / Open Source (FLOSS) Projects" to determine:
- Is this a FLOSS project? (Check LICENSE, README)
- Does it accept tool-assisted contributions? (Check CONTRIBUTING, AGENTS.md, CLAUDE.md, .claude/, etc.)
- What is the user's contributor status? (Check CODEOWNERS, MAINTAINERS, workspace memory)

Report findings and ask for confirmation before recording to workspace memory.

**Step 2: Inventory agent instruction files.** Search the repo for all agent-related files:
- CLAUDE.md files (at any depth)
- .claude/ directories (settings, agents, commands, skills, rules)
- .cursor/, .cursorrules, .github/copilot-instructions.md, and similar
- Use the heuristics in `~/.claude/CLAUDE.md` FLOSS section for discovering new conventions

Summarize each file individually. Record the inventory in workspace memory, annotated with
date and base branch commit SHA, and marked as non-authoritative (the repo is the source of truth).

**Step 3: Assess contributor relevance.** For each command, skill, agent, or workflow found:
- Is it useful for an external contributor, or does it require internal tooling/access?
- Note any MCP servers, internal CLIs, or privileged tools referenced.

Record the contributor-relevant findings in workspace memory.

**Step 4: Extract generic insights.** Review the project's agent instruction files for coding
and development principles that are:
- Not specific to this project
- Not specific to the project's particular tooling
- Broadly applicable across other projects using the same language/tools

**Critical**: Do not copy text from the project. Restate insights in your own words. This
respects the project's license and ensures the learnings are genuinely generic rather than
project-specific formulations.

Present candidate insights to the user. For each, explain what inspired it and propose wording
for `~/.claude/CLAUDE.md`. Wait for approval before making any edits.

**Step 5: Create editor config files.** Create `.editorconfig` and `.lvimrc` files at the
project root to match the project's coding standards:

- `.editorconfig`: Match the project's formatter configs (e.g. ruff.toml line-length for Python,
  Prettier printWidth for JS/TS). Include sections for all relevant file types. Read `~/.vimrc`
  to understand Jordan's global editor defaults and identify which settings need overriding.
- `.lvimrc`: Override Jordan's global Vim settings (from `~/.vimrc`) to match the project.
  Include `setlocal` overrides for indent size, tab width, and textwidth per filetype.
  Override ALE buffer-local variables (`b:ale_fixers`, `b:ale_linters`) to use only the
  linters/formatters the project actually uses (e.g. only `ruff` for Python formatting if the
  project uses Ruff, not black/isort/autopep8).

These files are for local use and are rarely intended to be committed to the FLOSS project.

**Step 6: Run /suggest-improvements.** After completing the above steps, invoke the
suggest-improvements skill to catch any additional session-level improvements.

## Additional Focus Areas (optional)

$ARGUMENTS

If focus areas were provided above, prioritize those areas. Otherwise, follow the full workflow.
