#!/usr/bin/env bash
# PreToolUse hook for Claude Code — blocks destructive bash commands.
# Target dir: ~/.claude/hooks/pre-tool-use.sh
# See: https://code.claude.com/docs/en/hooks
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"jq is required but not installed"}}'
  exit 0
fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

LOG_DIR="${HOME}/.claude/hooks"
LOG_FILE="${LOG_DIR}/blocked.log"
mkdir -p "$LOG_DIR"

BLOCKED_PATTERNS=(
  'rm\s+-[a-zA-Z]*r[a-zA-Z]*f'            # rm -rf / rm -r -f (any flag combo)
  'rm\s+--recursive'                       # rm --recursive
  'DROP\s+TABLE'                           # SQL DROP TABLE
  'git\s+push\s+--force'                   # git push --force
  'git\s+push\s+-f\b'                      # git push -f
  'TRUNCATE\s+TABLE'                       # SQL TRUNCATE TABLE
  'mkfs\.[a-z0-9]+'                        # mkfs.* filesystem creation
  'dd\s+if=.*of=.*bs='                     # dd block device overwrite
  'sudo\s+rm\s+-rf'                        # sudo rm -rf
)
BLOCKED_REASONS=(
  "Recursive force delete (rm -rf) blocked"
  "Recursive delete (rm --recursive) blocked"
  "SQL DROP TABLE blocked"
  "Git force push (git push --force) blocked"
  "Git force push (git push -f) blocked"
  "SQL TRUNCATE TABLE blocked"
  "Filesystem creation (mkfs) blocked"
  "Block device overwrite (dd) blocked"
  "Privileged recursive delete (sudo rm -rf) blocked"
)

# DELETE FROM without WHERE
if echo "$COMMAND" | grep -qiE 'DELETE\s+FROM' && ! echo "$COMMAND" | grep -qiE 'WHERE'; then
  REASON="SQL DELETE FROM without WHERE blocked"
  TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  PWD_PATH=$(pwd 2>/dev/null || echo "unknown")
  printf '%s\t%s\t%s\t%s\n' "$TS" "$COMMAND" "$PWD_PATH" "$REASON" >> "$LOG_FILE"
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"$REASON\"}}"
  exit 0
fi

for i in "${!BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "${BLOCKED_PATTERNS[$i]}"; then
    REASON="${BLOCKED_REASONS[$i]}"
    TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    PWD_PATH=$(pwd 2>/dev/null || echo "unknown")
    printf '%s\t%s\t%s\t%s\n' "$TS" "$COMMAND" "$PWD_PATH" "$REASON" >> "$LOG_FILE"
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"$REASON\"}}"
    exit 0
  fi
done

# Normal commands pass through untouched
exit 0
