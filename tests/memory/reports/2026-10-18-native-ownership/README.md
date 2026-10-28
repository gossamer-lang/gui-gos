# Native ownership audit, 2026-10-18

The complete code-editor fixture passes strict Valgrind checks in debug native
and optimized dynamic native, using a system-allocator runtime and
`GOS_RC_NO_POOL=1`. Both runs report:

| Category | Bytes | Blocks |
|---|---:|---:|
| Definitely lost | 0 | 0 |
| Indirectly lost | 0 | 0 |
| Possibly lost | 0 | 0 |
| Still reachable | 66,384 | 105 |
| Suppressed | 0 | 0 |

Both error summaries are zero. The fixture exercises Save As editing and Save,
cancellation, retained tab pages, tear-off/merge, focus, screenshots and dirty
close. The raw fixture transcripts, all Valgrind loss records and artifact hashes
are retained in the `debug` and `release` directories. The script is
[../../run.sh](../../run.sh); setup is in [../../README.md](../../README.md).
`GUI_MEMORY_RELEASE=1` selects optimized code with the supplied host runtime.

`regressions` retains VM and forced JIT output and debug/optimized native
Valgrind logs for three compiler fixtures: native owner lifecycles, method-vector
return cleanup and rebound-string field transfer. Each installs JIT entries,
all outputs match, and all six native checks report zero lost bytes and zero
errors. `checks` retains the focused compiler, toolkit and windowing checks.
Rust formatting and workspace all-target/all-feature Clippy with warnings denied
pass. The release compiler is rebuilt; its JIT smoke and optimized-native strict Valgrind smoke pass. Windowing four-tier parity also passes with that compiler. The full compiler workspace test gate has not been rerun after this audit.

The other three implemented examples also pass strict debug-native checks with
zero lost bytes in every category, zero errors and no suppressions. Their raw
logs are under `examples`. Hello World and the application launcher each retain
20,911 reachable bytes in 71 blocks; the widgets showcase retains 21,631 in 73.
They use the same compiler, supplied runtime, CPU target, system allocator,
private settings and Valgrind flags as the editor debug scan.

These are Linux x86-64 offscreen exit-time checks. Reachable library and runtime
caches remain reported. They do not establish long-running memory-growth limits,
allocator high-water budgets, real display behavior or other platform results.
The wider toolkit implementation plan remains incomplete.
