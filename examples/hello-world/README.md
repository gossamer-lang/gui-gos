# Hello world

The smallest gui-gos application: a name field, a Say hello button (also
Enter and Ctrl+G), and a greeting. File > Quit or Ctrl+Q exits; Tab and
Shift+Tab move focus. It follows the system theme.

Run it with `gos fetch` and then `gos run .` (Gossamer 0.75.8 or newer); the
fetch brings windowing-gos and gui-engine-gos at their tagged releases. `gos build .` and `gos build --release .` write
native executables to `target/debug/gui-hello-world` and
`target/release/gui-hello-world`.
