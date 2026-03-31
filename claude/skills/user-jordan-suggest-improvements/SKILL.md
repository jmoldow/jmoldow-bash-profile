---
name: user-jordan-suggest-improvements
description: Reviews ~/.claude/CLAUDE.md and other configuration files for improvements based on the current chat session. Use after completing a task, when the user says "suggest improvements", or when lessons were learned that should be remembered.
argument-hint: "[focus areas to prioritize, e.g. 'focus on git workflow']"
---

# Suggest Improvements

Review the current chat session and suggest improvements to Claude Code configuration files.

## How to Execute

**Step 1: Re-read configuration files.** Read the following files to get their current contents:

- `~/.claude/CLAUDE.md`
- `~/.claude/settings.json`
- The project's `CLAUDE.md` (at the repo root)
- The project's `.claude/settings.json`
- The project's `.claude/settings.local.json`
- The project-specific MEMORY.md (at `~/.claude/projects/<project-dir>/memory/MEMORY.md`)

Not all of these files may exist. Skip any that don't.

Also consider any of your own skill, command, agent, or rule files that were invoked or relevant during the session (e.g. files in `~/.claude/skills/`, `~/.claude/commands/`, `~/.claude/agents/`, `~/.claude/rules/`). Do not consider the project-level equivalents under `.claude/` — those belong to the project and should not be modified.

When considering the project's agentic files: Also check for the existence of AGENTS.md, CLAUDE.md, .claude/,
.cursorrules, .cursor/rules/, .github/copilot-instructions.md, or similar **top-level** files or directories whose name
or contents suggest they provide instructions to AI coding agents. The convention is evolving — new tools may introduce
their own instruction files. Look for files/directories named after AI tools or containing phrases like "agent", "AI",
"LLM", "copilot", or "assistant" in their name. Read their contents. As before, skip skills, commands, agents, etc. that
belong to the project, but do include them if they belong to me.

**Step 2: Review the conversation.** Reflect on the current chat session and identify:

- Patterns or lessons learned that should be remembered across sessions
- Workflow friction that could be reduced with settings changes
- Rules or conventions that were discovered or reinforced
- Mistakes made during the session that a memory entry could prevent in future
- Stale or incorrect entries in existing memory/config files

Are there any generic coding/developing insights from the project's agentic files that are not specific to the project
and not specific to the particular tooling being used in the repo, that would be useful to add to my own @~/.claude/
files? From these insights, only suggest small and simple improvements: do not include complex suggestions from agents,
sub-agents, commands, skills, etc. I don't want to accidentally violate a license or copyright.

Also, are there any instructions in my own @~/.claude/CLAUDE.md file or project-specific MEMORY.md file that are hard to
understand precisely or hard to execute, that would benefit from being reworded, simplified, or clarified?

**Step 3: Suggest improvements.** For each suggestion, specify:

- Which file to change
- What to add, modify, or remove
- Why (what session experience motivates it)

Follow the rules in `~/.claude/CLAUDE.md` about what to save and what not to save in memory files. In particular, be careful about adding branch-specific information to MEMORY.md — annotate with timestamp, branch, and commit SHA if the information is specific to uncommitted changes.

When suggesting new memories to add to the project, don't suggest memories that are already recorded in one of those
referenced files, unless they are tweaks/modifications to the existing memories. If that is the case, call this out in
the memory.

However, it is okay to suggest adding new memories to ~/.claude/CLAUDE.md that might be beneficial to add to all
sessions across all projects, even if it duplicates a memory in a project-specific memory file, as long as the memory
would be relevant in other projects that use the same tools / programming language.

**Step 4: Apply approved changes.** After presenting suggestions, wait for the user to approve before making edits. Apply changes using the Edit tool.

## Additional Focus Areas (optional)

$ARGUMENTS

If focus areas were provided above, prioritize those areas in your review. Otherwise, review broadly.
