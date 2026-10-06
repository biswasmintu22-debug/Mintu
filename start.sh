#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
PROJECT_ROOT="$(pwd)"
PORT="${PORT:-3000}"
DIST_DIR="$PROJECT_ROOT/dist"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
export PROJECT_ROOT DIST_DIR WEB_DIR PORT
/usr/bin/time -p test -n "$PORT"
/usr/bin/time -p test -d "$PROJECT_ROOT"
if [ -f "$PROJECT_ROOT/package.json" ]; then
  /usr/bin/time -p npm install --no-audit --no-fund
  if /usr/bin/time -p test -f "$PROJECT_ROOT/package-lock.json"; then
    /usr/bin/time -p npm ci --no-audit --no-fund || /usr/bin/time -p npm install --no-audit --no-fund
  fi
fi
/usr/bin/time -p mkdir -p "$DIST_DIR"
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p mkdir -p "$WEB_DIR"
/usr/bin/time -p bash -c 'printf "{\"project\":\"%s\",\"directory\":\"%s\"}" "$PROJECT_ROOT" "$DIST_DIR" > "$WEB_DIR/deployment-output.json"'
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
/usr/bin/time -p bash -c 'python3 -c "import json,os; json.load(open(os.path.join(os.environ[\"WEB_DIR\"],\"deployment-output.json\"))); print(\"deployment-output.json valid\")"'
/usr/bin/time -p python3 -m http.server "$PORT" --directory "$DIST_DIR" --bind 0.0.0.0
