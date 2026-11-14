# Changelog

## 0.2.9 - Program status and attention requests

- `terminal::Event::Status` carries what a terminal's program reports of its state (OSC 7501): idle, working, blocked with what it waits for, done, error, or clear, with its app name, task id, progress and message.
- `terminal::Event::Attention` reports a program's request for attention (OSC 1337 RequestAttention), and kitty's notifications (OSC 99) arrive as `Event::Notify`.
- Builds on gui-engine-gos 0.2.21.

## 0.2.8 - Folder watches, mailbox at start

- `Effect::WatchFolder` delivers `UiMsg::FolderChanged` once as the watch begins and then each time a file in the folder is made, removed, renamed or written, from a thread that runs only while the watch does; `Effect::UnwatchFolder` ends it.
- `App::on_mailbox` hands the session's mailbox to the application once the session starts, so a goroutine started before it runs, such as one waiting on a file, can post it messages.
- Builds on gui-engine-gos 0.2.20.

## 0.2.7 - One clipboard

- `services::clipboard` uses the engine's clipboard, so `use_memory(true)` also catches a terminal's own copies and a program's OSC 52 writes, which before reached only the system clipboard. Builds on gui-engine-gos 0.2.18.
- Each module imports what it uses, so the library builds with a Gossamer that keeps a module's imports to itself.

## 0.2.6 - System fonts from the first frame

- `text::fonts::preload` readies an installed family before any text needs it, asking fontconfig, Core Text or the Windows font registry for its files, so the first frame already draws in it instead of switching to it once the installed fonts are read.
- `text::fonts::register_file` and `text::fonts::register` add a font file or font data, every face of a collection, at once.
- A family named by its style-specific name ("Lilex Light" of the family "Lilex"), as fontconfig and desktop settings name it, draws in that face instead of the fallback. `FontRecord::legacy_family` carries that name.
- A registered variable font with no bold face beside it also draws its family's bold.
- A timer no longer wakes the event loop before it is due when the system clock is being corrected.
- Builds on gui-engine-gos 0.2.17 and windowing-gos 0.1.19.

## 0.2.5 - Shells start at their window's size

- A terminal's program starts once its view sizes the screen, so a shell draws its first prompt once. `terminal::Event::NotStarted` reports a program that could not start then.
- `Widget::quick_pick` lists an application's own items the way the palette lists commands, narrowed to those holding what is typed, and reports the one chosen.
- Closing a terminal hangs it up instead of killing its program, so a shell saves its history before it ends.
- `terminal::Event::Foreground` names the job running in front of a terminal's program and its directory, each time either changes.
- The command palette finds the commands holding what is typed anywhere in their name, which it shows after its category ("View: Zoom In"), and Tab completes the search to the highlighted command. It shows as one panel, only as tall as the commands it lists.
- Builds on gui-engine-gos 0.2.14 and windowing-gos 0.1.17: lighter repaints and less CPU for terminal output, and on macOS scrolling without copying and a cursor that blinks without repainting.

## 0.2.4 - Quieter when idle, faster when scrolling

- Builds on gui-engine-gos 0.2.9: a caret stops blinking and stays lit 10 seconds after the last input or terminal output, and terminal output that scrolls past a full scrollback parses about 20% faster.
- Builds on windowing-gos 0.1.13: on macOS, quiet windows free their spare display buffers and programs load fewer system frameworks.

## 0.2.3 - Optional engine parts

- The engine's optional parts are features of gui-gos too (`markup`, `svg`, `jpeg`, `gif`), all on by default; an application that depends on gui-gos and gui-engine-gos with `default-features = false` builds without them.
- Builds on gui-engine-gos 0.2.8, which also fixes a large paste stalling in a terminal, and windowing-gos 0.1.12, whose SDL no longer loses a wake from another thread. Requires Gossamer 0.78.1.

## 0.2.2 - Less CPU for terminal output

- Builds on gui-engine-gos 0.2.7: a terminal whose output scrolls draws only the rows that came in, and a frame's raster work runs on workers that stay parked between frames.

## 0.2.1 - FreeBSD desktops

- Builds on windowing-gos 0.1.11 and gui-engine-gos 0.2.6: installed fallback fonts are mapped instead of read into memory, hidden windows let their frames go, Wayland windows present through shared memory without loading the GPU driver, and windows under libdecor no longer hang while they open.
- Applications run on FreeBSD desktops (X11 or Wayland, with a D-Bus session bus) as they do on Linux: settings and caches under `$XDG_CONFIG_HOME` and `$XDG_CACHE_HOME`, the installed-application list from desktop entries, and the single-instance claim. The release gate runs there with its portable profile.
- The web view renders pages and runs scripts through WebKitGTK 4.1 on FreeBSD (`pkg install webkit2-gtk_41`), as on Linux.

## 0.2.0 - Event and command names

- Builds on gui-engine-gos 0.2.1.
- The first character typed in a terminal after a full screen TUI app that used kitty's keyboard protocol exits on Ctrl+C or Ctrl+D reaches the shell; it used to be dropped.
- New text in a field with completions highlights its best match, instead of keeping the row chosen for the earlier text.
- A window's close button, or any request from the desktop to close a window, leaves the modal dialog it shows open and focuses the window; a second close request no longer cancels a question such as a confirmation to close.
- A terminal narrowed while a full-screen program runs over a full scrollback returns its shell prompt to its own line, at column zero, when the program exits.
- `UiMsg` events are named for what happened: `Clicked`, `Toggled`, `Checked`, `Chosen`, `Submitted`, `Selected`, `SelectedMany`, `Expanded`, `Activated`, `Reordered`, `SortRequested`, `OpenRequested`, `OpenUriRequested`, `TextChanged`, `CaretMoved`, `ValueChanged`, `RangeChanged`, `ColorChanged`, `DateChanged`, `TabSelected`, `SplitMoved`, `CellEdited`, `ColumnResized`, `TabMoved`, `TabDropped`, `TabDetached`, `TabMovedToWindow`, `TabDocked`, `WorkFinished`, `PrintProgress` and `WindowFocusChanged` replace `Click`, `Toggle`, `Check`, `Choose`, `Submit`, `Select`, `SelectMany`, `Expand`, `Activate`, `Reorder`, `Sort`, `Open`, `OpenUri`, `Text`, `Caret`, `Value`, `Range`, `Color`, `Date`, `Tab`, `Split`, `CellEdit`, `ColumnResize`, `TabMove`, `TabDrop`, `TabDetach`, `TabToWindow`, `Dock`, `Worked`, `Print` and `WindowFocus`.
- `Effect` commands say what they do: `StartTimer`, `StartWork`, `ShowToast`, `SetCommands`, `AnswerCompletion`, `AnswerDialogCheck` and `FocusInWindow` replace `Timer`, `Work`, `Toast`, `Commands`, `Complete`, `DialogChecked` and `FocusIn`.
- State reads as nouns: `ChoiceState.highlighted` and `highlighted_index()`, `EditState.undo_stack` and `redo_stack`, `CompletionItem.insert_text`, `TextInput.validator` and the input dialog's `validator`, `Scroll.fits_content`, `Collection.drag_offer`, `Modifiers.drag_source`, `ScrollState.drag_offset`, and `CollectionState.dragged_column`, `editing_row`, `editing_column`, `dragged_row`, `dragged_row_index` and `dragged_row_y`.
- Methods say what they do: `StateStore::edit_state`, `choice_state` and `drag_state`, `ChoiceState::type_ahead`, `FindBar::set_matches`, `ModelLog::record_removal` and `record_move`, `App::initial_focus`, `CommandTable::is_chord_pending`, `Document::is_layout_ready`, and `Terminal::set_highlights`.
- A check control draws as a box or a switch by `kind: CheckKind` instead of `switch: bool`.

## 0.1.7 - Docking, tab drops and forwarded command lines

- Builds on gui-engine-gos 0.1.8 and windowing-gos 0.1.8: on X11 every press of a global shortcut arrives, and a window it brings forward takes focus.
- `Effect::Dock(window, Edge, length, depth)` docks a window along any edge of its display, and `Effect::SetOnAllDesktops` shows it on every virtual desktop (X11, macOS); a docked window resizes from its edge facing the display.
- `UiMsg::TabToWindow(strip, key, window)` reports a tab dropped onto another window away from any strip there.
- `App::single_instance_command_line(arguments)` hands a later launch's command line to the running instance as `UiMsg::CommandLine(directory, arguments)`, and `App::instance(name)` names the instance apart from the app id.

## 0.1.6 - Global shortcuts, fetching and window visibility

- Requires Gossamer 0.76.0 or later.
- Builds on gui-engine-gos 0.1.7 and windowing-gos 0.1.5.
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
