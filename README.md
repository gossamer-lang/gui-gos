# gui-gos

A desktop GUI toolkit for [Gossamer](https://github.com/gossamer-lang/gossamer),
used as `use gui`. You describe your window as a tree of widgets built from
your model; the toolkit draws it, handles input and accessibility, and sends
your `update` function a message for each thing the user does. It runs on
Linux (X11 and Wayland), macOS and Windows, and draws in software by default.

```gossamer
use gui
use gui::{UiMsg, Widget}

struct Model {
    count: i64
}

fn update(m: Model, msg: UiMsg) -> Model {
    match msg {
        UiMsg::Click(id) if id == "add" => Model { count: m.count + 1 }
        _ => m
    }
}

fn view(m: Model) -> Widget {
    Widget::column(#[
        Widget::label(f"Clicked {m.count} times")
        Widget::button("add", "Click me")
    ], 12).padding(24)
}

fn main() {
    let app = gui::application("Counter", "dev.example.counter", || Model { count: 0 }, update, view)
    app.size(320, 160).run().unwrap()
}
```

## What is included

Standard and choice controls, text fields and a code editor, rich documents,
menus, toolbars and command palettes, dialogs (files, colors, fonts, dates,
preferences), virtual lists, tables and trees, tabs, themes and localization,
and screen-reader support. Modules add a terminal, docking, printing and PDF
export, charts, a scene canvas, an image viewer and a media player.

## Install

```toml
# project.toml
[dependencies]
"github.com/gossamer-lang/gui-gos" = { git = "https://github.com/gossamer-lang/gui-gos", tag = "v0.1.0" }
```

Then run `gos fetch`, which also fetches gui-engine-gos and windowing-gos at
their releases. A program that imports `windowing` itself declares it too,
at the tag gui-gos uses. You need Gossamer 0.75.6 or newer and a Rust
toolchain; `tools/check-toolchain.sh` checks the compiler. The first build
compiles the Rust core and SDL; later builds reuse them.

## Examples

```sh
cd examples/hello-world
gos fetch
gos run .
```

`examples/` also has a widgets showcase, a code editor, an application
launcher, a rich-text editor, a terminal, docking, printing, charts, a scene
editor, an image viewer and a media player.

## Documentation

- [Architecture](https://gossamer-lang.org/docs/ecosystem/gui/architecture/): how gui-gos, the Rust core and
  windowing-gos fit together.
- [Capabilities](https://gossamer-lang.org/docs/ecosystem/gui/capabilities/): what works, and its limits.
- [Modules](https://gossamer-lang.org/docs/ecosystem/gui/modules/): terminal, docking, printing, charts, scene
  canvas, image viewer and media player.
- [Editing](https://gossamer-lang.org/docs/ecosystem/gui/editing/), [Rich documents](https://gossamer-lang.org/docs/ecosystem/gui/rich-documents/),
  [Documents](https://gossamer-lang.org/docs/ecosystem/gui/documents/), [Completion](https://gossamer-lang.org/docs/ecosystem/gui/completion/)
- [Theming](https://gossamer-lang.org/docs/ecosystem/gui/theming/), [Localization](https://gossamer-lang.org/docs/ecosystem/gui/localization/),
  [Keyboard](https://gossamer-lang.org/docs/ecosystem/gui/keyboard/), [Accessibility](https://gossamer-lang.org/docs/ecosystem/gui/accessibility/)
- [Custom widgets](https://gossamer-lang.org/docs/ecosystem/gui/custom-widgets/), [Rendering](https://gossamer-lang.org/docs/ecosystem/gui/rendering/),
  [Resources](https://gossamer-lang.org/docs/ecosystem/gui/resources/), [Performance](https://gossamer-lang.org/docs/ecosystem/gui/performance/)
- [Packaging](https://gossamer-lang.org/docs/ecosystem/gui/packaging/), [Dependencies](https://gossamer-lang.org/docs/ecosystem/gui/dependencies/),
  [Testing](https://gossamer-lang.org/docs/ecosystem/gui/testing/), [Toolkit platform](https://gossamer-lang.org/docs/ecosystem/gui/toolkit-platform/)

## Testing

```sh
./quick-check.sh                    # format, lint and type-check
./tests/parity/run.sh               # the suites on the VM, the JIT and both native profiles
./tools/check-examples.sh terminal  # one example's journey on every tier
./tools/check-rust.sh               # the Rust cores and bindings
```

`tools/release-gate.sh OUT` runs every check, packages the examples and
installs them in clean containers. See [Testing](https://gossamer-lang.org/docs/ecosystem/gui/testing/).

## License

Apache 2.0.
