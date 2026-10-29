#!/bin/sh
# Deterministic software and real GPU readback on private Linux display servers.
set -eu
root=$(cd "$(dirname "$0")/../../.." && pwd)
out=${GUI_RENDER_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
if [ "${1:-}" != --private ]; then
    (cd "$root/gui-engine-gos/rust/gui-engine"; cargo build --release --example render-check)
    { date -u; uname -a; cargo --version; } > "$out/environment.txt"
    GUI_RENDER_OUT="$out" dbus-run-session -- "$0" --private
    exit
fi
# A socket path is at most 108 bytes, so the runtime directory sits at a short
# path of its own.
runtime=$(mktemp -d /tmp/gui-render-rt.XXXXXX)
export XDG_RUNTIME_DIR="$runtime" XDG_CONFIG_HOME="$out/config" XDG_CACHE_HOME="$out/cache"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
weston --backend=headless --xwayland --socket=render-check --width=3840 --height=2160 --idle-time=0 > "$out/weston.log" 2>&1 &
server=$!
trap 'kill "$server" 2>/dev/null || :; wait "$server" 2>/dev/null || :; rm -rf "$runtime"' EXIT HUP INT TERM
export WAYLAND_DISPLAY=render-check
attempt=0
while :; do
    display=$(sed -n 's/.*xserver listening on display \(:[0-9]*\).*/\1/p' "$out/weston.log" | head -1)
    [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ] && [ -n "$display" ] && break
    attempt=$((attempt + 1))
    if [ "$attempt" -gt 100 ] || ! kill -0 "$server" 2>/dev/null; then cat "$out/weston.log" >&2;exit 1;fi
    sleep 0.1
done
export DISPLAY=$display
binary="$root/gui-engine-gos/rust/gui-engine/target/release/examples/render-check"
# Runs one measurement into NAME.csv and NAME.stderr; a failure shows why.
measure() {
    name=$1
    shift
    if ! env "$@" > "$out/$name.csv" 2> "$out/$name.stderr"; then
        echo "render-check $name failed:" >&2
        cat "$out/$name.stderr" >&2
        exit 1
    fi
}
measure software SDL_VIDEO_DRIVER=offscreen GUI_RENDERER=software "$binary"
# A forced GPU request must fail over on a driver without acceleration.
measure fallback SDL_VIDEO_DRIVER=offscreen GUI_RENDERER=gpu "$binary"
for driver in x11 wayland; do
    # The unset default must stay in software even on GPU-capable displays.
    measure "$driver-default" -u GUI_RENDERER SDL_VIDEO_DRIVER=$driver "$binary" --require-software
    measure "$driver-unknown" SDL_VIDEO_DRIVER=$driver GUI_RENDERER=unknown "$binary" --require-software
    measure "$driver-gpu" SDL_VIDEO_DRIVER=$driver GUI_RENDERER=gpu "$binary" --require-gpu
done
printf 'Rendering report: %s\n' "$out"
