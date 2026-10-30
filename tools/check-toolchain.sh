#!/bin/sh
# windowing-gos and gui-engine-gos come in as tagged dependencies, which
# `gos fetch` prepares; only the compiler is checked here.
set -eu
cd "$(dirname "$0")/.."
GOS=${GOS:-gos}
version=$("$GOS" --version)
require_version() {
    printf '%s\n' "$1" | awk -v minimum="$2" '
    function parts(value, out) { sub(/^v/, "", value); return split(value, out, ".") }
    { value=$NF; if (value !~ /^[0-9]+\.[0-9]+\.[0-9]+$/) exit 1;
      parts(value, actual); parts(minimum, required);
      for (i=1; i<=3; i++) { if (actual[i]+0 > required[i]+0) exit 0;
                            if (actual[i]+0 < required[i]+0) exit 1; }
      exit 0 }'
}
if ! require_version "$version" 0.75.8; then
    echo "Requires Gossamer >= 0.75.8; found $version. Set GOS to the compiler executable." >&2
    exit 1
fi
printf '%s\n' "$version"
