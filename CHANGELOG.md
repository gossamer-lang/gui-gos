# Changelog

## 0.1.6 - Global shortcuts, fetching and window visibility

- Requires Gossamer 0.76.0 or later.
- Builds on gui-engine-gos 0.1.6 and windowing-gos 0.1.4.
- `services::work::Operation::Fetch` GETs a URL on the session's worker and answers `Outcome::Fetched` with the status and body.
- `Effect::RegisterHotkey` and `UnregisterHotkey`, answered by `UiMsg::Hotkey`; `Effect::SetWindowVisible`, `SetAlwaysOnTop` and `DockTop`.
- `ViewOptions::scrollbar_side`, `terminal::Event::Focused`, and `ThemeOverride`'s `surface` and `field`.
- `TextInput::family` sets a field's text in an installed font family, and `TextInput::font_points` sets its size in points; a line field's height follows that size.
- A right click leaves a context menu open even where it opens under the pointer.
- `UiMsg::DockResized` reports a docked window the user resized as fractions of its display.
- Dialog buttons carry keyboard accelerators, and the arrow keys move between them.
- `Widget::joined_tab_pages` is a joined strip whose tabs keep their pages and can leave it: to a new window from the tab menu or by dragging out of the window, or into another window's strip of the same workspace.

## 0.1.5 - Gossamer 0.75.17, terminal copy mode, link hints and saving

- Requires Gossamer 0.75.17 or later.
- Builds on gui-engine-gos 0.1.5 and windowing-gos 0.1.3: terminals show output about twice as fast, typed input sooner, and frames evenly under a flood; a terminal's history is bounded by memory; pastes of up to 16 MiB stream; programs can use kitty's keyboard protocol; and holding a spin box's - or + button keeps stepping.
- `Terminal::copy_mode` starts copy mode, which selects and copies with the keyboard across the screen and the history.
- `Terminal::hints` labels the links on the screen for a key to open or copy them; `Terminal::leave_mode` ends either mode.
- `Terminal::save_text` writes a terminal's history or selection to a file, with wrapped rows joined into their lines.
- `App::remember_size(false)` opens windows at the size the application gives them instead of the size they last closed at; they still open where they were.

## 0.1.4 - Accent overrides, activation tokens and SVG icons

- Builds on gui-engine-gos 0.1.4.
- `ThemeOverride` takes an `accent` color for its subtree, which also colors selected rows and completion highlights.
- `Session::activate_window` takes an optional Wayland activation token.
- `AppIcon::from_svg` draws an SVG document as an application icon, such as one embedded with a `comptime` read.

## 0.1.3 - Terminal and settings options

- Builds on gui-engine-gos 0.1.3 and windowing-gos 0.1.1.
- `terminal::ViewOptions` sets how a terminal view draws and behaves; `Terminal::clear_scrollback` erases its history; snapshots name the foreground job; `Event::PasteHeld` asks before a risky paste.
- `PreferenceKind::Action`, `Effect::SetWindowSize`, `Effect::SetTransparent` (open windows included) and `App::transparent`.
- `TextStyle::ligatures` and the terminal view's font weight and ligatures.
- The find bar offers earlier searches.

## 0.1.2 - Dialog windows

- Builds on gui-engine-gos 0.1.2: preferences and wizards open in a window of their own that can be moved and resized, long popup lists scroll, and preference help wraps.

## 0.1.1 - Engine 0.1.1

- Builds on gui-engine-gos 0.1.1: on Linux, an application whose link order marks its startup-only code releases that code once its first frame is shown, and terminal scrollback lines are stored at their exact size.

## 0.1.0

- Initial version.
