# Editor startup and Save changes verification

The release startup fault came from an ownership error in LLVM's boxed enum
payload copy. The copied binding released the caller's map handle. LLVM now
acquires all direct and guarded children in the destination slots, including
independent map/set handles. The recursive enum shape and repeated field-read
regressions pass. The original native crash trace is retained.

The Save changes dialog had a separate layout defect: the severity icon's
vertical alignment consumed the available body height and left the footer
outside its hit-test ancestors. The icon now uses top alignment in the row.
The new geometry regression checks all three buttons at normal and 200% text.
The GUI suite passes 141 tests and 954 assertions.

The editor fixture now clicks Cancel and Don't Save instead of supplying an
outcome programmatically. `--close-fixture` independently clicks Cancel,
Don't Save and Save, waits for asynchronous file completion, verifies file
contents, and exits normally. VM, debug native and optimized native pass.
The release executable in `examples/code-editor/target/release` is rebuilt.
A real X11 launch mapped the window and closed normally with exit 0.

All four strict system-allocator Valgrind runs pass: the full editor journey
and the three-action close fixture in debug and optimized native. Each reports
zero definite, indirect and possible lost bytes and zero memory errors, with
no suppressions. Reachable storage is 52,423 bytes for the editor journey and
50,327 bytes for the close fixture. These finite journeys do not certify the
remaining long-running resource budgets.

Builds use `GOS_RUNTIME_LIB` for the retained system-allocator archive and
`GOS_LLVM_MCPU=x86-64-v3`. Checks set `GOS_RC_NO_POOL=1`,
`SDL_VIDEO_DRIVER=offscreen` and `GUI_ACCESSIBILITY=off`. Compiler, runtime,
source and executable hashes are retained. The X11 probe uses the normal
release runtime and its real window.

Formatting and workspace Clippy with warnings denied pass. The combined
compiler test gate has its own result and is not inferred from these GUI
checks.

The five requested compiler targets pass together: host runtime library (3),
tier parity (92), weak references (1), builtin coverage (4), and uniqueness
(14), totaling 114 tests. The additional LLVM shape suite passes 33 tests.
The map/tuple corpus fixture explicitly records its JIT admission exclusions
in the existing fallback ledger; its JIT run is not reported as native coverage.

The `current/` follow-up retains the same four passing strict editor memory
checks after file-browser navigation and the typed-reader fallback fix. The
GUI suite now passes 142 tests and 974 assertions. The final normal-runtime
release executable passes both editor fixtures with empty stderr and is copied
to `examples/code-editor/target/release/gui-code-editor`; its current hash and
runtime hashes are recorded separately from the original checkpoint above.
The complete compiler workspace command finishes with exit 0: 5,962 tests pass,
zero fail and one is ignored. The subsequent typed-reader fallback fix has its
own 468-test runtime gate and workspace Clippy result.
