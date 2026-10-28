#!/bin/sh
# Timings are measurements, not deterministic parity output or certified budgets.
set -eu
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
out=${GUI_PERFORMANCE_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
{
    date -u
    uname -a
    "$GOS" --version
    if command -v sha256sum >/dev/null; then sha256sum "$(command -v "$GOS")"; fi
    if command -v lscpu >/dev/null; then lscpu; fi
} > "$out/environment.txt"
echo "Performance report: $out"
measure() {
    resources=$1
    shift
    if [ -x /usr/bin/time ]; then
        /usr/bin/time -v -o "$resources" "$@"
    else
        "$@"
    fi
}
cd examples/code-editor
export SDL_VIDEO_DRIVER=offscreen
# Isolate settings and window placement so prior interactive runs cannot alter results.
export XDG_CONFIG_HOME="$out/config"
export XDG_CACHE_HOME="$out/cache"
limit=${GUI_PERFORMANCE_TIMEOUT:-900}
samples=${GUI_BENCHMARK_SAMPLES:-12}
case "$samples" in ''|*[!0-9]*|0) echo 'GUI_BENCHMARK_SAMPLES must be positive' >&2; exit 1 ;; esac
export GUI_BENCHMARK_SAMPLES="$samples"
tiers=${GUI_PERFORMANCE_TIERS:-vm jit debug release}
for tier in $tiers; do
    case "$tier" in
        debug) "$GOS" build . > "$out/debug-build.txt" ;;
        release) "$GOS" build --release . > "$out/release-build.txt" ;;
    esac
    for size in small large; do
        set -- --benchmark
        [ "$size" = small ] || set -- "$@" --large
        file="$out/$tier-$size.csv"
        case "$tier" in
            vm) GOS_JIT=0 measure "$out/$tier-$size.resources" timeout -k 5 "$limit" "$GOS" run . -- "$@" > "$file" ;;
            jit) GOS_JIT=1 GOS_JIT_STATS=1 GOSSAMER_JIT_THRESHOLD=1 measure "$out/$tier-$size.resources" timeout -k 5 "$limit" "$GOS" run . -- "$@" > "$file" 2> "$out/jit-$size-stats.txt"
                awk '/gos-jit-stats: compiled=/ { split($0, a, "compiled="); total += a[2]+0 } END { exit total > 0 ? 0 : 1 }' "$out/jit-$size-stats.txt" ;;
            *) wc -c < "./target/$tier/gui-code-editor" > "$out/$tier-artifact-bytes.txt"
               measure "$out/$tier-$size.resources" timeout -k 5 "$limit" "./target/$tier/gui-code-editor" "$@" > "$file" ;;
        esac
        awk -F, -v expected="$((1 + 4 * samples))" 'NF != 3 || $3 < 0 { bad=1 } END { exit bad || NR != expected }' "$file"
        echo "Measured $tier $size"
    done
done
printf 'tier,size,operation,samples,p50_ns,p95_ns,p99_ns\n' > "$out/summary.csv"
for tier in $tiers; do
    for size in small large; do
        for operation in startup typing cursor scroll completion; do
            awk -F, -v op="$operation" '$1 == op { print $3 }' "$out/$tier-$size.csv" |
                sort -n | awk -v tier="$tier" -v size="$size" -v op="$operation" '
                    { samples[NR]=$1 }
                    END { n=NR; if (!n) exit 1;
                          p50=int(n*0.50+0.999); p95=int(n*0.95+0.999); p99=int(n*0.99+0.999);
                          printf "%s,%s,%s,%d,%s,%s,%s\n", tier,size,op,n,samples[p50],samples[p95],samples[p99] }' >> "$out/summary.csv"
        done
    done
done
echo "Summary: $out/summary.csv"
