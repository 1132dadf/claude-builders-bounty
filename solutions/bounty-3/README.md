# Destructive Bash command hook

Install the script at `~/.claude/hooks/block_destructive.py`, make it executable, then add a `PreToolUse` hook for the `Bash` tool to your Claude Code settings:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/block_destructive.py"
          }
        ]
      }
    ]
  }
}
```

The hook reads the standard JSON event from stdin. It emits a deny decision only when a high-risk pattern is detected; otherwise it emits no output and allows normal processing. Blocked attempts are appended to `~/.claude/hooks/blocked.log`.

Patterns include recursive forced deletion, force-push, `DROP TABLE`, `TRUNCATE`, and `DELETE FROM` statements without a `WHERE` clause. This is a defensive heuristic, not a shell parser or SQL firewall: review commands with complex quoting, aliases, variables, and nested scripts before relying on it as a security boundary. Test in a disposable repository first.
