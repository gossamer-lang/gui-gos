#!/bin/sh
# Fetches the tagged dependencies (windowing-gos, gui-engine-gos) of the
# library and of every example, test and module project, so each builds
# against the released sources.
set -eu
cd "$(dirname "$0")/.."
GOS=${GOS:-gos}
for manifest in project.toml examples/*/project.toml tests/*/project.toml tests/*/*/project.toml modules/*/project.toml; do
    [ -f "$manifest" ] || continue
    dir=$(dirname "$manifest")
    echo "fetch: $dir"
    (cd "$dir" && "$GOS" fetch)
done
