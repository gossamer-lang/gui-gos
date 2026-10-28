# webview

Web pages for gui-gos applications, rendered by WebKitGTK 4.1. It is a
separate package: applications that do not depend on it link no WebKit, GTK
or GLib.

```toml
[dependencies]
"dev.gossamer/gui-webview" = { path = "../../modules/webview" }
```

## How it works

WebKitGTK renders each page into a GTK offscreen window on an engine thread
of its own. GTK and WebKit are called only from that thread. The application
sends commands over a channel and wakes the thread with a GLib idle callback.
When a page repaints, the engine copies the window's pixels into a `Frame` and
reports `Event::Painted`. `webview::widget` paints the latest frame and
forwards pointer, wheel, key, text and focus input as GDK events. Every event
reaches the session as `UiMsg::Custom(webview::WAKE, "")`; `Engine::events`
answers what arrived.

```gossamer
let engine, runner = webview::engine()
let mut session = app(engine).start()?
let runner = runner.posting_to(session.mailbox())
cohort(isolation: Isolation::Thread) {
    let _ = spawn(|| webview::run(runner))
    result = session.run()
    engine.shutdown()
}?
```

A `Page` loads URIs or HTML, reloads, stops, goes back and forward, runs
scripts (`Event::Script`), downloads (`Event::Download*`), saves and restores
its history (`save_session`, `restore_session`), and can end its web process
(`terminate`, reported like a crash through `Event::Crashed`). Permission
requests arrive as `Event::Permission` and are answered with
`Engine::answer_permission`; requests for a new window arrive as
`Event::NewWindow`.

## Limits

- Linux only. Elsewhere `run` reports `Event::Unavailable` and returns an error.
- A display is required: GTK opens one even for offscreen windows. Without it
  the engine reports `Event::Unavailable`.
- Pages render in software (WebKit's hardware acceleration is off) so their
  pixels can be read; each repaint copies the whole page.
- Input method composition is not forwarded; committed text is.
- Pages are not reported to assistive technology beyond the view's name.
