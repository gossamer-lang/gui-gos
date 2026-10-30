#!/bin/bash
# Double-clicked in Finder, a .command file opens in Terminal: this one runs
# install.sh beside it and keeps the window open to show how it went.
here="$(cd "$(dirname "$0")" && pwd)"
bash "$here/install.sh"
status=$?
echo ""
read -r -p "Press Return to close this window. " _
exit "$status"
