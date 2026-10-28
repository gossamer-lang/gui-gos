#!/bin/sh
# Runs every resource journey per tier at two lengths. Live objects at exit
# (the runtime's leak ledger) must match between the two lengths, and open
# descriptors must not grow after warmup. RSS is recorded, not gated: the
# allocator's retained pages make exact equality meaningless.
set -eu
export GUI_TEST_INLINE_WORK=1
cd "$(dirname "$0")"
GOS=${GOS:-gos}
export GOS
../../../tools/check-toolchain.sh
out=${GUI_JOURNEY_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
echo "Journey report: $out"
short=${GUI_JOURNEY_SHORT:-40}
long=$((short * 4))
tiers=${GUI_JOURNEY_TIERS:-vm jit debug release}
journeys=${GUI_JOURNEYS:-windows popups tabs editor}
export SDL_VIDEO_DRIVER=offscreen
export XDG_CONFIG_HOME="$out/config"
export XDG_CACHE_HOME="$out/cache"
export GOS_LEAK_LEDGER=1
limit=${GUI_JOURNEY_TIMEOUT:-900}
status=0
run() {
    tier=$1
    shift
    case "$tier" in
        vm) GOS_JIT=0 timeout -k 5 "$limit" "$GOS" run . "$@" ;;
        jit) GOS_JIT=1 GOSSAMER_JIT_THRESHOLD=1 timeout -k 5 "$limit" "$GOS" run . "$@" ;;
        *) timeout -k 5 "$limit" "$out/bin/$tier/gui-memory-journeys" "$@" ;;
    esac
}
printf 'tier,journey,iterations,warm_rss_kib,end_rss_kib,warm_fds,end_fds,ledger\n' > "$out/summary.csv"
for tier in $tiers; do
    case "$tier" in
        debug) "$GOS" build . --out-dir "$out/bin/debug" > "$out/debug-build.txt" ;;
        release) "$GOS" build --release . --out-dir "$out/bin/release" > "$out/release-build.txt" ;;
    esac
    for journey in $journeys; do
        for n in "$short" "$long"; do
            base="$out/$tier-$journey-$n"
            if ! run "$tier" "$journey" "$n" > "$base.txt" 2> "$base.err"; then
                echo "FAIL: $tier $journey $n did not finish (see $base.err)" >&2
                status=1
                continue
            fi
            warm=$(grep ",warm," "$base.txt")
            end=$(grep ",end," "$base.txt")
            ledger=$(sed -n 's/^LEAK LEDGER (live at exit): //p' "$base.err")
            printf '%s,%s,%s,%s,%s,%s,%s,%s\n' "$tier" "$journey" "$n" \
                "$(echo "$warm" | cut -d, -f4)" "$(echo "$end" | cut -d, -f4)" \
                "$(echo "$warm" | cut -d, -f5)" "$(echo "$end" | cut -d, -f5)" "$ledger" >> "$out/summary.csv"
            if [ "$(echo "$warm" | cut -d, -f5)" != "$(echo "$end" | cut -d, -f5)" ]; then
                echo "FAIL: $tier $journey $n: open descriptors grew after warmup" >&2
                status=1
            fi
        done
        a=$(awk -F, -v t="$tier" -v j="$journey" -v n="$short" '$1 == t && $2 == j && $3 == n { print $8 }' "$out/summary.csv")
        b=$(awk -F, -v t="$tier" -v j="$journey" -v n="$long" '$1 == t && $2 == j && $3 == n { print $8 }' "$out/summary.csv")
        if [ -z "$a" ] || [ "$a" != "$b" ]; then
            echo "FAIL: $tier $journey: live objects at exit differ between $short and $long iterations: [$a] [$b]" >&2
            status=1
        else
            echo "ok    $tier $journey: live objects at exit equal at $short and $long iterations"
        fi
    done
done
echo "Summary: $out/summary.csv"
exit "$status"
