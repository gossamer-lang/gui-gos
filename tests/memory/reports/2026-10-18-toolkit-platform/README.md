# Toolkit and Linux accessibility verification

The six-journey toolkit fixture matches its expected transcript in VM, forced
JIT, debug native and optimized dynamic native. The JIT reports installed
entries. The GUI suite passes 140 tests and 858 assertions, including the
240-assertion color picker label/input spacing regression. Existing parity
also matches all four tiers.

Both native fixture binaries pass strict system-allocator Valgrind checks:
zero definite, indirect and possible lost bytes, zero errors, and no
suppressions. Both retain 7,678 reachable bytes in 43 blocks. These are finite
fixture checks, not a long-running resource budget certification.

The fixed journey covers temporal validation, color preview/cancel, calendar
acceptance/focus restoration, font preview/cancel, preferences Apply/dirty
Cancel, and wizard Back/draft retention/Finish.

The private-bus native AT-SPI probe passes cache discovery, text query, an edit
applied by the UI thread, and graceful disconnect. It uses X11 and does not
certify Orca, Wayland, Windows UIA or macOS accessibility. Private bus teardown
prints a connection message after the successful probe.

Compiler/runtime hashes used to build these binaries are in `environment.txt`;
they identify this evidence even if the local compiler is rebuilt later.
Toolkit source hashes are in `sources.sha256`. The native runtime archive uses
the system allocator, with `GOS_RC_NO_POOL=1`; builds use
`GOS_LLVM_MCPU=x86-64-v3`. Runtime checks set `SDL_VIDEO_DRIVER=offscreen` and
`GUI_ACCESSIBILITY=off`; the separate AT-SPI probe enables accessibility.
Reproduce with `tests/toolkit-platform/run.sh`, `GUI_TOOLKIT_MEMORY=1` and
`GOS_RUNTIME_LIB` pointing to the system-allocator archive. Use
`tests/toolkit-platform/atspi.sh` for the isolated native protocol probe.

Remaining toolkit/platform gates are recorded in
[the checkpoint](../../../../docs/toolkit-platform.md).
