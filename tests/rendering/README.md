# Retained renderer verification

Run `./run.sh` from this directory, or `tests/rendering/run.sh` from gui-gos.
Requires Cargo, Weston with Xwayland, a private D-Bus session and Mesa/OpenGL.
Set `GUI_RENDER_OUT` to retain CSVs, environment metadata and display logs.
The runner fails when reference pixels, GPU tolerance, recovery or byte/work
invariants fail. It never rewrites screenshot goldens.
It also verifies that an unset `GUI_RENDERER` uses software on X11 and Wayland,
including after renderer resets, before checking explicit GPU selection.

See [the renderer contract](https://gossamer-lang.org/docs/ecosystem/gui/rendering/). For an existing display,
run `cargo run --release --example render-check -- --require-gpu` from
`gui-engine-gos/rust/gui-engine` with `GUI_RENDERER=gpu` and the intended
`SDL_VIDEO_DRIVER`. Without `--require-gpu`, fallback remains available.
