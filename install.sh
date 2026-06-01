#!/usr/bin/env bash
# Connect the DevMatrix Workshop MCP server to your Claude Code.
#
# Prereqs:
#   - Claude Code installed (https://claude.com/claude-code)
#   - A Workshop API key from the DevMatrix Workshop UI
#     (Settings → API Keys → "Workshop key", pick platform(s) + read/write)
#
# Usage:
#   ./install.sh <dm_live_… Workshop key> [mcp-url]
#     mcp-url defaults to https://mcp.devmatrix.dev/mcp
#     dev (QA):   https://mcp-dev.devmatrix.dev/mcp
#     local:      http://localhost:8090/mcp
set -euo pipefail

KEY="${1:-}"
URL="${2:-https://mcp.devmatrix.dev/mcp}"
NAME="dmx"

if [ -z "$KEY" ]; then
  echo "Usage: ./install.sh <dm_live_… Workshop key> [mcp-url]" >&2
  exit 2
fi
if ! command -v claude >/dev/null 2>&1; then
  echo "❌ 'claude' CLI not found. Install Claude Code first:" >&2
  echo "   https://claude.com/claude-code" >&2
  exit 1
fi
case "$KEY" in
  dm_live_*) ;;
  *) echo "❌ That doesn't look like a Workshop key (expected dm_live_…)." >&2
     echo "   Create one in the Workshop: Settings → API Keys → Workshop key." >&2
     exit 2 ;;
esac

# Idempotent: drop any existing 'dmx' registration before re-adding, so
# re-running with a new key or URL never errors on a duplicate name.
if claude mcp list 2>/dev/null | grep -q "^${NAME}\b"; then
  echo "ℹ️  Replacing existing '${NAME}' MCP registration…"
  claude mcp remove "$NAME" >/dev/null 2>&1 || true
fi

claude mcp add --transport http "$NAME" "$URL" \
  --header "Authorization: Bearer ${KEY}"

echo "✅ Connected DevMatrix Workshop MCP '${NAME}' at ${URL}"
echo "   Verify:  claude mcp list"
echo "   Tools:   list_platforms · list_specs · get_spec (.dmx) · list_wiki ·"
echo "            get_wiki (.md) · validate_spec · save_spec · upload_wiki"
echo "   Remove:  claude mcp remove ${NAME}"
