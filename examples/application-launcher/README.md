# Launcher catalog demonstration

Requires Gossamer 0.75.5+. Run `gos fetch` once for the tagged windowing-gos
and gui-engine-gos releases, then `gos run .` here or build using
`gos build .` / `gos build --release .`. Native executable:
`target/{debug,release}/app-launcher`.

Search filters a fixed catalog; Enter in search or the Launch command starts
the selected structured executable and argument vector. No search text is sent
to a shell. Missing programs are reported in the window. Catalog targets are
Linux examples and may not be installed.

`SDL_VIDEO_DRIVER=offscreen gos run . -- --fixture` checks search and Enter
through the session and records a fake launch without starting a process.
Native binaries accept `--fixture` directly.

OS catalog discovery, asynchronous activation, favorites/recent persistence,
large-catalog ranking and real-platform launch evidence remain open.
