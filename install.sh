#!/usr/bin/env bash
# Installs the property-marketing-kit skill into the user's Claude Code skills dir.
set -euo pipefail
DEST="${1:-$HOME/.claude/skills/property-marketing-kit}"
SRC="$(cd "$(dirname "$0")" && pwd)"

echo "Installing property-marketing-kit skill"
echo "  from: $SRC"
echo "  to:   $DEST"
mkdir -p "$DEST"
# copy everything except git metadata and any local working output
rsync -a --exclude '.git' --exclude 'property-marketing-kits' --exclude '.DS_Store' "$SRC"/ "$DEST"/ 2>/dev/null \
  || cp -R "$SRC"/. "$DEST"/
chmod +x "$DEST"/scripts/*.sh 2>/dev/null || true
echo "Done. Restart Claude Code, then: \"Use the property-marketing-kit skill on <listing URL>.\""
