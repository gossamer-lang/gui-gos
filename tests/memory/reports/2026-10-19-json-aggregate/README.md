# JSON aggregate ownership, 2026-10-19

G32 is fixed: JSON fields clone independent handles into aggregate storage and
release them during teardown. Projected reads acquire a handle before the source
aggregate dies. Counted aggregate descriptors and region copy metadata name JSON
children too. The prior three-iteration failure lost 72 direct and 555 indirect
bytes; the minimized fixed scan loses zero bytes in every category.

The broader `copies.gos` probe exercises field reads, return values, reassignment,
nested structs, vectors, maps, fixed arrays and recursive boxed enums. It exposed
G33, missing field acquisition for indexed aggregate copies, and G34, release
hoisting that sorted a block-entry sentinel as the latest insertion point and
freed an enum before its last copy. Both are fixed with regression coverage.

VM, forced-JIT, debug native and optimized dynamic native transcripts match.
The forced-JIT execution falls back for every body in this JSON probe; the trace
is retained and this is not certification of compiled JIT JSON support. Debug
and release system-allocator Valgrind scans have zero definite, indirect and
possible losses and zero errors, without suppressions. A further release scan
with the subsequent accessibility compiler fixes also remains clean.

The combined compiler gate exits successfully: 1,344 passing tests, including all
five requested targets, 92 tier parity checks, 150 MIR lowerings, 33 LLVM shapes
and 470 runtime tests. Workspace Clippy with warnings denied and formatting pass.
This gate predates the subsequent accessibility ownership fixes, which have their
own report and verification. Long-running toolkit resource budgets remain open.
