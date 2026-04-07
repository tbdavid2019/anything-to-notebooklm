#!/bin/bash

# anything-to-notebooklm runtime installer
# Installs the upstream MCP/runtime pieces this rewritten skill depends on.

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SKILL_DIR/wexin-read-mcp"
VENV_DIR="$SKILL_DIR/.venv"
VENV_PYTHON="$VENV_DIR/bin/python"
VENV_PIP="$VENV_DIR/bin/pip"
VENV_PLAYWRIGHT="$VENV_DIR/bin/playwright"
VENV_NOTEBOOKLM="$VENV_DIR/bin/notebooklm"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Anything to NotebookLM Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}[1/6] Checking Python...${NC}"
if ! command -v python3 >/dev/null 2>&1; then
  echo -e "${RED}❌ Python 3.9+ is required${NC}"
  exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_VERSION="3.9"
if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
  echo -e "${RED}❌ Python $PYTHON_VERSION detected, need 3.9+${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Python $PYTHON_VERSION${NC}"

echo ""
echo -e "${YELLOW}[1.5/6] Creating local virtualenv...${NC}"
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi
"$VENV_PIP" install --upgrade pip setuptools wheel
echo -e "${GREEN}✅ Virtualenv ready: $VENV_DIR${NC}"

echo ""
echo -e "${YELLOW}[2/6] Installing WeChat MCP runtime...${NC}"
if [ -d "$MCP_DIR" ]; then
  echo -e "${GREEN}✅ wexin-read-mcp already present${NC}"
else
  git clone https://github.com/Bwkyd/wexin-read-mcp.git "$MCP_DIR"
  echo -e "${GREEN}✅ wexin-read-mcp cloned${NC}"
fi

echo ""
echo -e "${YELLOW}[3/6] Installing Python dependencies...${NC}"
if [ -f "$MCP_DIR/requirements.txt" ]; then
  "$VENV_PIP" install -r "$MCP_DIR/requirements.txt"
fi
"$VENV_PIP" install -r "$SKILL_DIR/requirements.txt"
echo -e "${GREEN}✅ Python dependencies installed${NC}"

echo ""
echo -e "${YELLOW}[4/6] Installing Chromium for Playwright...${NC}"
"$VENV_PYTHON" -c "from playwright.sync_api import sync_playwright" >/dev/null 2>&1
"$VENV_PLAYWRIGHT" install chromium
echo -e "${GREEN}✅ Chromium installed${NC}"

echo ""
echo -e "${YELLOW}[5/6] Installing NotebookLM CLI...${NC}"
if [ -x "$VENV_NOTEBOOKLM" ]; then
  echo -e "${GREEN}✅ notebooklm already available in virtualenv${NC}"
else
  if "$VENV_PIP" install "notebooklm-py[browser]"; then
    :
  else
    "$VENV_PIP" install git+https://github.com/teng-lin/notebooklm-py.git
  fi
fi

if [ ! -x "$VENV_NOTEBOOKLM" ]; then
  echo -e "${RED}❌ notebooklm install failed${NC}"
  exit 1
fi
echo -e "${GREEN}✅ notebooklm installed: $VENV_NOTEBOOKLM${NC}"

echo ""
echo -e "${YELLOW}[6/6] Next steps...${NC}"
echo "1. Add this MCP entry to ~/.claude/config.json:"
echo ""
echo "   \"weixin-reader\": {"
echo "     \"command\": \"$VENV_PYTHON\","
echo "     \"args\": [\"$MCP_DIR/src/server.py\"]"
echo "   }"
echo ""
echo "2. Restart Claude Code"
echo "3. Run: $VENV_NOTEBOOKLM login"
echo "4. Optionally verify with: ./check_env.py"
echo ""
echo "NotebookLM CLI path: $VENV_NOTEBOOKLM"
echo -e "${GREEN}✅ Install complete${NC}"
