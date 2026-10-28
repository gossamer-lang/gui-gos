#!/bin/sh
# Discover all package manifests, excluding build caches.
set -eu
cd "$(dirname "$0")"
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
# Reproducers under tests/*/reports are hashed evidence, kept as run.
find . -type d \( -name target -o -name .gos-cache -o -name .git \) -prune -o \
    -path './tests/*/reports' -prune -o -name '*.gos' -print |
while IFS= read -r source; do
    "$GOS" fmt --check "$source" > /dev/null
done
echo 'fmt: every source formatted'
find . -type d \( -name target -o -name .gos-cache -o -name .git \) -prune -o \
    -path './tests/*/reports' -prune -o -name project.toml -print |
while IFS= read -r manifest; do
    directory=$(dirname "$manifest")
    printf 'Checking %s\n' "$directory"
    (cd "$directory"; "$GOS" lint .; "$GOS" check .)
done
