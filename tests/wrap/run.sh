#!/bin/sh
set -eu
export GUI_TEST_INLINE_WORK=1
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
report=${GUI_WRAP_REPORT:-$(mktemp -d)}
mkdir -p "$report"
report=$(cd "$report" && pwd)
work=$(mktemp -d "$report/run.XXXXXX")
export SDL_VIDEO_DRIVER=offscreen GUI_ACCESSIBILITY=off
export XDG_CONFIG_HOME="$work/config" XDG_CACHE_HOME="$work/cache"
GOS_RUN_ENGINE=vm GOS_JIT=0 "$GOS" run tests/wrap > "$report/vm.txt"
GOS_RUN_ENGINE=vm GOS_JIT=1 GOS_JIT_STATS=1 GOSSAMER_JIT_THRESHOLD=1 "$GOS" run tests/wrap > "$report/jit.txt" 2> "$report/jit-stats.txt"
awk '/gos-jit-stats: compiled=/ { split($0, a, "compiled="); total += a[2]+0 } END { exit total > 0 ? 0 : 1 }' "$report/jit-stats.txt"
"$GOS" build tests/wrap --out-dir "$work/debug" > "$report/debug-build.txt"
"$work/debug/gui-wrap" > "$report/debug.txt"
"$GOS" build --release tests/wrap --out-dir "$work/release" > "$report/release-build.txt"
"$work/release/gui-wrap" > "$report/release.txt"
for tier in vm jit debug release; do
    diff -u tests/wrap/expected.txt "$report/$tier.txt"
done
printf 'wrap journeys: all four tiers match; report %s\n' "$report"
