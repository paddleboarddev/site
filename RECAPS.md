# Recaps

Running log of completed work on the PaddleBoard marketing site, newest first. Each `## YYYY-MM-DD` groups a day; each `### ` is one coherent unit of work.

## 2026-07-29

### Rebuild the home page as an editor-native design

- **Ported the approved prototype into the real Hugo templates.** The diagnosis was structural: centred hero + radial glow → eyebrow pill → 999px buttons → three-across icon-card grid → CTA band, in a `-apple-system` stack. That is the default shape of an LLM-generated dev-tool page, so **most of this change is deletion.**
- **Type and colour are the product's own.** Lilex + IBM Plex Sans (what `.ZedMono`/`.ZedSans` resolve to) self-hosted from the app's OFL files with licences; every colour lifted from `paddleboard.json`. That makes "editor-native" literal, and costs nothing — the page and the screenshots inside it now agree rather than merely coordinate.
- **The device:** a line-number gutter down the page, section labels coloured as real syntax tokens, and the app's status bar as the final line (static, not fixed — a pinned bar is a real cost on a phone).
- **Six narrative sections replace ten icon cards**, each anchored to a real v0.2.0 screenshot shot against `samples/demo`. Copy lives in `hugo.toml` under `[[params.sections]]` so wording stays editable without touching markup. Scion is last and deliberately quieter (muted label, dashed rule, "add-on" in the label) because it is opt-in and self-installed.
- **Preserved deliberately:** every SEO surface (title, description, keywords, canonical, OG/Twitter, `SoftwareApplication` JSON-LD, `robots: index, follow`), the keyword-bearing prose section from `content/_index.md`, all footer attribution, and the release CTAs from PR #22. The ten feature descriptions survive as a dense two-column list rather than a card grid, so no content was lost.
- 🐛 **Two bugs found by measuring rather than looking**, both of which would have shipped silently: `overflow:hidden` on `main` (added to clip the gutter) made it a scroll container and **broke in-page anchors including the nav's own `#features` link**; and flipping alternate rows with `order` left the screenshot in the narrow `7fr` track, so **every other image rendered 22% smaller** (measured 457/587, now uniformly 587).
- **Fidelity call:** the gutter was first a repeating CSS gradient — cheaper, no DOM — but it renders as tick marks, and "line numbers" is the entire device. Reverted to real numbers, clipped.
- **Re-verified the prototype's specificity trap** (`.feat p` at `0,1,1` beating `.tok-kw` at `0,1,0`, which silently greys every token). All six colours compute correctly; the CSS carries a comment explaining why that specificity is load-bearing.
- Shipped as [PR #23](https://github.com/paddleboarddev/site/pull/23), not merged — this one changes what every visitor sees and wants a look on a real screen first.
- **Follow-ups:** `/update-site` still writes an `icon` field nothing renders and knows nothing about `[[params.sections]]`. The "Also in the box" list is the most likely cut — it preserves content and SEO but is not in the approved design, and is one `{{ range }}` to remove.

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
