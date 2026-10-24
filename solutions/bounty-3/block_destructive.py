#!/usr/bin/env python3
"""Claude Code PreToolUse hook that blocks high-risk Bash commands."""
from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

LOG_PATH = Path.home() / ".claude" / "hooks" / "blocked.log"
RULES = [
    ("recursive force delete", re.compile(r"\brm\b(?=[^\n]*\s-r(?:f|R)?\b)(?=[^\n]*\s-f\b)|\brm\s+-rf\b", re.I)),
    ("force push", re.compile(r"\bgit\s+push\b[^\n]*(?:--force(?:-with-lease)?|\s-f(?:\s|$))", re.I)),
    ("DROP TABLE", re.compile(r"\bDROP\s+TABLE\b", re.I)),
    ("TRUNCATE", re.compile(r"\bTRUNCATE\s+(?:TABLE\s+)?", re.I)),
    ("DELETE without WHERE", re.compile(r"\bDELETE\s+FROM\b(?:(?!\bWHERE\b).)*;?(?=$|\n|\s*(?:--|#))", re.I | re.S)),
]


def find_violation(command: str) -> str | None:
    for description, pattern in RULES:
        if pattern.search(command):
            return description
    return None


def log_block(command: str, reason: str) -> None:
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(timezone.utc).isoformat()
    # Keep a single-line, bounded record so pasted multi-line commands do not corrupt the log.
    safe_command = " ".join(command.split())[:2000]
    with LOG_PATH.open("a", encoding="utf-8") as handle:
        handle.write(f"{timestamp}\t{reason}\t{safe_command}\n")


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, UnicodeDecodeError):
        print(json.dumps({"decision": "block", "reason": "Hook input was not valid JSON."}))
        return 0

    tool_name = payload.get("tool_name", "")
    tool_input = payload.get("tool_input") or {}
    if tool_name != "Bash":
        return 0
    command = tool_input.get("command", "")
    if not isinstance(command, str):
        return 0

    reason = find_violation(command)
    if reason is None:
        return 0
    try:
        log_block(command, reason)
    except OSError:
        # Fail closed: if a destructive command is detected, logging failure must not permit it.
        pass
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": f"Blocked by destructive-command hook: {reason}. Review and run a safer command manually."
        }
    }))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
