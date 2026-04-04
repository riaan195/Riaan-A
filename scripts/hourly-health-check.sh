#!/usr/bin/env bash
set -euo pipefail

echo "[health-check] verifying index.html exists and is non-empty"
test -s index.html

echo "[health-check] scanning for unresolved merge markers"
if grep -nE '^(<<<<<<<|=======|>>>>>>>)' index.html; then
  echo "[health-check] found merge conflict markers in index.html"
  exit 1
fi

echo "[health-check] verifying required UI controls"
for id in saveBtn loadBtn restartBtn upgradeBtn; do
  grep -q "id=\"$id\"" index.html
done

echo "[health-check] verifying embedded JavaScript parses"
python - <<'PY'
from pathlib import Path
import re

html = Path("index.html").read_text(encoding="utf-8")
scripts = re.findall(r"<script>([\s\S]*?)</script>", html)
if not scripts:
    raise SystemExit("No inline <script> block found in index.html")

Path("ci-inline-script.js").write_text("\n\n".join(scripts), encoding="utf-8")
PY
node --check ci-inline-script.js
rm -f ci-inline-script.js

echo "[health-check] verifying expected game actions exist"
for fn in createRequest hireEmployee nextDay; do
  grep -q "function $fn()" index.html
done

echo "[health-check] all checks passed"
