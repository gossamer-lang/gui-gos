#!/bin/sh
# Lists too long for the bytecode VM: built and run as release native code.
# Timings are measurements; the journey's outcome is the check.
set -eu
export GUI_TEST_INLINE_WORK=1
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
out=${GUI_SCALE_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
export XDG_CONFIG_HOME="$out/config" XDG_CACHE_HOME="$out/cache"
"$GOS" build --release tests/scale --out-dir "$out/bin" > "$out/build.txt"
SDL_VIDEO_DRIVER=offscreen XDG_CONFIG_HOME="$out/config" XDG_CACHE_HOME="$out/cache" \
    timeout -k 5 "${GUI_SCALE_TIMEOUT:-600}" "$out/bin/gui-scale" | tee "$out/journey.txt"
