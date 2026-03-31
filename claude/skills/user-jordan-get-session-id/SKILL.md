---
name: user-jordan-get-session-id
description: Determine the current Claude Code session ID (UUID) for use with `claude --resume` or for organizing temp files.
---

# Get Session ID

Determine the current Claude Code session ID by outputting a unique marker string and searching for it in recent session log files.

## How to Execute

**Step 1: Generate a unique marker.**

Output a random UUID in chat. For example:

> Session probe marker: `a1b2c3d4-probe-5e6f-7a8b-9c0d1e2f3a4b`

The marker just needs to be unique enough to not appear in other sessions. Use a different UUID each time.

**Step 2: Search recent session logs.**

Run the following command, substituting the marker and the correct project directory:

```bash
ls -t ~/.claude/projects/<project-dir>/*.jsonl | head -n20 | xargs grep -l "<marker-uuid>"
```

The project directory is derived from the working directory path with `/` replaced by `-` and prefixed with `-`. For example, `/Users/jordan/git/eq/helios` becomes `-Users-jordan-git-eq-helios`.

**Step 3: Extract the session ID.**

The matching filename without the `.jsonl` extension is the session ID. For example:
`/Users/jordan/.claude/projects/-Users-jordan-git-eq-helios/04a7d646-2152-400a-b7b2-4741c91d9724.jsonl`
→ session ID: `04a7d646-2152-400a-b7b2-4741c91d9724`

**Step 4: Report the result.**

Tell the user the session ID and note that it can be used with:
- `claude --resume <session-id>`
- Temp file directory: `/tmp/claude/<session-id>/`
