# Release acceptance baseline, 2026-10-21

Command: `GUI_PERF_OUT=/tmp/gui-gos-wrap-work/perf-report ./tests/perf/run.sh`
in the private gui-gos working copy. All six fixtures pass. The runner built
release native before measurement; no other task builds ran during the final
measurements. Every timed fixture takes 100 samples. The static idle window is
observed for 60 seconds without caret blinking or animation.

`results.csv` records nearest-rank p95/p99 and both failing ceilings.
`environment.txt` records the CPU, PCI graphics, OS/kernel and compiler hash.
`binary.sha256` identifies the measured release executable; `build.txt` records
its profile/output. `parity.txt` records the separate four-tier geometry check.
The binary and build caches are not distributed in this report.

| Fixture | p95 | p99 |
|---|---:|---:|
| Startup through first software presentation | 15.63 ms | 16.56 ms |
| Committed typing in the monospace editor | 1.46 ms | 1.70 ms |
| Million-row two-column table scrolling | 2.42 ms | 2.68 ms |
| Opening the 100,000-choice picker | 109.55 ms | 116.70 ms |
| Native surface resize plus session dispatch | 1.39 ms | 1.58 ms |
| Static idle | 0 extra loop wakeups | 0 extra frames |

These are software/offscreen measurements on the documented Linux reference
host. Startup includes one cold toolkit instance and warm repeated instances,
with compilation and OS process startup excluded. The picker retains all
choices but renders a bounded popup. Resize uses the offscreen backend, with
native size synchronization followed by a session pixel-size event. Idle
counts toolkit loop returns, excluding its final observation deadline and the
frame caused by that deadline's model update; it does not count OS thread
context switches. GPU, physical display latency, large-document and other
platform acceptance remain open.
