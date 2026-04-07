#!/usr/bin/env python3
"""Environment checks for the rewritten anything-to-notebooklm runtime."""

import json
import shutil
import subprocess
import sys
from pathlib import Path

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"
ROOT = Path(__file__).parent
VENV_BIN = ROOT / ".venv" / "bin"
VENV_PYTHON = VENV_BIN / "python"


def print_status(status: str, message: str) -> None:
    if status == "ok":
        print(f"{GREEN}✅ {message}{NC}")
    elif status == "warning":
        print(f"{YELLOW}⚠️ {message}{NC}")
    else:
        print(f"{RED}❌ {message}{NC}")


def check_python() -> bool:
    version = sys.version_info
    ok = version.major >= 3 and version.minor >= 9
    print_status("ok" if ok else "error", f"Python {version.major}.{version.minor}.{version.micro}")
    return ok


def check_module(module_name: str, import_name: str | None = None) -> bool:
    import_name = import_name or module_name
    commands = []
    if VENV_PYTHON.exists():
        commands.append([str(VENV_PYTHON), "-c", f"import {import_name}"])
    commands.append([sys.executable, "-c", f"import {import_name}"])

    for cmd in commands:
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        except Exception:
            continue
        if result.returncode == 0:
            location = "local virtualenv" if cmd[0] == str(VENV_PYTHON) else "current interpreter"
            print_status("ok", f"{module_name} installed ({location})")
            return True

    print_status("error", f"{module_name} missing")
    return False


def check_command(name: str) -> bool:
    local = VENV_BIN / name
    if local.exists():
        print_status("ok", f"{name} available in local virtualenv: {local}")
        return True
    if shutil.which(name):
        print_status("ok", f"{name} available")
        return True
    print_status("error", f"{name} missing")
    return False


def check_mcp_server() -> bool:
    server = Path(__file__).parent / "wexin-read-mcp" / "src" / "server.py"
    ok = server.exists()
    print_status("ok" if ok else "error", f"MCP server {'found' if ok else 'missing'}: {server}")
    return ok


def check_claude_config() -> bool:
    config_path = Path.home() / ".claude" / "config.json"
    if not config_path.exists():
        print_status("warning", f"Claude config missing: {config_path}")
        return False
    try:
        config = json.loads(config_path.read_text())
    except Exception as exc:
        print_status("error", f"Failed to read Claude config: {exc}")
        return False
    ok = "mcpServers" in config and "weixin-reader" in config["mcpServers"]
    print_status("ok" if ok else "warning", "weixin-reader MCP configured" if ok else "weixin-reader MCP not configured")
    return ok


def check_notebooklm_auth() -> bool:
    notebooklm = VENV_BIN / "notebooklm"
    if notebooklm.exists():
        cmd = [str(notebooklm), "list"]
    elif shutil.which("notebooklm"):
        cmd = ["notebooklm", "list"]
    else:
        print_status("error", "notebooklm missing")
        return False
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
    except Exception as exc:
        print_status("warning", f"NotebookLM auth check failed: {exc}")
        return False
    ok = result.returncode == 0
    print_status("ok" if ok else "warning", "NotebookLM authenticated" if ok else "NotebookLM not authenticated; run `notebooklm login`")
    return ok


def main() -> int:
    print(f"{BLUE}=== anything-to-notebooklm environment check ==={NC}")
    results = [
        check_python(),
        check_module("fastmcp"),
        check_module("playwright"),
        check_module("beautifulsoup4", "bs4"),
        check_module("lxml"),
        check_module("markitdown"),
        check_command("playwright"),
        check_command("notebooklm"),
        check_mcp_server(),
        check_claude_config(),
        check_notebooklm_auth(),
    ]
    passed = sum(results)
    total = len(results)
    print(f"{BLUE}=== {passed}/{total} checks passed ==={NC}")
    if passed != total:
        print("Fix path:")
        print("1. Run ./install.sh")
        print("2. Configure ~/.claude/config.json")
        print("3. Run notebooklm login")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
