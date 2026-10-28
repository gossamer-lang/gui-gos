# Code editor

Requires Gossamer 0.75.5+. Run `gos fetch` once for the tagged windowing-gos
and gui-engine-gos releases, then `gos run .`, `gos build .`, or
`gos build --release .` here.
Native executables are `target/{debug,release}/gui-code-editor`.
Pass UTF-8 files after `--` to open them in document tabs. One editor runs per
user: launching it again with files opens them as tabs in the running one.

File and Edit menus expose the same commands as the keyboard. Primary is Ctrl
on Linux and Windows, Command on macOS. Primary+N creates a document,
Primary+O opens files, Primary+S saves, Primary+Shift+S opens Save As, and
Primary+Q reviews unsaved changes before quitting. Save As uses the toolkit
file browser: type a full path or browse folders, choose a filter, and Save.
Cancel and Escape leave the document editable. Replacing an existing file
requires an explicit confirmation. Favorite and recent folders persist per app.

The editor supports Unicode shaping, selection, clipboard, undo/redo, syntax
highlighting for code files (plain text stays uncolored) and word completion.
Primary+F finds and Primary+H replaces, with case and whole-word options, a
match count, F3 and Shift+F3 to step, and one undo for Replace All; Primary+G
goes to a line or `line:column`. The status bar shows the caret's line and
column. Files dropped on the window open as tabs, selected text drags out, and
dropped text is inserted where it lands. Tab inserts a tab character;
Ctrl+Tab and Ctrl+Shift+Tab switch documents. The lexical index is cached between
views and reuses unchanged lines after edits. File reads and writes run on a
worker; saving records the snapshot actually written, so edits made during a
save stay dirty.

Drag a tab to reorder it or drag it outside the strip to open another window.
The tab menu offers the keyboard alternative, Move Tab to New Window.
View > Merge All Windows brings documents back together. Inactive tabs and
transferred pages retain caret, selection, scroll position and undo history.

`SDL_VIDEO_DRIVER=offscreen gos run . -- --fixture` exercises opening, editing,
saving, Save As typing and cancellation, find, replace and go-to, tab
tear-off/merge, and dirty-close review. Native executables accept `--fixture` too. The fixture uses temporary
files and writes diagnostic screenshots under the system temporary directory.

`SDL_VIDEO_DRIVER=offscreen gos run . -- --close-fixture` clicks the actual
Save changes buttons. Cancel preserves the draft, Don't Save exits without
writing, and Save waits for the file worker to commit the draft before exiting.
The check also verifies file contents. Native executables accept
`--close-fixture` too.
