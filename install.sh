#!/bin/bash
# Install the photo-essay skill for Claude Code
set -e

SKILL_DIR="$HOME/.claude/skills/photo-essay"

if [ -d "$SKILL_DIR" ]; then
  echo "Updating existing installation..."
  cd "$SKILL_DIR" && git pull
else
  echo "Installing photo-essay skill..."
  git clone https://github.com/Proofbound/photo-essay-skill.git "$SKILL_DIR"
fi

echo "Installing Python dependencies..."
pip install Pillow pillow-heif --break-system-packages -q 2>/dev/null || pip install Pillow pillow-heif -q

echo ""
echo "Photo essay skill installed! Open Claude Code and try:"
echo '  "Make a photo essay from ~/Photos/my-trip"'
