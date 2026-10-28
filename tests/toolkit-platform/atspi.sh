#!/bin/sh
# Probe only the application launched here, on a private accessibility bus.
set -eu
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
out=${GUI_ATSPI_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
if [ "${1:-}" != --private ]; then
    if [ "${GUI_ATSPI_RELEASE:-0}" = 1 ]; then
        "$GOS" build --release --dynamic tests/toolkit-platform --out-dir "$out/bin" > "$out/build.txt"
    else
        "$GOS" build tests/toolkit-platform --out-dir "$out/bin" > "$out/build.txt"
    fi
    GUI_ATSPI_OUT="$out" dbus-run-session -- sh tests/toolkit-platform/atspi.sh --private
    exit
fi
# A socket path is at most 108 bytes, so the runtime directory sits at a short
# path of its own.
runtime=$(mktemp -d /tmp/gui-atspi-rt.XXXXXX)
export XDG_RUNTIME_DIR="$runtime"
export XDG_CONFIG_HOME="$out/config"
export GUI_ACCESSIBILITY=on
export SDL_VIDEO_DRIVER=x11
ready_limit=100
if [ "${GUI_ATSPI_MEMORY:-0}" = 1 ]; then
    : "${GOS_RUNTIME_LIB:?Use a system-allocator runtime archive for Valgrind}"
    ready_limit=600
    GOS_RC_NO_POOL=1 timeout -k 5 120 valgrind --keep-debuginfo=yes --leak-check=full --show-leak-kinds=all \
        --errors-for-leak-kinds=definite,indirect,possible --error-exitcode=99 \
        --log-file="$out/valgrind.txt" "$out/bin/gui-toolkit-platform" --serve > "$out/server.txt" 2> "$out/stderr.txt" &
else
    "$out/bin/gui-toolkit-platform" --serve > "$out/server.txt" 2> "$out/stderr.txt" &
fi
server=$!
trap 'kill "$server" 2>/dev/null || true; rm -rf "$runtime"' EXIT HUP INT TERM
i=0
while ! test -s "$out/server.txt"; do
    i=$((i + 1))
    test "$i" -lt "$ready_limit"
    sleep 0.05
done
endpoint=$(sed -n 's/^AT-SPI endpoint: //p' "$out/server.txt")
test -n "$endpoint"
address=$(gdbus call --session --dest org.a11y.Bus --object-path /org/a11y/bus --method org.a11y.Bus.GetAddress | sed "s/^('//; s/',)$//")
query() { object=$1; method=$2; shift 2; gdbus call --address "$address" --dest "$endpoint" --object-path "$object" --method "$method" -- "$@"; }
query /org/a11y/atspi/cache org.a11y.atspi.Cache.GetItems > "$out/cache.txt"
paths=$(tr "()[]," '\n' < "$out/cache.txt" | sed -n "s/.*'\(\/org\/a11y\/atspi\/accessible\/[a-z0-9]*\)'.*/\1/p" | sort -u)
time_path=
stop_path=
for object in $paths; do
    id=$(query "$object" org.freedesktop.DBus.Properties.Get org.a11y.atspi.Accessible AccessibleId)
    case "$id" in *"'time'"*) time_path=$object ;; *"'integration-stop'"*) stop_path=$object ;; esac
    if [ -n "$time_path" ] && [ -n "$stop_path" ]; then break; fi
done
test -n "$time_path"
test -n "$stop_path"
gdbus introspect --address "$address" --dest "$endpoint" --object-path "$time_path" --xml > "$out/introspection.xml"
query "$time_path" org.a11y.atspi.Component.GetMDIZOrder > "$out/mdi-z-order.txt"
query /org/a11y/atspi/accessible/root org.freedesktop.DBus.Properties.Get org.a11y.atspi.Application AtspiVersion > "$out/atspi-version.txt"
python3 - "$out" <<'PY'
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
out = Path(sys.argv[1])
root = ET.parse(out / 'introspection.xml').getroot()
interfaces = {node.attrib['name']: node for node in root.findall('interface')}
assert 'org.a11y.atspi.Text' in interfaces
assert 'org.a11y.atspi.EditableText' in interfaces
component = interfaces['org.a11y.atspi.Component']
order = component.find("method[@name='GetMDIZOrder']")
assert [(arg.attrib['direction'], arg.attrib['type']) for arg in order.findall('arg')] == [('out', 'n')]
text = interfaces['org.a11y.atspi.Text'].find("method[@name='GetText']")
assert [(arg.attrib['direction'], arg.attrib['type']) for arg in text.findall('arg')] == [('in', 'i'), ('in', 'i'), ('out', 's')]
assert 'int16 0' in (out / 'mdi-z-order.txt').read_text()
assert '2.1' in (out / 'atspi-version.txt').read_text()
PY
query "$time_path" org.a11y.atspi.Text.GetText 0 -1 > "$out/text-before.txt"
query "$time_path" org.a11y.atspi.EditableText.SetTextContents 14:20 > "$out/edit.txt"
i=0
while :; do
    query "$time_path" org.a11y.atspi.Text.GetText 0 -1 > "$out/text-after.txt"
    if grep -q '14:20:00' "$out/text-after.txt"; then break; fi
    i=$((i + 1)); test "$i" -lt 30; sleep 0.05
done
query "$stop_path" org.a11y.atspi.Action.DoAction 0 > "$out/close.txt"
grep -q true "$out/close.txt"
wait "$server"
trap - EXIT HUP INT TERM
rm -rf "$runtime"
printf 'AT-SPI: introspection, wire types, cache discovery, text query, UI-thread edit, button activation and graceful disconnect passed\n'
