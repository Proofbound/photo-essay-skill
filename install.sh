#!/usr/bin/env bash
#
# Photo Essay Skill Installer for macOS/Linux
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Proofbound/photo-essay-skill/main/install.sh | bash
#

set -e

SKILL_DIR="$HOME/.claude/skills/photo-essay"
REPO_URL="https://github.com/Proofbound/photo-essay-skill.git"
ZIP_URL="https://github.com/Proofbound/photo-essay-skill/archive/refs/heads/main.zip"

echo ""
echo "============================================"
echo "  Photo Essay Skill Installer"
echo "============================================"
echo ""
echo "This will install the Photo Essay skill for Claude Code."
echo "It turns your photos into magazine-style HTML documents."
echo ""

# -------------------------------------------
# 1. Check for Python 3
# -------------------------------------------
PYTHON_CMD=""

if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    # Make sure it's Python 3
    if python --version 2>&1 | grep -q "Python 3"; then
        PYTHON_CMD="python"
    fi
fi

if [ -z "$PYTHON_CMD" ]; then
    echo "ERROR: Python 3 is not installed."
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Install it with:"
        echo "  brew install python3"
        echo ""
        echo "Or download from https://www.python.org/downloads/"
    else
        echo "Install it with your package manager, e.g.:"
        echo "  sudo apt install python3 python3-pip"
    fi
    exit 1
fi

echo "[OK] Found $($PYTHON_CMD --version)"

# -------------------------------------------
# 2. Check for pip
# -------------------------------------------
if ! $PYTHON_CMD -m pip --version &>/dev/null; then
    echo "ERROR: pip is not available."
    echo ""
    echo "Try: $PYTHON_CMD -m ensurepip"
    exit 1
fi

echo "[OK] Found pip"

# -------------------------------------------
# 3. Check for existing install
# -------------------------------------------
if [ -f "$SKILL_DIR/skills/photo-essay/SKILL.md" ]; then
    echo ""
    echo "The skill is already installed at:"
    echo "  $SKILL_DIR"
    echo ""
    read -p "Reinstall? [y/N] " choice
    case "$choice" in
        y|Y)
            echo "Removing old installation..."
            rm -rf "$SKILL_DIR"
            ;;
        *)
            echo "Skipping download, updating dependencies..."
            SKIP_DOWNLOAD=1
            ;;
    esac
fi

# -------------------------------------------
# 4. Download the skill
# -------------------------------------------
if [ -z "$SKIP_DOWNLOAD" ]; then
    echo ""
    echo "Downloading Photo Essay skill..."

    mkdir -p "$HOME/.claude/skills"

    if command -v git &>/dev/null; then
        echo "Using git..."
        git clone "$REPO_URL" "$SKILL_DIR"
    elif command -v curl &>/dev/null; then
        echo "Git not found, downloading zip..."
        TMP_ZIP=$(mktemp /tmp/photo-essay-XXXXXX.zip)
        TMP_DIR=$(mktemp -d /tmp/photo-essay-extract-XXXXXX)

        curl -fsSL "$ZIP_URL" -o "$TMP_ZIP"
        unzip -q "$TMP_ZIP" -d "$TMP_DIR"
        mv "$TMP_DIR/photo-essay-skill-main" "$SKILL_DIR"

        rm -f "$TMP_ZIP"
        rm -rf "$TMP_DIR"
    else
        echo "ERROR: Neither git nor curl found. Install one and try again."
        exit 1
    fi

    echo "[OK] Skill downloaded to $SKILL_DIR"
fi

# -------------------------------------------
# 5. Install Python dependencies
# -------------------------------------------
echo ""
echo "Installing Python packages (Pillow, pillow-heif)..."

PIP_FLAGS=""
# Use --break-system-packages on systems that need it (PEP 668)
if $PYTHON_CMD -m pip install --dry-run Pillow 2>&1 | grep -q "externally-managed"; then
    PIP_FLAGS="--break-system-packages"
fi

$PYTHON_CMD -m pip install Pillow pillow-heif $PIP_FLAGS -q

# -------------------------------------------
# 6. Verify
# -------------------------------------------
echo ""
echo "Verifying..."

OK=1

if [ ! -f "$SKILL_DIR/skills/photo-essay/SKILL.md" ]; then
    echo "[!!] Skill files not found at expected location."
    OK=0
fi

if $PYTHON_CMD -c "from PIL import Image; print('[OK] Pillow')" 2>/dev/null; then
    :
else
    echo "[!!] Pillow package not working"
    OK=0
fi

if $PYTHON_CMD -c "import pillow_heif; print('[OK] HEIC support')" 2>/dev/null; then
    :
else
    echo "[!!] HEIC support not working (iPhone photos may not work)"
    echo "     This is optional — JPEG and PNG photos will still work."
fi

echo ""
if [ "$OK" = "1" ]; then
    echo "============================================"
    echo "  Installation complete!"
    echo "============================================"
    echo ""
    echo "Open Claude Code and say:"
    echo ""
    echo "  \"Make a photo essay from ~/Photos/my-trip\""
    echo ""
    echo "Replace the path with wherever your photos are."
else
    echo "Installation may have issues. See errors above."
fi
