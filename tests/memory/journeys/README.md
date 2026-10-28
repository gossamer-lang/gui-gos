# Resource journeys

Long-running toolkit lifecycles, each repeated many times:

| Journey | One iteration |
|---|---|
| `windows` | Open a second window, type into it, capture it, close it |
| `popups` | Open and dismiss a select list, open and dismiss a menu by keyboard |
| `tabs` | Tear a tab off into its own window and merge it back |
| `editor` | Type, open and dismiss completion, copy, undo, select all, delete |

Each journey prints `journey,phase,iterations,rss_kib,fds` after ten warmup
iterations and at the end. `run.sh` runs every journey at N and 4N iterations
(default N = 40, `GUI_JOURNEY_SHORT`) on the VM, forced JIT, debug native and
release native (`GUI_JOURNEY_TIERS`), with the runtime's leak ledger
(`GOS_LEAK_LEDGER=1`). It fails when the objects live at exit differ between
the two lengths, or when open descriptors grow after warmup. Resident memory
is recorded in `summary.csv` but not gated: the allocator keeps pages it has
used, so a flat count is the evidence, not an equal RSS.

```sh
./tests/memory/journeys/run.sh
GUI_JOURNEY_TIERS='debug release' GUI_JOURNEYS=windows ./tests/memory/journeys/run.sh
```

Run one journey directly with `gos run tests/memory/journeys windows 200`
(arguments after the package path, without `--`; see B11 in the Track B
issues file).

The VM's own values are not runtime allocations, so its ledger counts stay
near zero; the compiled tiers are where the ledger measures the toolkit.
Measurements use the offscreen video driver and `/proc` (Linux); descriptor
and RSS columns read -1 elsewhere.
