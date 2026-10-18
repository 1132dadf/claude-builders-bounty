#!/bin/bash
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')
BLOCK="rm -rf /|sudo rm|mkfs|dd if="
if echo "$cmd" | grep -qE "$BLOCK"; then
  echo "BLOCKED: $cmd" >> ~/.claude/hooks/blocked.log
    echo '{"decision":"block","reason":"Destructive command blocked"}'
    fi
