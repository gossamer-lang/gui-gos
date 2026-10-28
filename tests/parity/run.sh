#!/bin/sh
set -eu
export GUI_TEST_INLINE_WORK=1
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
cd tests/parity
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT HUP INT TERM
export SDL_VIDEO_DRIVER=offscreen
export XDG_CONFIG_HOME="$out/config"
export XDG_CACHE_HOME="$out/cache"
GOS_JIT=0 "$GOS" run . > "$out/vm.txt"
GOS_JIT=1 GOS_JIT_STATS=1 GOSSAMER_JIT_THRESHOLD=1 "$GOS" run . > "$out/jit.txt" 2> "$out/jit-stats.txt"
awk '/gos-jit-stats: compiled=/ { split($0, a, "compiled="); total += a[2]+0 } END { exit total > 0 ? 0 : 1 }' "$out/jit-stats.txt"
"$GOS" build . --out-dir "$out/debug-bin"
"$out/debug-bin/gui-parity" > "$out/debug.txt"
"$GOS" build --release . --out-dir "$out/release-bin"
"$out/release-bin/gui-parity" > "$out/release.txt"
for tier in vm jit debug release; do
    diff -u expected.txt "$out/$tier.txt"
done
GOS_JIT=0 "$GOS" run --no-default-features . > "$out/no-default.txt"
grep -qx 'modules: probe module compiled out' "$out/no-default.txt"
echo 'parity: all four tiers match the expected transcript'
