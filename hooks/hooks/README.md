# PreToolUse Hook — Block Destructive Commands

A Claude Code [pre-tool-use hook](https://code.claude.com/docs/en/hooks) that blocks dangerous bash commands before they run.

## What it blocks

- `rm -rf` / `rm --recursive` (any flag combo)
- SQL `DROP TABLE`, `TRUNCATE TABLE`
- SQL `DELETE FROM` **without** a `WHERE` clause
- `git push --force` / `git push -f`
- `mkfs.*` filesystem creation
- `dd if=... of=... bs=...` block-device overwrite

Every blocked attempt is logged to `~/.claude/hooks/blocked.log` with a UTC timestamp, the attempted command, and the project path. Normal commands pass through untouched.

## Install (2 commands)

```bash
mkdir -p ~/.claude/hooks && curl -fsSL https://raw.githubusercontent.com/1132dadf/claude-builders-bounty/1132dadf-patch-1/hooks/hooks/pre-tool-use.sh -o ~/.claude/hooks/pre-tool-use.sh
chmod +x ~/.claude/hooks/pre-tool-use.sh
```

## Test

```bash
echo '{"tool_input":{"command":"rm -rf /"}}' | ~/.claude/hooks/pre-tool-use.sh
# -> permissionDecision: deny + blocked.log entry

echo '{"tool_input":{"command":"ls -la"}}' | ~/.claude/hooks/pre-tool-use.sh
# -> exit 0 (allowed)
```
