#!/bin/sh
# Every example with a scripted journey must produce the same semantic
# transcript on all four tiers; hello-world must build on both native profiles.
#
#   tools/check-examples.sh [NAME...]    the named examples, or all of them
set -eu
export GUI_TEST_INLINE_WORK=1
cd "$(dirname "$0")/.."
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
out=${GUI_EXAMPLE_REPORT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
work=$(mktemp -d "$out/run.XXXXXX")
export XDG_CONFIG_HOME="$out/config" XDG_CACHE_HOME="$work/cache"
limit=${GUI_FIXTURE_TIMEOUT:-300}
status=0
# The examples with scripted journeys, after hello-world; the release gate
# lists the same ones.
if [ "$#" -eq 0 ]; then
    set -- hello-world application-launcher code-editor widgets-showcase
fi
for name in "$@"; do
    # hello-world is the smallest application and has no scripted journey:
    # it must type-check and build on both native profiles.
    if [ "$name" = hello-world ]; then
        (
            cd examples/hello-world
            "$GOS" check . > /dev/null && "$GOS" build . --out-dir "$work/hello-world/debug" > /dev/null && "$GOS" build --release . --out-dir "$work/hello-world/release" > /dev/null
        ) && echo "PASS: hello-world (check, debug native, release native)" || { echo "FAILED: hello-world" >&2; status=1; }
        continue
    fi
    directory="examples/$name"
    if [ ! -f "$directory/project.toml" ]; then
        echo "MISSING: $name" >&2
        status=1
        continue
    fi
    mkdir -p "$out/$name"
    if ! (
        cd "$directory"
        export SDL_VIDEO_DRIVER=offscreen
        if [ "$name" = rich-editor ]; then export GUI_TEST_INLINE_WORK=0; fi
        export XDG_CONFIG_HOME="$out/$name/config"
        export XDG_CACHE_HOME="$work/cache"
        GOS_RUN_ENGINE=vm GOS_JIT=0 timeout -k 5 "$limit" "$GOS" run . -- --fixture > "$out/$name/vm.txt" || exit 1
        GOS_RUN_ENGINE=vm GOS_JIT=1 GOS_JIT_STATS=1 GOSSAMER_JIT_THRESHOLD=1 timeout -k 5 "$limit" "$GOS" run . -- --fixture > "$out/$name/jit.txt" 2> "$out/$name/jit-stats.txt" || exit 1
        awk '/gos-jit-stats: compiled=/ { split($0, a, "compiled="); total += a[2]+0 } END { exit total > 0 ? 0 : 1 }' "$out/$name/jit-stats.txt" || { echo "No JIT entries installed: $name" >&2; exit 1; }
        "$GOS" build . --out-dir "$work/$name/debug-bin" > "$out/$name/debug-build.txt" || exit 1
        binary=$(sed -n 's/^id = "[^/]*\/\([^"]*\)"/\1/p' project.toml)
        timeout -k 5 "$limit" "$work/$name/debug-bin/$binary" --fixture > "$out/$name/debug.txt" || exit 1
        "$GOS" build --release . --out-dir "$work/$name/release-bin" > "$out/$name/release-build.txt" || exit 1
        timeout -k 5 "$limit" "$work/$name/release-bin/$binary" --fixture > "$out/$name/release.txt" || exit 1
        for tier in jit debug release; do
            diff -u "$out/$name/vm.txt" "$out/$name/$tier.txt" || exit 1
        done
        if [ "$name" = code-editor ]; then
            # Save/Discard/Cancel must also close through the real worker.
            export GUI_TEST_INLINE_WORK=0
            GOS_JIT=0 timeout -k 5 "$limit" "$GOS" run . -- --close-fixture > "$out/$name/close-vm.txt" || exit 1
            GOS_JIT=1 GOSSAMER_JIT_THRESHOLD=1 timeout -k 5 "$limit" "$GOS" run . -- --close-fixture > "$out/$name/close-jit.txt" || exit 1
            timeout -k 5 "$limit" "$work/$name/debug-bin/$binary" --close-fixture > "$out/$name/close-debug.txt" || exit 1
            timeout -k 5 "$limit" "$work/$name/release-bin/$binary" --close-fixture > "$out/$name/close-release.txt" || exit 1
            for tier in jit debug release; do diff -u "$out/$name/close-vm.txt" "$out/$name/close-$tier.txt" || exit 1; done
        fi
    ); then
        echo "FAILED: $name" >&2
        status=1
    else
        echo "PASS: $name (VM, JIT, debug native, release native)"
    fi
done
if [ "$status" -eq 0 ] && [ -z "${GUI_EXAMPLE_REPORT:-}" ]; then
    rm -rf "$out"
else
    echo "Example logs: $out" >&2
fi
exit "$status"
