# Widget showcase

Requires Gossamer 0.75.5+. Run `gos fetch` once for the tagged windowing-gos
and gui-engine-gos releases, then `gos run .`, `gos build .`, or
`gos build --release .` here. Native executable:
`target/{debug,release}/gui-widgets-showcase`.

Every control is wired to something it changes:

- **Controls**: a name that fills a greeting, a port field checked as you
  type, a text size chosen from a menu or radio buttons, a view switch that
  shows a folder as a list, grid or table, a license checkbox that enables
  Install, notification checkboxes under one "All" box, a volume slider with
  its spin box and meter, and buttons (copy, a menu, a split button). A
  switch enables or disables the sample row of controls.
- **Collections**: the same twenty files as a list (rows drag out as text),
  a sortable table, an icon grid and a folder tree.
- **Dialogs**: information, warning, error, unsaved changes, rename, open,
  save, folder, color, font, date, preferences, a two-page wizard and About.
  The Desktop section shows a toast, sends a notification, shows a tray
  icon, and offers a
  card that drags its file into another application.
- **Date and color**: date, time and duration fields, a calendar and the
  color picker.
- **Navigation**: a breadcrumb, a toolbar (right to left, smaller and larger
  text), the appearance switches (theme, density, display scale, text size),
  a mail-folder sidebar and a disclosure.

View > Reset (Primary+R) restores every control; Help > About (Primary+I)
opens the About dialog.

`SDL_VIDEO_DRIVER=offscreen gos run . -- --fixture` checks that Install waits
for the license, the port field reports bad input and accepts a good port,
the view switch shows a table, a disabled control takes no focus, the
keyboard reaches the last file, a dialog closes on Escape, and the
appearance switches apply. Native binaries accept `--fixture` directly.
