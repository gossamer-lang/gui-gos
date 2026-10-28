#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
violations=$(find src examples tools -type d \( -name target -o -name .gos-cache \) -prune -o -type f \( -name '*.rs' -o -name '*.c' -o -name '*.cpp' -o -name '*.py' -o -name '*.js' \) -print)
if [ -n "$violations" ]; then
    echo 'Non-Gossamer implementation/generator sources remain:' >&2
    printf '%s\n' "$violations" >&2
    exit 1
fi
printf 'source-policy: clean\n'
