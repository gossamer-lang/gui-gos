#!/bin/sh
# Release-native budgets on the documented software/offscreen reference.
set -eu
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
out=${GUI_PERF_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
{
    date -u
    uname -a
    "$GOS" --version
    sha256sum "$(command -v "$GOS")"
    if command -v lscpu >/dev/null; then lscpu; fi
    if command -v lspci >/dev/null; then lspci; fi
    if [ -f /etc/os-release ]; then cat /etc/os-release; fi
} > "$out/environment.txt"
export SDL_VIDEO_DRIVER=offscreen
export GUI_ACCESSIBILITY=off
export XDG_CONFIG_HOME="$out/config"
export XDG_CACHE_HOME="$out/cache"
# Budgets measure the toolkit alone, so no session bus reaches desktop
# services whose replies would land inside a measured interval.
runtime=$(mktemp -d)
trap 'rm -rf "$runtime"' EXIT
chmod 700 "$runtime"
export XDG_RUNTIME_DIR="$runtime"
export DBUS_SESSION_BUS_ADDRESS=disabled:
"$GOS" build --release tests/perf --out-dir "$out/bin" > "$out/build.txt"
printf 'fixture,unit,samples,p95,p99,p95_budget,p99_budget\n' > "$out/results.csv"
status=0
for fixture in startup typing scroll picker resize idle; do
    if "$out/bin/gui-perf" "$fixture" > "$out/$fixture.csv" 2> "$out/$fixture.stderr"; then
        echo "PASS: $fixture"
    else
        echo "FAIL: $fixture" >&2
        cat "$out/$fixture.stderr" >&2
        status=1
    fi
    if ! awk -F, -v name="$fixture" 'NF != 7 || $1 != name || $3 < 1 || $4 < 0 || $5 < $4 { bad=1 } END { exit bad || NR != 1 }' "$out/$fixture.csv"; then
        echo "FAIL: missing or malformed result for $fixture" >&2
        status=1
    fi
    cat "$out/$fixture.csv" >> "$out/results.csv"
done
echo "Performance report: $out"
exit "$status"
