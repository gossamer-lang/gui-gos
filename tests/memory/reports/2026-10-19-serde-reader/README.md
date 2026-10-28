# Typed reader ownership audit

Repeated file-browser settings decoding exposed an eager fallback allocation in
`gos_rt_serde_rd_map_key`. A valid reader allocated both its returned key and an
unused empty fallback string. Six keys left 228 bytes of strings and 312 bytes
of diagnostic registry storage. The runtime now constructs the fallback only
for a missing reader. `gos_rt_serde_rd_json` had the same fallback defect and
uses the same lazy helper.

The minimized map-settings program changes from 540 possibly lost bytes to zero
definite, indirect or possible losses and zero memory errors under strict
system-allocator Valgrind, without suppressions. Runtime tests pass 468 tests;
formatting and workspace Clippy with warnings denied pass.

The additional `aggregate-json.gos` probe reveals a separate compiler
ownership defect: storing a decoded `json::Value` in a struct leaves its
actual handle unreclaimed. With the fallback fixed, three iterations still lose
72 direct and 555 indirect bytes. The raw failing report is retained. The subsequent
[JSON aggregate audit](../2026-10-19-json-aggregate/README.md) records its fix and
expanded regression evidence. Long-running resource budgets remain open.
