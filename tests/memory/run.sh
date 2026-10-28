#!/bin/sh
# The runtime must use the system allocator so Valgrind can see its ownership.
set -eu
cd "$(dirname "$0")/../.."
GOS=${GOS:-gos}
export GOS
./tools/check-toolchain.sh
command -v valgrind >/dev/null
: "${GOS_RUNTIME_LIB:?Set GOS_RUNTIME_LIB to a system-allocator runtime archive}"
out=${GUI_MEMORY_OUT:-$(mktemp -d)}
mkdir -p "$out"
out=$(cd "$out" && pwd)
case "$(uname -m)" in
    x86_64) GOS_LLVM_MCPU=${GOS_LLVM_MCPU:-x86-64-v3}; export GOS_LLVM_MCPU ;;
esac
{
    date -u
    uname -a
    "$GOS" --version
    echo "GUI_MEMORY_RELEASE=${GUI_MEMORY_RELEASE:-0}"
    if command -v sha256sum >/dev/null; then
        sha256sum "$(command -v "$GOS")" "$GOS_RUNTIME_LIB"
    fi
} > "$out/environment.txt"
echo "Memory report: $out"
if [ "${GUI_MEMORY_RELEASE:-0}" = 1 ]; then
    "$GOS" build --release --dynamic examples/code-editor --out-dir "$out/bin" > "$out/build.txt"
else
    "$GOS" build examples/code-editor --out-dir "$out/bin" > "$out/build.txt"
fi
SDL_VIDEO_DRIVER=offscreen XDG_CONFIG_HOME="$out/config" GOS_RC_NO_POOL=1 \
    timeout -k 5 "${GUI_MEMORY_TIMEOUT:-600}" valgrind \
    --leak-check=full --show-leak-kinds=all \
    --errors-for-leak-kinds=definite,indirect,possible --error-exitcode=99 \
    --log-file="$out/valgrind.txt" "$out/bin/gui-code-editor" --fixture \
    > "$out/fixture.txt" 2> "$out/stderr.txt"
SDL_VIDEO_DRIVER=offscreen XDG_CONFIG_HOME="$out/close-config" GOS_RC_NO_POOL=1 \
    timeout -k 5 "${GUI_MEMORY_TIMEOUT:-600}" valgrind \
    --leak-check=full --show-leak-kinds=all \
    --errors-for-leak-kinds=definite,indirect,possible --error-exitcode=99 \
    --log-file="$out/close-valgrind.txt" "$out/bin/gui-code-editor" --close-fixture \
    > "$out/close-fixture.txt" 2> "$out/close-stderr.txt"
echo "Memory check passed: $out/valgrind.txt"
echo "Confirmation memory check passed: $out/close-valgrind.txt"
