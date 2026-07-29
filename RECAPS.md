# Recaps

Running log of completed work on the PaddleBoard marketing site, newest first. Each `## YYYY-MM-DD` groups a day; each `### ` is one coherent unit of work.

## 2026-07-29

### Point every call to action at the signed release

- **The page contradicted itself.** The hero read `alpha (build from source)` with a primary button of **Get the source**, and the **header nav's primary button said the same** — while the CTA band at the foot of the same page correctly described a code-signed, notarized macOS build. The top told visitors to compile it themselves; the bottom offered them a binary. PR #20 fixed the band and missed the other two. The "alpha" framing stopped being true at **v0.1.14**.
- **All three primary actions** (nav, hero, band) now read **Download** and point at `releases/latest`. The eyebrow states the real status: `v0.2.0, signed & notarized`.
- **Intentionally preserved:** the hero's secondary **Read the docs** button, and the **GitHub** nav link — people who want to build from source still reach the repo in one click, so nothing was lost by demoting "Get the source".
- **JSON-LD `downloadUrl`** moved from the repo root to `releases/latest`, so structured data describes the artifact rather than the source tree.
- **Verified against the live release rather than assumed** — this mattered because the version number now appears in the hero: `v0.2.0` is public, not a draft or prerelease (published 2026-07-21); `releases/latest` returns 200; assets are `PaddleBoard-aarch64.dmg` (161 MB) and `paddleboard-linux-x86_64.tar.gz` (163 MB), so both the signed-macOS and Linux-tarball claims hold. Clean `hugo --gc --minify`; rendered output has three `releases/latest` links and zero occurrences of "alpha (build from source)", "Get the source", "binaries are on the way", or "Gatekeeper bypass".
- ⚠️ **Process note:** I first reported this as "the notarization copy never reached main" from a stale `origin/main` I had not fetched. That was wrong — #20 merged (`9802aee`). Reading the live page is what found the real, narrower defect. **Fetch before asserting what is deployed, or just read the deployed page.**
- Shipped as [PR #22](https://github.com/paddleboarddev/site/pull/22); deploys to paddleboard.dev on merge. Independent of the redesign — it fixes copy that is wrong for every visitor today.

## 2026-07-20

### Correct release status and add a first-launch feature card

- **Fixed a materially wrong CTA band.** `layouts/index.html` still told visitors PaddleBoard "built from source today — released binaries are on the way" and that builds "aren't notarized by Apple yet, so distributed macOS apps will need a Gatekeeper bypass." All untrue since **v0.1.14** — every release publishes a signed, notarized macOS DMG plus a Linux x86_64 tarball. Verified against the actual published release assets before rewriting. The primary button was also sending people to build from source; it now points at Releases and reads **Download**.
- **New feature card** (`hugo.toml`): *🎨 Ready from first launch* — PaddleBoard's own default theme, onboarding that connects a model (locally with no API key, or bring your own), and a short guided tour. The v0.2.0 headline.
- **Intentionally left alone:** the `version` param (`publish-public.sh` bumps it at release time, and the `v0.2.0` tag isn't public yet), the tagline/subtitle/SEO params (the README's pitch didn't drift), and all layout/CSS.
- Built clean with `hugo --gc --minify` (4 pages, no warnings). Shipped as [PR #20](https://github.com/paddleboarddev/site/pull/20); deploys to paddleboard.dev on merge.

## 2026-07-05

### Add maintainer credit to the footer

- Added "Made by [Jason (Jay) Smith](https://jasonsmith.io)" to the footer's legal line in `layouts/_default/baseof.html`, appended to the existing copyright line with the same ` · ` separator style used for the version badge.
- Built locally with `hugo --gc --minify` (4 pages, no errors) and confirmed the credit renders in `public/index.html` with the link pointing at https://jasonsmith.io. `public/` is gitignored (built by CI on deploy), so the change is template-only.
- Shipped as [PR #17](https://github.com/paddleboarddev/site/pull/17).
