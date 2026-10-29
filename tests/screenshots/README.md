# Screenshot tests

Each scene renders offscreen at scale 1 with the embedded DejaVu fonts only
(`text::fonts::use_system_fonts(false)`), so the pixels do not depend on the
machine's installed fonts. The runs reach no session bus, so the desktop's
settings (its menu font size, accent and contrast) do not reach them either. A scene's capture must equal its golden PNG in
`golden/` exactly.

| Scene | Shows |
|---|---|
| `controls-light`, `controls-dark`, `controls-high-contrast` | Buttons, checkboxes, switch, field, select, slider and progress in each theme |
| `controls-rtl` | The same controls laid out right to left |
| `text` | Wrapping, combining marks, Greek and Cyrillic, mixed direction, monospace, muted text |
| `selection` | A focused field with all its text selected beside an unfocused area |
| `menu` | The drawn menu bar with its first menu open by keyboard |
| `dialog` | A destructive confirmation over the window |
| `table` | A sorted two-column list with a selected row |

```sh
./tests/screenshots/run.sh
```

runs every scene on the VM, forced JIT, debug native and release native.
A mismatch writes the capture as `<scene>-actual.png` in the tier's report
directory and fails; set `GUI_SCREENSHOT_REPORT` to keep the reports.

After an intended rendering change, regenerate the goldens and review each
image before keeping it:

```sh
cd tests/screenshots
env DBUS_SESSION_BUS_ADDRESS=disabled: XDG_RUNTIME_DIR="$(mktemp -d)" \
    SDL_VIDEO_DRIVER=offscreen GUI_SCREENSHOT_UPDATE=1 gos run . golden
```
