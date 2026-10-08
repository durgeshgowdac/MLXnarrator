#!/bin/bash
# Double-click launcher: runs bin/generate.sh
exec "$(cd "$(dirname "$0")" && pwd)/bin/generate.sh" "$@"
