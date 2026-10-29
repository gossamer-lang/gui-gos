#!/bin/sh
# Isolated real display servers; no window or bus uses the caller's session.
set -eu
cd "$(dirname "$0")/.."
if [ "${1:-}" = --run ]; then
    ../windowing-gos/tests/smoke/target/release/windowing-smoke
    examples/widgets-showcase/target/release/gui-widgets-showcase --fixture
    examples/code-editor/target/release/gui-code-editor --fixture
    GUI_RENDERER=gpu ../gui-engine-gos/rust/gui-engine/target/release/examples/render-check --require-gpu
    if [ "$SDL_VIDEO_DRIVER" = x11 ]; then tests/toolkit-platform/atspi.sh; fi
    exit
fi
out=$(mktemp -d)
export XDG_CONFIG_HOME="$out/config" XDG_CACHE_HOME="$out/cache"
trap 'rm -rf "$out"' EXIT HUP INT TERM
case "${SDL_VIDEO_DRIVER:-}" in
    x11) sh ../windowing-gos/tools/private-bus.sh -- xvfb-run -a "$0" --run ;;
    wayland)
        export XDG_RUNTIME_DIR="$out/runtime" WAYLAND_DISPLAY=gui-test
        mkdir -m 700 "$XDG_RUNTIME_DIR"
        weston --backend=headless --socket="$WAYLAND_DISPLAY" --idle-time=0 > "$out/weston.log" 2>&1 &
        server=$!
        trap 'kill "$server" 2>/dev/null || :; wait "$server" 2>/dev/null || :; rm -rf "$out"' EXIT HUP INT TERM
        attempts=0
        until [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; do
            attempts=$((attempts + 1))
            if [ "$attempts" -ge 100 ] || ! kill -0 "$server" 2>/dev/null; then
                cat "$out/weston.log" >&2
                exit 1
            fi
            sleep 0.1
        done
        sh ../windowing-gos/tools/private-bus.sh -- "$0" --run ;;
    *) echo 'SDL_VIDEO_DRIVER must be x11 or wayland' >&2; exit 1 ;;
esac
