#!/bin/bash
# Double-click launcher: runs bin/run-all.sh
exec "$(cd "$(dirname "$0")" && pwd)/bin/run-all.sh" "$@"
