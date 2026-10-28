# Toolkit/platform fixture

Run `gos run .` for temporal draft validation, color preview cancellation and
calendar dialog/focus restoration. Run with `--serve` for a visible native
window and AT-SPI endpoint; it exits normally after 90 seconds.

`--files-fixture` runs only the file-browser journey. It seeds eight recent
locations, creates a folder through the focused field, then checks Back/Forward,
breadcrumbs, hidden files, refresh, filename preservation and Cancel. This
guards against scrolling the toolbar out of reach when focus moves to the list.

`./run.sh` compares VM, forced JIT, debug native and optimized native against
`expected.txt`, retaining output under `GUI_TOOLKIT_OUT` or a temporary folder.
It requires proof that JIT entries were installed. `GUI_TOOLKIT_MEMORY=1` adds
strict Valgrind checks using the caller's system-allocator `GOS_RUNTIME_LIB`.
No leak suppressions are accepted.

On Linux X11, `./atspi.sh` builds the server, starts a private D-Bus session and
runtime directory, discovers the time field by accessible identity and edits
it through the native AT-SPI bus. It touches only its own application and waits
for graceful shutdown. `GUI_ATSPI_OUT` chooses the retained report directory.
This protocol check does not replace an Orca acceptance run.

The probe also parses live introspection XML, checks the signed 16-bit stacking
order reply and reads the application protocol version. It requires Python 3
and `gdbus`. Set `GUI_ATSPI_MEMORY=1` and supply a system-allocator
`GOS_RUNTIME_LIB` to run the same private-bus journey under strict Valgrind.

Focused unit tests cover date edges and DST, CSS/alpha/hue, picker transactions,
favorite persistence, catalog substitution, native protocol/action validation
and non-overlapping color labels at 100%/200% text and fractional scale.

Set `GUI_ATSPI_RELEASE=1` to build the real bus probe with optimized dynamic native
code. It can be combined with `GUI_ATSPI_MEMORY=1` for a strict release audit.
