#!/bin/bash
# Double-click launcher: runs bin/render-no-subs.sh
exec "$(cd "$(dirname "$0")" && pwd)/bin/render-no-subs.sh" "$@"
