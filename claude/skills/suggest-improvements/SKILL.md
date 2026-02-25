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

**Step 2: Review the conversation.** Reflect on the current chat session and identify:

- Patterns or lessons learned that should be remembered across sessions
- Workflow friction that could be reduced with settings changes
- Rules or conventions that were discovered or reinforced
- Mistakes made during the session that a memory entry could prevent in future
- Stale or incorrect entries in existing memory/config files

**Step 3: Suggest improvements.** For each suggestion, specify:

- Which file to change
- What to add, modify, or remove
- Why (what session experience motivates it)

Follow the rules in `~/.claude/CLAUDE.md` about what to save and what not to save in memory files. In particular, be careful about adding branch-specific information to MEMORY.md — annotate with timestamp, branch, and commit SHA if the information is specific to uncommitted changes.

**Step 4: Apply approved changes.** After presenting suggestions, wait for the user to approve before making edits. Apply changes using the Edit tool.
