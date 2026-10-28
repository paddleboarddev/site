# Changelog

Changes to paddleboard.dev that a visitor would notice, newest first. The site
has no versions of its own, so entries are dated by the day they went live.
Why each change was made lives in [RECAPS.md](RECAPS.md).

## 2026-10-28

### Added
- The engineering post [The Worst Bugs in a Fork Don't Break the Build](https://paddleboard.dev/blog/worst-bugs-in-a-fork/).
- A "Coming in 0.3.1" note on the beta page, listing the macOS window-button fix and a security update.
- A Reddit link (r/paddleboarddev) in the footer's Community column.
- On the beta page: where logs live on Linux, and a caveat that long threads on the managed local model end sooner, because it runs with an 8K context.

### Fixed
- The sandbox card on the home page said the built-in tier needs nothing installed. It needs libkrun from Homebrew first, and only your project folder is shared with it.

### Removed
- The "coming soon" date strip under the navigation. v0.3.0 is out, so the beta page now shows the version alone.
