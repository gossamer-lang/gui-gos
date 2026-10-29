#!/bin/sh
set -eu
export GUI_TEST_INLINE_WORK=1
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
cd tests/screenshots
if [ -n "${GUI_SCREENSHOT_REPORT:-}" ]; then
    out=$GUI_SCREENSHOT_REPORT
    keep=1
else
    out=$(mktemp -d)
    keep=0
fi
mkdir -p "$out"
out=$(cd "$out" && pwd)
work=$(mktemp -d "$out/run.XXXXXX")
export SDL_VIDEO_DRIVER=offscreen
export XDG_CONFIG_HOME="$work/config"
export XDG_CACHE_HOME="$work/cache"
# Scenes show the default desktop, so no session bus reaches a settings portal.
mkdir -m 700 "$work/runtime"
export XDG_RUNTIME_DIR="$work/runtime"
unset DBUS_SESSION_BUS_ADDRESS
run_tier() {
    tier=$1
    shift
    mkdir -p "$out/$tier"
    if "$@" golden "$out/$tier" > "$out/$tier.txt" 2>&1; then
        echo "ok    $tier"
    else
        echo "FAIL: $tier"
        cat "$out/$tier.txt"
        failed=1
    fi
}
failed=0
run_tier vm env GOS_JIT=0 "$GOS" run .
run_tier jit env GOS_JIT=1 GOSSAMER_JIT_THRESHOLD=1 "$GOS" run .
"$GOS" build . --out-dir "$work/debug"
run_tier debug "$work/debug/gui-screenshots"
"$GOS" build --release . --out-dir "$work/release"
run_tier release "$work/release/gui-screenshots"
if [ "$failed" -ne 0 ]; then
    echo "screenshots: actual images are under $out"
    exit 1
fi
[ "$keep" -eq 1 ] || rm -rf "$out"
echo 'screenshots: every scene matches its golden on all four tiers'
