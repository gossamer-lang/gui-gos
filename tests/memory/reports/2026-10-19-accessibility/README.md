# Linux accessibility ownership audit, 2026-10-19

The initial real X11 accessibility journey lost 12,500 direct, 44,276 indirect
and 40,500 possible bytes. No suppressions are used in this audit.

G35 fixes a consumed string extraction retaining a share with no owner when a
later binding stores it in an aggregate. G36 gives conditional vector call
results null owner slots so return cleanup is valid across branch joins.
Follow-on checks exposed G37, transferred vector payload cleanup suppressed when
an aggregate returns its independently retained share, and G38, per-site vector
cleanup missed for field stores through borrowed receivers or indexed paths.
The compiler now distinguishes those owners. Null guard assignments also no
longer count as allocated prior values when deciding whether a move is safe.
Compiler regressions and the nested native D-Bus round-trip cover these paths.

The detached nine-node snapshot/query fixture has zero definite, indirect or
possible losses and zero memory errors in every query mode. Four and 64 debug
updates both leave exactly 3,584 reachable bytes in two runtime registry blocks.

SDL releases X11 display instances, but unloading Xlib strands its global locale
and quark caches. The windowing backend promotes the already loaded Xlib to
process lifetime and balances its temporary loader reference. The test does not
preload a library or suppress allocations. Strict 33- and 65-session native runs
both have zero lost bytes/errors, stable descriptors, and exactly 81,409 reachable
bytes in 1,010 blocks. Thus the preserved caches plateau across sessions.
See [the lifecycle contract](../../../../../windowing-gos/tests/resources/README.md).

The real debug-native X11/D-Bus journey now reports zero lost bytes and errors.
It validates live introspection XML, signed 16-bit stacking order, discovery,
Unicode text queries, a UI-thread edit to 14:20:00, and normal disconnect.
Portal subprocess messages in the retained unfiltered run log are separate from
the instrumented application's memory report. The nested transport test also
passes strict debug and optimized native memory checks.

The editor's full debug journey and actual Save, Discard and Cancel clicks remain
strict-Valgrind clean. GUI unit checks pass 144 tests and 998 assertions; windowing
unit checks pass six tests and 206 assertions. Optimized integration and the
fresh complete compiler workspace gate are still being collected.

The subsequent compiler parity gate exposed G39 in
`feature-testing-examples/mut_ref_element_loops.gos`. Newly guarded cleanup
reclaimed a vector after assigning it into a mutable element slot that had not
acquired a share. The compiler now retains the incoming vector before releasing
the displaced vector, including safe self-assignment. Per-site cleanup retains
its own independent share. The full corpus fixture now matches the VM and has
zero lost bytes and errors in both native system-allocator scans. All 154 MIR
lowering tests pass and workspace Clippy with warnings denied passes. The
intermediate compiler gate is retained as a failure, not reported as green;
a fresh complete workspace run follows the final source fix.
