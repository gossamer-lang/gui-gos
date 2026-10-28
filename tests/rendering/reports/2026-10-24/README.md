# Rendering and CI checkpoint, 2026-10-24

Implementation and local validation for priority items 1–4 in
`~/dev/plans/gui_for_goss.md`. [Renderer contract](../../../../docs/rendering.md).

| Check | Result |
|---|---|
| Rust formatting and Clippy, all targets of both cores and bindings | Pass, Rust 1.95.0 |
| Toolkit unit/session tests | 334 passed, including subtree reuse/eviction, purge, occlusion and pixel equivalence |
| Windowing Rust tests | 9 passed |
| Both binding test targets | Pass |
| Gossamer unit tests | 55 passed, 267 assertions |
| Windowing parity | Four tiers agree, 177 lines |
| Wrapper | Four tiers match; transformations, byte limits, cache hits and reset recovery |
| Software screenshot goldens | All nine scenes match on all four tiers, no golden updates |
| Examples | Hello world checks/builds in both native profiles; showcase, editor and launcher agree on all four tiers |
| Gossamer quick-check | Pass, including the mechanically migrated optional webview custom-widget adapter |
| Workflow | actionlint and four-repository checkout inspection pass |
| Renderer fixture | Software, unavailable-acceleration fallback, X11 OpenGL and Wayland OpenGL pass |

The final screenshot, wrapper and example runners use fresh native output
folders and binding caches. Earlier fixed-output runs could reuse native
executables after Rust-only edits; those runs are not substituted for this
checkpoint's fresh-build results. See the per-tier transcripts and build logs.

Each renderer path measures 30 samples of five workloads at 640x480,
1920x1080 and 3840x2160. Actual GPU readback is compared initially and after
incremental frames; the maximum allowed difference is 8 per 8-bit channel.
Software goldens remain exact. The fixture verifies reset delivery, software
fallback after device loss and subsequent GPU recreation, bounded raster/GPU
caches, isolated-subtree reuse, 18-pixel caret damage and zero raster work on
unchanged scenes. SDL's fixed-size offscreen EGL pbuffer is unsupported by the
GPU compositor; forced acceleration there exercises software fallback.

Diagnostic p95 at 3840x2160, milliseconds:

| Backend | Caret | Text change | Scroll | Resize | Unchanged scene |
|---|---:|---:|---:|---:|---:|
| Software | 0.054 | 0.141 | 0.234 | 38.088 | 0.033 |
| X11 OpenGL | 26.236 | 15.765 | 16.563 | 142.941 | 0.138 |
| Wayland OpenGL | 17.795 | 18.390 | 16.767 | 83.019 | 0.133 |

These measurements used private headless Weston/Xwayland outputs and ran
alongside compilation. They are diagnostics, not calibrated input-to-present
or physical-GPU performance certification. Large full-window resize costs
remain visible in the raw CSVs. Native D3D/Metal execution is wired into the
Windows/macOS CI jobs but was not executed on this Linux host. The combined
release/performance gate remains separate work.

`environment.txt`, `hardware.txt`, `sources.sha256` and `goldens.sha256`
identify the toolchains, host and checked sources. Rendering cache budgets do
not complete the broader document/model/task memory audit or background-work
service, priority items 5 and 6.
