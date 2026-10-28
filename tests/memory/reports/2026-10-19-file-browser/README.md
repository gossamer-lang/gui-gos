# File browser navigation and ownership

The browser now implements bounded Back/Forward history, relative locations,
breadcrumbs, refresh, persistent hidden-file preferences and inline new-folder
creation. Invalid names and failed navigation preserve editable state. The Save
filename survives navigation, and folder creation restores focus to the list.

A populated recent list exposed nested scrolling: focusing the entries scrolled
the whole browser body and moved Back out of reach. The browser now receives a
bounded body and scrolls only its places and entries. Other picker templates
retain their own body scrolling. The original history failure is retained.

`--files-fixture` seeds eight recent locations before exercising creation,
focus, history, breadcrumbs, hidden files, refresh and Cancel. Its transcript
matches VM, forced JIT (129 + 65 installed entries), debug native and optimized
native. The complete seven-line toolkit journey also passes both native tiers.
All 142 GUI tests and 974 assertions pass with the final layout.

Both strict system-allocator native Valgrind runs report zero definite,
indirect or possible losses and zero errors, without suppressions. Reachable
storage is 7,678 bytes in 43 blocks. The typed-reader fallback fix is required;
the earlier archive leaked 540 bytes during repeated settings decoding.

Compiler, runtime, source and executable hashes are retained. These finite
journeys do not close asynchronous-directory IO, platform or long-running
resource gates, or the separate JSON-in-struct compiler ownership issue.
