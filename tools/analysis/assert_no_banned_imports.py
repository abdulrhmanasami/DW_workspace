#!/usr/bin/env python3

import json, re, sys, pathlib, os

ROOT = pathlib.Path(__file__).resolve().parents[2]

CLEAN_ROOT = pathlib.Path(
    os.environ.get("CLEAN_B_ROOT", str(ROOT))
).resolve()
APP  = CLEAN_ROOT / "lib"

CFG  = ROOT / "tools" / "reports" / "banned_import_patterns.json"

def main():
    config = json.loads(CFG.read_text(encoding="utf-8"))
    allow_patterns = [re.compile(p) for p in config.get("allow", [])]
    deny_patterns = [re.compile(p) for p in config.get("deny", [])]

    bad = []
    for p in APP.rglob("*.dart"):
        txt = p.read_text(encoding="utf-8", errors="ignore")
        for m in re.finditer(r"^\s*import\s+['\"]([^'\"]+)['\"][^;]*;", txt, flags=re.M):
            uri = m.group(1)

            # Check if this import matches any deny pattern
            denied = any(rx.match(f"{p.relative_to(ROOT)}:{uri}") for rx in deny_patterns)

            # If denied, check if it's explicitly allowed
            if denied:
                allowed = any(rx.match(uri) for rx in allow_patterns)
                if not allowed:
                    bad.append((str(p.relative_to(ROOT)), uri))

    if bad:
        print("BANNED IMPORTS FOUND:")
        for path, uri in bad:
            print(f"- {path}: {uri}")
        sys.exit(1)
    target_display = APP
    try:
        target_display = APP.relative_to(ROOT)
    except ValueError:
        pass
    print(f"✅ No banned imports in {target_display}")

if __name__ == "__main__":
    main()