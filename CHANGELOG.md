# Changelog

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
