---
name: suggest-improvements
description: Re-read ~/.claude/CLAUDE.md and suggest improvements to it and other configuration files based on the current chat session.
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

When considering the project's agentic files: Also check for the existence of AGENTS.md, CLAUDE.md, .claude/,
.cursorrules, .cursor/rules/, .github/copilot-instructions.md, or similar **top-level** files or directories whose name
or contents suggest they provide instructions to AI coding agents. The convention is evolving — new tools may introduce
their own instruction files. Look for files/directories named after AI tools or containing phrases like "agent", "AI",
"LLM", "copilot", or "assistant" in their name. Read their contents.

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

**Step 4: Apply approved changes.** After presenting suggestions, wait for the user to approve before making edits. Apply changes using the Edit tool.
