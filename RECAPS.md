# Recaps

Running log of completed work on the PaddleBoard marketing site, newest first. Each `## YYYY-MM-DD` groups a day; each `### ` is one coherent unit of work.

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
