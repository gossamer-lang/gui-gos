# Paragraph reuse diagnostic, 2026-10-18

This is an exploratory native debug comparison with the same rebuilt Gossamer
compiler, release Rust system-allocator runtime and x86-64-v3 target. Raw CSVs,
min/max summaries and hardware/artifact hashes are retained alongside this file.
It measures paragraph reuse only. Both cases contain the border-painting,
boundary-search and paragraph-discovery improvements.

The baseline copies the toolkit and editor into temporary directories, points
their manifests at the same dependencies, and replaces `cached_paragraph` with:

```gossamer
fn cached_paragraph(text: String, style: TextStyle, options: LayoutOptions, ascent: f64, line_h: f64) -> Vec<Line> {
    layout_paragraph(text, 0, text.byte_len(), style, options, ascent, line_h, grapheme_boundaries(text))
}
```

The other binary uses the accounted paragraph cache. Each binary runs
`--benchmark`, then `--benchmark --large`, with two samples per operation,
offscreen presentation and separate Linux settings directories. Cases run
sequentially. Other compiler/parity checks were active on the machine, so these
numbers do not establish absolute latency or stable percentiles.

| Repeated source lines | Typing without reuse | Typing with reuse |
|---|---|---|
| 32 | 67.6-70.4 ms | 7.3-7.8 ms |
| 2,048 | 3,904-3,976 ms | 35.1-35.9 ms |

Cursor and scroll times did not improve in this run. Completion still takes
about 250-298 ms on the large cached fixture. The repeated source template favors
reuse. Diverse files, 10 MiB documents, 1 MiB lines, resource growth, real displays
and p95/p99 acceptance remain unverified. See [measurement method](../../../../docs/performance.md)
for timer boundaries and the reproducible four-tier runner.
