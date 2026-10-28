# Release-native performance gates

Run `./tests/perf/run.sh` from the repository root. `GOS` selects the installed
compiler; `GUI_PERF_OUT` selects a retained report folder. The runner always
builds release native, uses software rendering with SDL's offscreen driver,
disables the accessibility bus and isolates settings and caches. Compilation
is outside the measurements. All six fixtures run even if a budget fails.

Each fixture prints one CSV record:

```text
fixture,unit,samples,p95,p99,p95_budget,p99_budget
```

The fixture exits unsuccessfully if its semantic checks or either budget fail.
The report retains each record, errors, build output, compiler hash and system
metadata. `results.csv` includes a header. Values use nanoseconds except idle,
which reports extra event-loop wakeups over a 60 second observation. The final
observation timer and its model-update frame are excluded. Any other wakeup
or frame fails. This counts toolkit loop returns, not operating-system thread
context switches or compositor activity.

`GUI_PERF_SAMPLES` defaults to 100 and must be at least 100. Percentiles use
nearest rank. Fixtures measure:

- Startup: toolkit initialization through the first software presentation of
  an editor containing 32 distinct source lines, repeated in one process.
  This includes the first cold toolkit instance and subsequent warm instances,
  but excludes OS process startup and file IO.
- Typing: 100 committed characters through the shared multiline monospace
  editor, including dispatch, model update, layout and presentation. The final
  text must contain every character.
- Scroll: Page Down through a two-column million-row table. The semantic tree
  must change and expose fewer than 32 rows.
- Picker: open and dismiss a searchable picker with 100,000 choices; each
  measured opening must create its popup.
- Resize: alternate surface dimensions, synchronize the native window, and
  deliver pixel-size changes through the session. The resulting size must match.
- Idle: a static window without text focus, animation or other scheduled work.

The initial ceilings are documented in [Performance](https://gossamer-lang.org/docs/ecosystem/gui/performance/). A passing
software/offscreen run does not certify real-display input-to-present latency,
GPU rendering, diverse large documents, or other platforms. Run without other
CPU-heavy work and retain reports when comparing changes.
