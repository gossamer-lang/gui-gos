#!/bin/sh
# Orca reads the toolkit fixture on a private headless desktop: its own D-Bus
# session, Weston display with Xwayland, runtime directory and Orca settings.
set -eu
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
out=${GUI_ORCA_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
if [ "${1:-}" != --private ]; then
    for tool in orca weston Xwayland dbus-run-session gdbus script; do
        command -v "$tool" > /dev/null || { echo "orca.sh needs $tool" >&2; exit 2; }
    done
    "$GOS" build tests/toolkit-platform --out-dir "$out/bin" > "$out/build.txt"
    # The private session offers only the accessibility bus. Desktop services
    # it would otherwise start on demand (portals, gvfs) join the accessibility
    # bus without a desktop to serve, and Orca waits on their replies.
    mkdir -p "$out/services"
    service=$(for dir in /usr/local/share/dbus-1/services /usr/share/dbus-1/services; do test -f "$dir/org.a11y.Bus.service" && echo "$dir/org.a11y.Bus.service" && break; done)
    test -n "$service" || { echo "orca.sh needs the org.a11y.Bus D-Bus service (at-spi2-core)" >&2; exit 2; }
    grep -v '^SystemdService=' "$service" > "$out/services/org.a11y.Bus.service"
    cat > "$out/session.conf" <<CONF
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <type>session</type>
  <listen>unix:tmpdir=/tmp</listen>
  <auth>EXTERNAL</auth>
  <servicedir>$out/services</servicedir>
  <policy context="default"><allow send_destination="*"/><allow receive_sender="*"/><allow own="*"/></policy>
</busconfig>
CONF
    GUI_ORCA_OUT="$out" dbus-run-session --config-file="$out/session.conf" -- sh tests/toolkit-platform/orca.sh --private
    exit
fi
# A Wayland socket path must fit in 108 bytes, so the runtime directory is short.
runtime=$(mktemp -d)
chmod 700 "$runtime"
export XDG_RUNTIME_DIR="$runtime"
export XDG_CONFIG_HOME="$out/config"
export XDG_DATA_HOME="$out/data"
unset DISPLAY WAYLAND_DISPLAY
mkdir -p "$out/orca-prefs"
# Speech and braille stay off: Orca still records every utterance in its log.
printf '%s\n' '{"general": {"enableSpeech": false, "enableBraille": false}, "profiles": {"default": {"profile": ["Default", "default"], "pronunciations": {}, "keybindings": {}}}, "pronunciations": {}, "keybindings": {}}' > "$out/orca-prefs/user-settings.conf"
pids=
trap 'kill $pids 2>/dev/null || true; rm -rf "$runtime"' EXIT HUP INT TERM
weston --backend=headless --xwayland --socket=gui-orca --idle-time=0 --no-config > "$out/weston.txt" 2>&1 &
pids="$!"
await() { file=$1; pattern=$2; i=0; while ! grep -aq "$pattern" "$file" 2> /dev/null; do i=$((i + 1)); test "$i" -lt 400 || { echo "timed out waiting for '$pattern' in $file" >&2; exit 1; }; sleep 0.05; done; }
await "$out/weston.txt" "xserver listening on display"
export WAYLAND_DISPLAY=gui-orca
DISPLAY=$(sed -n 's/.*xserver listening on display \(:[0-9]*\).*/\1/p' "$out/weston.txt" | head -n 1)
export DISPLAY
address=$(gdbus call --session --dest org.a11y.Bus --object-path /org/a11y/bus --method org.a11y.Bus.GetAddress | sed "s/^('//; s/',)$//")
# Orca line-buffers its log only on a terminal, so it writes to the pty of
# `script`, which copies each line to the log as it arrives.
script -q -f -e -c "orca --debug-file=/dev/tty -u '$out/orca-prefs'" "$out/orca.log" > /dev/null 2>&1 &
pids="$pids $!"
await "$out/orca.log" "ORCA: Initialized"
GUI_ACCESSIBILITY=on SDL_VIDEO_DRIVER=x11 "$out/bin/gui-toolkit-platform" --serve > "$out/server.txt" 2> "$out/stderr.txt" &
server=$!
pids="$pids $server"
said() { await "$out/orca.log" "SPEECH OUTPUT: '$1'"; }
# Orca takes the window as active, then reads the field holding focus. It
# speaks the window's name only when the activation reaches it before it found
# the active window on its own.
await "$out/orca.log" "window:activate for \[frame: 'Toolkit integration'\]"
said "Date entry 2026-10-18."
endpoint=$(sed -n 's/^AT-SPI endpoint: //p' "$out/server.txt")
query() { object=$1; method=$2; shift 2; gdbus call --address "$address" --dest "$endpoint" --object-path "$object" --method "$method" -- "$@"; }
query /org/a11y/atspi/cache org.a11y.atspi.Cache.GetItems > "$out/cache.txt"
paths=$(tr "()[]," '\n' < "$out/cache.txt" | sed -n "s/.*'\(\/org\/a11y\/atspi\/accessible\/[a-z0-9]*\)'.*/\1/p" | sort -u)
time_path=
color_path=
stop_path=
for object in $paths; do
    id=$(query "$object" org.freedesktop.DBus.Properties.Get org.a11y.atspi.Accessible AccessibleId)
    case "$id" in *"'time'"*) time_path=$object ;; *"'pick-color'"*) color_path=$object ;; *"'integration-stop'"*) stop_path=$object ;; esac
done
test -n "$time_path" && test -n "$color_path" && test -n "$stop_path"
# Focus moved by assistive technology is read like focus moved by keyboard.
query "$time_path" org.a11y.atspi.Component.GrabFocus > /dev/null
said "Time entry 12:30:00."
query "$color_path" org.a11y.atspi.Component.GrabFocus > /dev/null
said "Choose color push button."
query "$stop_path" org.a11y.atspi.Action.DoAction 0 > "$out/close.txt"
grep -q true "$out/close.txt"
wait "$server"
grep -a "SPEECH OUTPUT" "$out/orca.log" | sed "s/.*SPEECH OUTPUT: '//; s/' {.*//" > "$out/spoken.txt"
printf 'Orca: window activation, initial focus, AT-driven focus moves and button activation were spoken (%s)\n' "$out/spoken.txt"
