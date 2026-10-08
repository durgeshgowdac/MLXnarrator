#!/bin/bash
# Double-click launcher: runs bin/render.sh
exec "$(cd "$(dirname "$0")" && pwd)/bin/render.sh" "$@"
