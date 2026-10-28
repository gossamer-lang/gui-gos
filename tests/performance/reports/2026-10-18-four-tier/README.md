# Four-tier editor diagnostic, 2026-10-18

Generated with the final rebuilt compiler using:

```sh
GOS=/home/daniel/dev/gossamer/target/release/gos \
GUI_BENCHMARK_SAMPLES=2 \
GUI_PERFORMANCE_OUT=/tmp/gui-final-performance \
./tests/performance/run.sh
```

The default runtime selection is used. This differs from the system-allocator
runtime used in the separate controlled cache comparison. The report retains
raw CSVs, compiler/hardware metadata, JIT entry counts, build results, artifact
sizes and process resource measurements. Linux settings were isolated.
Compiler and parity checks were active concurrently.

| Tier | 32-line typing range | 2,048-line typing range |
|---|---|---|
| VM | 463.7-468.1 ms | 1,258-1,275 ms |
| Forced JIT | 178.9-187.5 ms | 948.2-958.3 ms |
| Native debug | 5.81-5.83 ms | 18.03-18.60 ms |
| Native release | 2.82-2.85 ms | 12.45-13.24 ms |

Large native release completion cycles took 83-101 ms. The native release
artifact was 11,831,456 bytes; measured maximum resident memory was about 41 MiB
for small and 95 MiB for large. VM/JIT process memory includes the compiler and
runtime and cannot be compared directly to a standalone native executable.

Only two samples per operation and one startup were taken. The percentile
columns are nearest-rank calculations on those samples, not established tail
latency. Fixtures repeat a source template; offscreen timing excludes process
startup, file IO and physical presentation. The 10 MiB/long-line, resource-growth,
diverse-file and real-platform budgets remain open. See the
[measurement method](../../../../docs/performance.md).
