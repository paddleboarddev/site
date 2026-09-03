+++
title = "PaddleBoard is in beta"
description = "What beta means here, the bar we hold ourselves to, and what we already know is rough."
eyebrow = "Version 0.3.0 · 9 September 2026"
layout = "beta"
date = 2026-09-02
+++

## What beta means here

It means the shape is settled. The features on this site are the features we
intend to have; we're not going to pull the rug on how personas work or where the
sandbox lives. What's left is the gap between "works on the machines we tested
it on" and "works on yours."

It does not mean feature-complete, and it does not mean bug-free. It means the
bugs that remain are the ones we haven't found yet rather than the ones we
already know about and shipped anyway.

## The stability bar

**What we hold ourselves to:**

- **Your files are not the experiment.** Editing, saving, LSP, git, the terminal
  and the debugger are Zed's, essentially unmodified, and they carry Zed's
  reliability. Nothing PaddleBoard adds sits between you and your buffer.
- **Nothing leaves your machine unless you point it somewhere.** Telemetry is
  disabled at the call site, not behind a setting. Local models run locally. The
  RAG index is a SQLite file in your project. Usage tracking writes plain JSON to
  your disk. The only outbound traffic is to the model provider you configured,
  the update check, and things you explicitly ask for — a deploy, a git push.
- **Agents don't execute code on your host by default.** Tool calls that run code
  go into a sandbox. If the sandbox runtime is missing, the default is to *block*
  and offer to install it — not to quietly fall back to running on your machine.
- **Downgrades stay possible.** Settings are additive; we don't rewrite your
  config into a format an older build can't read. If a release breaks something
  for you, the previous version is on the releases page and will still open your
  projects.

**What we don't promise yet:**

- That every code path has been exercised on hardware unlike ours.
- That the newer surfaces — Set Sail, the RAG index, the built-in sandbox tier,
  Scion — are as battle-tested as the editor underneath them. They are the newest
  code and the most likely to surprise you.
- That the UI is finished. Some of it is honestly rough, and the list below says
  where.

## Known issues

Current as of 0.3.0. We'd rather you read this than discover it.

**Platforms**

- macOS builds are **Apple Silicon only**. No Intel build.
- Linux ships as an **x86_64 tarball** — no `.deb`, no `.rpm`, no AppImage yet.
- **Windows builds from source.** There's no packaged Windows download.
- In-app updates work on macOS and Linux.

**Rough edges we know about**

- Several status-bar icons have no visible label, so what they do isn't
  discoverable without hovering.
- Every MCP server in the catalog shares one generic icon.
- The default keymap selector shows "Zed" as an option name, which is accurate —
  it is Zed's keymap — but reads oddly inside a different product.

**Opt-in by design, so they look missing until you turn them on**

- **Java, Kotlin, PHP, C#, C++** language servers are opt-in — run
  `Manage Languages` from the command palette. This is deliberate: each needs an
  external toolchain, and we'd rather show you the prerequisite than fail
  silently when it's absent.
- **Scion** parallel-agent support requires `go install` and an explicit
  `"paddleboard_scion": { "enabled": true }`. Installing the CLI alone doesn't
  activate it.
- The **pgvector** RAG backend is a compile-time feature; the default build uses
  the local SQLite store.

**Caveats worth stating**

- Placid mode hides the docks and centers the editor, but not the tab bar,
  status bar or gutter. Those are global settings read in ~1,100 places, so
  scoping them per-window is a settings-system refactor, not a toggle.
- TLS against a remote pgvector instance is untested. 🔍
- Set Sail hands interactive auth to your terminal rather than running it. That's
  intentional, but it means a deploy isn't fully hands-off the first time.

## How to report something

**[GitHub Discussions](https://github.com/paddleboarddev/paddleboard/discussions)**
is the front door — there's a Beta Feedback category. Bugs with a reproduction
are better as [issues](https://github.com/paddleboarddev/paddleboard/issues).

This matters more here than in most betas. **With telemetry off, you telling us
is the only signal that exists.** We can't see a crash you didn't report, we
can't count how many people bounced off onboarding, and we don't know which
features go unused. That's the trade we chose, and it only works if the reporting
path is easy.

Useful things to include: your OS and chip, the PaddleBoard version, which model
provider you're on, and what you expected instead. Logs live in
`~/Library/Logs/PaddleBoard/` on macOS.

## What happens after beta

Weekly changelog threads in Discussions, weekly upstream Zed merges, and 1.0 when
the known-issues list above is short enough to be boring. No date on that — a
date would be a guess, and you'd hold us to it.
