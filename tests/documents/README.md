# Native document regression

`./run.sh` compares the VM, forced JIT, debug-native and release-native transcripts
with real worker threads. Each tier edits 10+ MiB of Unicode/bidi source and a
1 MiB line, checks immutable snapshots and anchor affinity, performs worker
search, tests undo/redo and stale save markers, then checkpoints and restores
unsaved text and history. Session shutdown must release hosted callbacks.

The default functional p95 ceiling is 1,000 ms. The runner also executes the
release binary with `GUI_DOCUMENT_P95_MS=75` and `--timings` for the host's stricter
typing regression gate. `GUI_DOCUMENT_RELEASE_P95_MS` overrides that final ceiling. Timings include update, layout and software presentation and
exclude compilation and initial file creation. Run on an idle host. This is an
offscreen CPU gate; native presentation/IME/accessibility certification is separate.
