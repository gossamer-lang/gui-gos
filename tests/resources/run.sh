#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
out=${GUI_RESOURCE_REPORT:-$(mktemp -d /tmp/gui-resources.XXXXXX)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
work=$(mktemp -d "$out/run.XXXXXX")
export SDL_VIDEO_DRIVER=offscreen GUI_ACCESSIBILITY=off GUI_TEST_INLINE_WORK=0
export XDG_CONFIG_HOME="$work/config" XDG_CACHE_HOME="$work/cache"
GOS=${GOS:-gos}
GOS_RUN_ENGINE=vm GOS_JIT=0 "$GOS" run tests/resources > "$out/vm.txt"
GOS_RUN_ENGINE=vm GOS_JIT=1 GOS_JIT_STATS=1 GOSSAMER_JIT_THRESHOLD=1 "$GOS" run tests/resources > "$out/jit.txt" 2> "$out/jit-stats.txt"
awk '/gos-jit-stats: compiled=/ { split($0,a,"compiled="); total += a[2]+0 } END { exit total > 0 ? 0 : 1 }' "$out/jit-stats.txt"
"$GOS" build tests/resources --out-dir "$work/debug" > "$out/debug-build.txt"
"$work/debug/gui-resources" > "$out/debug.txt"
"$GOS" build --release tests/resources --out-dir "$work/release" > "$out/release-build.txt"
"$work/release/gui-resources" > "$out/release.txt"
for tier in vm jit debug release; do diff -u tests/resources/expected.txt "$out/$tier.txt"; done
printf 'Resource and background journeys agree on four tiers; report %s\n' "$out"
