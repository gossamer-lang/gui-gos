#!/bin/sh
set -eu
export GUI_TEST_INLINE_WORK=1
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
export GOS
if [ "${GUI_TOOLKIT_MEMORY:-0}" = 1 ]; then
    case "$(uname -m)" in x86_64) GOS_LLVM_MCPU=${GOS_LLVM_MCPU:-x86-64-v3}; export GOS_LLVM_MCPU ;; esac
fi
./tools/check-toolchain.sh
out=${GUI_TOOLKIT_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
export GUI_ACCESSIBILITY=off
export SDL_VIDEO_DRIVER=offscreen
export XDG_CONFIG_HOME="$out/config"
export XDG_CACHE_HOME="$out/cache"
echo "Toolkit report: $out"
GOS_JIT=0 timeout -k 5 300 "$GOS" run tests/toolkit-platform > "$out/vm.txt"
GOS_JIT=1 GOS_JIT_STATS=1 GOSSAMER_JIT_THRESHOLD=1 timeout -k 5 300 "$GOS" run tests/toolkit-platform > "$out/jit.txt" 2> "$out/jit-stats.txt"
awk '/gos-jit-stats: compiled=/ { split($0, a, "compiled="); total += a[2]+0 } END { exit total > 0 ? 0 : 1 }' "$out/jit-stats.txt"
"$GOS" build tests/toolkit-platform --out-dir "$out/debug" > "$out/debug-build.txt"
"$out/debug/gui-toolkit-platform" > "$out/debug.txt"
"$GOS" build --release --dynamic tests/toolkit-platform --out-dir "$out/release" > "$out/release-build.txt"
"$out/release/gui-toolkit-platform" > "$out/release.txt"
for tier in vm jit debug release; do diff -u tests/toolkit-platform/expected.txt "$out/$tier.txt"; done
if [ "${GUI_TOOLKIT_MEMORY:-0}" = 1 ]; then
    : "${GOS_RUNTIME_LIB:?Use a system-allocator runtime archive for Valgrind}"
    for tier in debug release; do
        GOS_RC_NO_POOL=1 timeout -k 5 300 valgrind --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=definite,indirect,possible --error-exitcode=99 --log-file="$out/$tier-valgrind.txt" "$out/$tier/gui-toolkit-platform" > "$out/$tier-memory.txt" 2> "$out/$tier-stderr.txt"
        diff -u tests/toolkit-platform/expected.txt "$out/$tier-memory.txt"
    done
fi
echo 'Toolkit fixture: all four tiers match'
