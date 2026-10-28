# Native editor leak check

The runner fails on invalid accesses and definite, indirect or possible leaks.
It preserves its build, fixture transcript, full Valgrind log and artifact hashes.
It does not suppress leak categories or treat a semantic transcript as memory
evidence. Valgrind's still-reachable process/library allocations are reported.

Build a system-allocator runtime from the Gossamer checkout:

```sh
CARGO_TARGET_DIR=target-prof RUSTFLAGS='--cfg fuzzing -C debuginfo=1' \
    cargo rustc -p gossamer-runtime --release --lib --crate-type staticlib -j 4
```

Then run from this toolkit checkout:

```sh
GOS=/home/daniel/dev/gossamer/target/debug/gos \
GOS_RUNTIME_LIB=/home/daniel/dev/gossamer/target-prof/release/libgossamer_runtime.a \
./tests/memory/run.sh
```

Use a compiler and archive built from the same current sources. Set
`GUI_MEMORY_OUT` to retain results at a chosen path. Each fixture is bounded to
600 seconds by default, configurable through `GUI_MEMORY_TIMEOUT`. The x86-64
default target is v3 to avoid unsupported newer instructions in Valgrind.
Other platforms and physical presentation still require their own checks.

Set `GUI_MEMORY_RELEASE=1` to check optimized native code. This uses the dynamic
host link so the supplied system-allocator archive is used, including on Linux
installations whose default release target uses a separate musl archive.

The [2026-10-18 audit](reports/2026-10-18-native-ownership/README.md) retains clean
debug and optimized editor scans, regression evidence and validation logs.
