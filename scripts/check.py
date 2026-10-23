#!/usr/bin/env python3
"""Validate tern-omp-usage before a pull request.

    python scripts/check.py          # syntax, tests, CSS and manifest (no Tern needed; CI runs this)
    python scripts/check.py --tern   # also reload the plugin in your Tern and read its log

Needs the Luau CLI (luau, luau-compile) on PATH, or LUAU_DIR pointing at the folder that has them.
Download: https://github.com/luau-lang/luau/releases/latest
"""

import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLUGIN_ID = "omp-usage"
LUAU_FILES = ["window.luau", "usage.luau", "tests/usage_test.luau"]
# Tern's CSS engine rejects these and logs a style sheet error.
BAD_CSS = ["text-shadow", "margin-block", "margin-inline", "padding-block", "padding-inline"]

failures: list[str] = []


def step(name: str, ok: bool, detail: str = "") -> None:
    print(f"{'ok  ' if ok else 'FAIL'} {name}" + (f"\n     {detail}" if detail and not ok else ""))
    if not ok:
        failures.append(name)


def tool(name: str) -> str | None:
    folder = os.environ.get("LUAU_DIR")
    if folder:
        for candidate in (name, name + ".exe"):
            path = Path(folder) / candidate
            if path.exists():
                return str(path)
    return shutil.which(name)


def run(argv: list[str], **kw) -> subprocess.CompletedProcess:
    return subprocess.run(argv, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", **kw)


def check_manifest() -> None:
    text = (ROOT / "plugin.toml").read_text(encoding="utf-8")
    fields = dict(re.findall(r'^(\w+)\s*=\s*"?([^"\n]*)"?\s*$', text, re.M))
    missing = [k for k in ("schema", "id", "name", "version", "window") if k not in fields]
    step("plugin.toml has schema, id, name, version, window", not missing, f"missing: {missing}")
    step(f"plugin.toml id is {PLUGIN_ID}", fields.get("id") == PLUGIN_ID, f"id = {fields.get('id')}")
    window = fields.get("window", "")
    step("plugin.toml window file exists", bool(window) and (ROOT / window).exists(), f"window = {window}")


def check_changelog() -> None:
    text = (ROOT / "plugin.toml").read_text(encoding="utf-8")
    version = (re.search(r'^version\s*=\s*"([^"]+)"', text, re.M) or [None, ""])[1]
    log = ROOT / "CHANGELOG.md"
    notes = log.read_text(encoding="utf-8") if log.exists() else ""
    # CI publishes this section as the release notes, so a version bump without it would ship empty notes.
    step(f"CHANGELOG.md has a section for {version}", bool(re.search(rf"^## {re.escape(version)}\s*$", notes, re.M)))


def check_css() -> None:
    for name in ("window.luau",):
        text = (ROOT / name).read_text(encoding="utf-8")
        sheets = re.findall(r"tern\.css\(\s*\"[^\"]+\"\s*,\s*\[\[(.*?)\]\]", text, re.S)
        hits = [
            f"{name}: {prop}" for sheet in sheets for prop in BAD_CSS if re.search(rf"(?<![\w-]){prop}\s*:", sheet)
        ]
        step(f"{name}: CSS avoids properties Tern rejects", not hits, ", ".join(hits))


def check_luau() -> None:
    compile_bin, luau_bin = tool("luau-compile"), tool("luau")
    if not compile_bin or not luau_bin:
        step("Luau CLI found (luau, luau-compile)", False, "install it or set LUAU_DIR; see the top of this file")
        return
    res = run([compile_bin, "--null", *LUAU_FILES])
    step("Luau syntax (luau-compile --null)", res.returncode == 0, (res.stderr or res.stdout).strip())
    res = run([luau_bin, "tests/usage_test.luau"])
    step("tests/usage_test.luau", res.returncode == 0, (res.stderr or res.stdout).strip())


def tern_log() -> Path | None:
    if os.environ.get("TERN_LOG"):
        return Path(os.environ["TERN_LOG"])
    local = os.environ.get("LOCALAPPDATA")
    path = Path(local) / "Tern" / "Logs" / "tern.log" if local else None
    return path if path and path.exists() else None


def check_tern() -> None:
    if not shutil.which("tern"):
        step("tern CLI found", False, "the --tern check needs Tern installed")
        return
    log = tern_log()
    start = log.stat().st_size if log else 0
    run(["tern", "plugin", "reload"], timeout=60)
    time.sleep(15)  # the first fetch and render land a few seconds after reload
    res = run(["tern", "plugin", "list", "--json"], timeout=60)
    try:
        plugins = json.loads(res.stdout)["plugins"]
    except (ValueError, KeyError):
        step("tern plugin list --json", False, res.stdout[:300] + res.stderr[:300])
        return
    mine = next((p for p in plugins if p.get("id") == PLUGIN_ID), None)
    step(f"Tern loaded {PLUGIN_ID} (link or install it first)", mine is not None)
    if mine:
        step(f"{PLUGIN_ID} status is ready", mine.get("status") == "ready", f"status = {mine.get('status')}")
    if not log:
        print("skip Tern log not found; set TERN_LOG to read it")
        return
    with log.open(encoding="utf-8", errors="replace") as f:
        f.seek(start)
        lines = [l.rstrip() for l in f if PLUGIN_ID in l and re.search(r"\b(WARN|ERROR)\b", l)]
    step("no warnings or errors in Tern's log since reload", not lines, "\n     ".join(lines[:5]))


def main() -> int:
    check_manifest()
    check_changelog()
    check_css()
    check_luau()
    if "--tern" in sys.argv:
        check_tern()
    print(f"\n{len(failures)} failed" if failures else "\nall checks passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
