#!/usr/bin/env bash
# GLM Toggle - CLI for switching Claude Code between GLM-5.1 (z.ai) and native Claude.
#
# Usage:
#   glm on      -> Switch to GLM-5.1 (z.ai)
#   glm off     -> Switch to native Claude
#   glm status  -> Show current mode
#   glm         -> Toggle (flip current mode)

set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
GLM_PROFILE="$CLAUDE_DIR/profiles/glm.json"
CLAUDE_PROFILE="$CLAUDE_DIR/profiles/claude.json"

if [[ ! -f "$GLM_PROFILE" ]]; then
  echo "ERROR: GLM profile not found: $GLM_PROFILE" >&2
  echo "See README.md for setup instructions." >&2
  exit 1
fi
if [[ ! -f "$CLAUDE_PROFILE" ]]; then
  echo "ERROR: Claude profile not found: $CLAUDE_PROFILE" >&2
  echo "See README.md for setup instructions." >&2
  exit 1
fi

current_mode() {
  if [[ -f "$SETTINGS" ]] && grep -q "api.z.ai" "$SETTINGS"; then
    echo "glm"
  else
    echo "claude"
  fi
}

enable_glm() {
  cp "$GLM_PROFILE" "$SETTINGS"
  echo "[OK] GLM-5.1 mode active. Restart Claude Code."
}

disable_glm() {
  cp "$CLAUDE_PROFILE" "$SETTINGS"
  echo "[OK] Native Claude mode active. Restart Claude Code."
}

ACTION="${1:-toggle}"

case "$ACTION" in
  status)
    if [[ "$(current_mode)" == "glm" ]]; then
      echo "Current mode: GLM-5.1 (z.ai)"
    else
      echo "Current mode: Native Claude"
    fi
    ;;
  on)  enable_glm ;;
  off) disable_glm ;;
  toggle)
    if [[ "$(current_mode)" == "glm" ]]; then
      disable_glm
    else
      enable_glm
    fi
    ;;
  *)
    echo "Unknown command: $ACTION" >&2
    echo "Usage: glm [on|off|status]" >&2
    exit 1
    ;;
esac
