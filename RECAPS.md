# Recaps

Running log of completed work on the PaddleBoard marketing site, newest first. Each `## YYYY-MM-DD` groups a day; each `### ` is one coherent unit of work.

## 2026-09-02

### Beta promises page — live at /beta, one week before launch

- **`content/beta.md` + `layouts/_default/beta.html`**, from the 2026-08-11 draft. This
  was a **blocking dependency**: the v0.3.0 release notes, the README and the Show HN
  first comment all link to it, and the plan requires it up *before* launch morning.
- **Its own layout, not `single.html`.** The post template stamps a date, a reading time
  and an "All posts" link — right for an article, wrong for a standing statement. A
  visible date invites "is this still true?", the one doubt this page exists to remove.
  The gutter rail stays, since that is what makes the page look like the product.
- ⚠️ **The draft still said "released 26 August 2026"** — the pre-move launch date.
  Corrected to 9 September in the front-matter eyebrow. Anything else drafted before
  2026-08-14 may carry the same stale date.
- **Linked from the footer's Project column, not the top nav.** `main.css` warns that a
  fifth nav link degrades the strip to scrolling, which can push **Download** off a
  phone — the same reason Blog lives there.
- **Known-issues list swept before publishing**, as the draft demands (it went stale
  once, two of five rough edges fixed two days after drafting). All three still hold:
  unlabelled status-bar icons, 5 catalog MCP servers sharing one generic icon, and the
  keymap selector showing "Zed" — each re-verified against the code today.
- ⏸️ **Open question left for Jay, deliberately not decided:** whether to list
  jasonsmithio/paddleboard#200 (the AI Dock intermittently not opening from the command
  palette). It is unresolved and affects a headline feature, and the page's ethos is
  "we'd rather you read this than discover it" — but it is his call, so it is not in
  the diff.
- ⚠️ **Deploy is not done until the Firebase edge cache is purged** and the page is
  verified from an external vantage.

## 2026-08-24

### setsail card — the modal, without ever pressing deploy

- **`static/video/setsail.{mp4,webm}` + poster**, wired into the `set sail` section.
  7.37s at `SPEED=2.0`; loop seam measured at 0.0004 average luma.
- **Shows both halves of the caption without side effects**: the `Quick deploy` /
  `Rig the pipeline` toggle and the 2x3 platform grid (Cloud Run, AWS Lambda, Vercel,
  Azure, Cloudflare, Netlify). The clip clicks platforms and modes, returns to the
  opening state, and **never presses confirm** — that fetches SKILL.md files into the
  project and seeds an agent thread, and on the Cloud Run path leads to billable
  resources. Everything the caption claims is visible before that button.
- ⚠️ **This card is squarer than its neighbours** — the modal is 1084x918 (1.18) where
  the other clips are ~1.56 — so it renders taller in the two-column layout. Cropping
  wider was tried and rejected: the backdrop is the onboarding page, and a margin crop
  put chopped half-words along both edges, which reads as a mistake.
- Requested 15.8s of source but the take yielded 14.7s, so the clip is 7.37s not 7.9s.
  Harmless here — the end state still matches the start — but another reminder that the
  encoder's output length is not the number you asked for.

### dock card — the agents list, scrolled and looped

- **`static/video/dock.{mp4,webm}` + poster**, wired into the `dock` section. 7.07s:
  the Agents list from Claude / Codex / Copilot / Cursor / Antigravity down through
  ADK / LangGraph / CrewAI / AutoGen / A2A, and back to the top.
- **Verified the loop numerically** rather than by eye — first frame against last
  differs by 0.00017 average luma, so the seam is invisible.
- **Shot the agents list rather than the tab sweep the plan called for.** Two of the
  five tabs are unshootable on a real machine: **MCP Servers** shows personal servers
  (and had a live `Context server request timeout`), **Usage** shows real token counts.
  The caption is about Agents anyway, and eleven agents overflow the modal, so the
  scroll is honest motion.
- **New `SPEED=` in `encode-clips.sh`.** The round trip ran 12s — too long for a card,
  and cutting half of it would have broken the loop. 1.7x keeps both ends.
- ⚠️ **`-t` caps the duration AFTER the speed filter**, so a raw `-t 12` returned 9.57s
  of a differently-framed window. The script now divides by `SPEED`, keeping the
  caller's duration meaning "seconds of the source take" either way. Second time in one
  session that trimming silently produced the wrong length — check durations, always.

### Feature cards can carry video — persona is the first

- **`layouts/index.html` renders `<video>` when a section defines `video`**, and falls
  back to `<img>` otherwise, so the five un-shot cards are untouched. webm `<source>`
  first, mp4 second; `autoplay muted loop playsinline preload="metadata"`.
- **Reduced motion is handled without JS.** Each motion card also emits its poster as
  `.shot-still`, hidden by default and swapped for the clip under
  `prefers-reduced-motion: reduce`. A card that loops forever is exactly what that
  preference is for, and this site carries no JS beyond JSON-LD.
- **New assets:** `static/video/persona.{mp4,webm}` (82KB / 124KB) and
  `static/img/persona-poster.jpg`. 6.5s, cropped to the AI Dock modal so the persona
  rows stay legible at card width (~590px on a desktop layout).
- The clip shows the QA Engineer row flipping from "Add to project" to
  "Installed (Project)" — a starter persona adopted in one click, which is the half of
  the caption a still could never carry.
- ⚠️ **`-ss`/`-t` before `-i` silently mis-cuts these takes.** `screencapture` writes
  variable-frame-rate movies, so fast input seeking lands on the nearest keyframe: a
  6.5s cut came out 7.5s in both encodes. `encode-clips.sh` now seeks after the input.
  Verify the duration of anything it produces rather than trusting the arguments.
- ⏸️ **Unverified:** autoplay and looping in a real browser. The markup, CSS, decode
  and durations all check out, but the pane used for verification reported a 0x0
  viewport, which cannot autoplay. Eyeball before merging.

### models card re-shot — the old asset contradicted its own caption

- Replaced `static/img/models.png` on branch `models-card-refresh` (**uncommitted**).
  1600x1004 as before, downscaled from a 3022x1896 2x capture; 258KB → 156KB.
- ⚠️ **The July asset undercut the caption it sits under.** Captioned *"Every provider
  in one list — including Local Models"*, it showed the model **picker** with
  **Google AI marked `default`** and **Local Models marked ✗ (unconfigured)** — a cloud
  provider as the default, on the card arguing local is first-class. The new shot is
  the **LLM Providers settings page** with Local Models ✓ and no cloud default.
- **Zed now sorts last** in that list (PaddleBoard PR pending on the app side), so the
  card no longer opens on upstream's name.
- **Stays a still, deliberately.** Zoomed, all nineteen providers fit one screen — there
  is nothing to scroll — and expanding Local Models reveals the bring-your-own llama.cpp
  section with an empty `sk-...` **API key field**, which contradicts the local-models
  message. Five video takes established this before the still was chosen.
- No window chrome (traffic lights) because the panel is zoomed. Consistent with
  `dock.png`, which is a bare modal; `hero.png` keeps its chrome. The set already mixes.
- ⏸️ **Follow-ups:** `persona` / `dock` / `setsail` / `sandbox` clips unshot — those four
  have real interactions and stay motion. The `<img>` → `<video>` swap at
  `layouts/index.html:34` still waits on the first real clip. Nothing committed yet.

## 2026-08-11

### The first post is live — and it revealed that syntax highlighting never worked here

- **Published the fork-hygiene engineering post** (#30) at `/blog/worst-bugs-in-a-fork/`, the beta campaign's T-2wk piece. The blog section built on 2026-08-06 had rendered nothing but its empty state until now. 1,725 words, 9 sections; dated the day it merged, per the `--buildFuture` trap.
- **Three mechanical edits during extraction:** dropped the H2 title (`single.html` renders `.Title`, so keeping it printed the headline twice), excluded the draft preamble and the internal notes section, trimmed a trailing horizontal rule.
- **Added a code excerpt** (#31) — the whole configuration both guards need, `RENAME_MAP` and `DELETED_DIRS`, placed against the paragraph that claims those two lists partition the space. **Diffed verbatim against `script/` before committing**, because the post's whole credibility rests on being checkable and a drifted excerpt would undercut it.
- ⚠️ **The excerpt exposed that Chroma highlighting had never actually run on this site.** Hugo defaults `markup.highlight.noClasses` to **true**, so code blocks carried inline **Monokai** (`#272822` on `#f8f8f2`) — a brown-black box in a blue site, exactly the foreign-element problem the section was built to avoid. Meanwhile `main.css` already had `.post-body .k` / `.c1` / `.s2` rules mapping tokens onto the editor's colours, **dead since the section shipped** because no post had a code block to reveal them. `noClasses = false` activates them.
- **Also mapped `.nv`** (shell variable names), which was missing — without it the array names the excerpt is *about* rendered as plain body text while their comments and strings were coloured.
- ✅ **Verified live, not locally:** background `#1e1e2e`, comments `#6c7086`, strings `#a6e3a1`, variables `#89b4fa`; the block scrolls inside itself at 1280px and 375px, and the page scrolls horizontally at neither.
- ⚠️ **Polling "the latest run" right after a merge races the workflow's creation.** A deploy check reported success for the *previous* run because #31's had not been created yet, and the verification off the back of it tested the old page. Caught because `<pre>` count was 0 while the arrays looked present. **Poll by run ID, or match the run to the merge commit.**
- ⚠️ **A layout measurement taken while the browser pane was collapsed reported `pageOverflow: true` with `clientWidth: 0`.** Re-measured with a real viewport rather than acting on it — there is no overflow. A zero-width viewport invalidates every layout number, not just that one.
- **Both commits are unsigned** — gpg-agent was not cached, per the standing decision not to rewrite merged history to re-sign.

## 2026-08-08

### Verified the blog section against the live site, and fixed the share card it left behind

- ✅ **Mobile is now visually verified** — the flag this section shipped with on 2026-08-06, when headless Chrome couldn't emulate a device. Checked in a real emulated viewport at 375px: **Blog correctly absent from the nav, Download intact**, Blog present in the footer's Project column, and `scrollWidth == clientWidth` with zero elements extending past the viewport. That last check matters because this page has shipped sideways-scroll bugs twice before.
- **The breakpoint is `max-width: 900px`, so Blog is hidden *at* 900, not below it.** The original recap said "below 900px" — off by one pixel, harmless, but the media query is the authority. Visible from 901px up; confirmed at 1280.
- ⚠️ **`single.html` had never rendered a real post anywhere** — the section shipped with no content, and the one preview attempt produced nothing because of the future-date trap. Exercised it locally with a throwaway post covering headings, lists, a blockquote, inline code and a Rust fence: rail gutter, reading time, Chroma classes, the all-posts link and the download CTA all render; the list page drops its empty state; the post appears in `blog/index.xml`.
- ⚠️ **Found a real bug that only shows up once a post exists: `twitter:description` was hardcoded to the site description** while `og:description` was correctly per-page. Anything preferring Twitter-card tags — Slack, Discord and LinkedIn unfurlers — would have described the product on a link someone shared to read the post, which is the exact failure the og: work was meant to prevent. One-word fix (`$desc`), verified per-page on a post and still site-level on the home page.
- **Note for the day the post lands:** the deploy still runs `hugo --gc --minify` with no `--buildFuture`, so a future-dated post silently does not appear. Date it on or before the merge day.

## 2026-08-06

### A blog section, built for the beta engineering post — scaffolding only, nothing published

- **The site had no blog at all.** `content/` held exactly one file (`_index.md`) and `layouts/` had only `index.html`, `robots.txt` and `_default/baseof.html`. Adding `list.html`, `single.html`, a `content/blog/` section, a nav entry and post styling is what "put the post on paddleboard.dev" actually costs — worth knowing two weeks before the launch rather than the morning of.
- **Built from the existing tokens, not a new palette.** The whole character of this site is that it looks like the editor; a stock Hugo article page would read as a different site bolted on. Posts keep the `.rail` line-number gutter, the `// ` comment eyebrow, Lilex for headings/code/metadata, and Chroma classes mapped onto the app's own syntax tokens so a code block here is coloured exactly like the same code in PaddleBoard.
- **Body copy is Plex at 68ch, deliberately not Lilex.** Long-form is the one place on this site where reading comfort outranks the monospace look.
- ⚠️ **The nav gained a fourth link, which is the exact case `main.css` warned about** — *"if a fifth link is ever added the strip degrades to scrolling"*, and a scrolling strip can push **Download** out of view on a phone. Rather than let that happen, **Blog is hidden below 900px** and lives in the footer's Project column instead. It's the only nav item that isn't a conversion path, so it's the one that yields.
- **Per-page `og:description` and `og:type: article`.** Every page previously shared the home page's description, so a shared post link would have described the product instead of the post — the whole reason someone clicked. Also emits `article:published_time`, and an RSS `<link rel="alternate">`.
- ⚠️ **The deploy runs `hugo --gc --minify` with NO `--buildFuture`, and Hugo silently drops future-dated content.** A post dated 11 Aug merged on 10 Aug simply will not appear — no error, no warning, a successful deploy with a missing post. Found by accident when the preview build produced no post page. Set a post's `date` to on-or-before the day it is merged.
- ⚠️ **Mobile is NOT visually verified.** Headless Chrome's `--window-size` does not emulate a device, so `<meta viewport>` isn't honoured and captures clip — the *existing, known-good* home page clips identically at 390px, which is how the artifact was identified rather than "fixed". Check on a real device or with DevTools emulation before merging.
- **Nothing is published.** No post content is committed; the empty state renders "Nothing published yet." Merging deploys the section, not the post — the deploy workflow is `push: [main]`.

## 2026-07-30

### Give the site a share card

- **Found while answering a different question.** Jay asked where the *GitHub* social preview gets uploaded; checking that turned up a bigger gap on this side — **the site had no `og:image` at all**, and `twitter:card` was `summary`.
- **Why that mattered more than the GitHub one.** The launch plan is Bluesky/Mastodon + LinkedIn, and the link being shared is mostly **paddleboard.dev**, not the repo. With no `og:image` those posts render as a bare text card. The weakest possible presentation, on the exact surface the launch runs on.
- **Reused the app repo's card** rather than making a second one — `assets/branding/social-preview.png` → `static/img/social-card.png`. It was already built at 1280×640, which is exactly the ratio a large summary card wants, so the GitHub preview and the site share card are now the same image.
- ⚠️ **`og:image` must be an absolute URL.** Every consumer silently drops a relative path, and the result is indistinguishable from having no card — nothing warns, the tag is simply there and ignored. Used Hugo's `absURL`, and verified the built HTML emits `https://paddleboard.dev/img/social-card.png` rather than `/img/...`.
- ⚠️ **`summary` → `summary_large_image`.** The old value renders a small square thumbnail, which crops a 2:1 card into nothing useful. Having the image without this change would have looked broken rather than absent.
- Added `og:image:width`/`height` (lets consumers reserve layout before fetching) and `:alt` on both tag families.
- Lives in `baseof.html`, so every page gets the card, not just the home page.

## 2026-07-29

### Fit the nav on a phone, and stop the hero shot running off

- **Two more mobile issues from Jay, both on surfaces the earlier fix touched.** Same day as the sideways-scroll fix below, which is worth noting: that fix stopped the *page* moving but did not make the nav usable.
- ⚠️ **"Let the strip scroll" solved the wrong half of the nav problem.** It removed the page-level overflow — the actual defect — but left `Download` rendered off screen, cut mid-word at 375px. The one item on the strip that has to be visible was the one you had to swipe to find, and "it's repeated in the hero below" was reasoning about the fix rather than about the user. Jay's ask was explicit: shrink it to *fill* the screen.
- **The wordmark is what buys the room.** Measured: the brand cell was 143px of the 436px the strip needed, ~100px of that the "PaddleBoard" text at 13px — more than any two links, and redundant with the h1 directly beneath it. Hiding the span below 900px and trimming link type (12.5→12px) and padding (11→9px) brings the strip to 320px at a 320px viewport.
- **`flex: none` was the reason it didn't fill.** With the links sized to content, `margin-left: auto` on Download had no free space to consume, so the strip ended 60px short of the right edge — it fit, but with a dead gap, which is not what "fill the screen" means. `flex: 1 0 auto` grows the row to fill while refusing to shrink below content width; plain `flex: 1` would let the links compress into each other on a narrower phone.
- **`overflow-x: auto` deliberately kept** as a fallback rather than deleted. It is no longer the mechanism, but it means a fifth nav link degrades to a scrolling strip instead of pushing the page sideways again.
- **The hero shot was inheriting the desktop treatment.** `border-right: 0` and `border-radius: 6px 0 0 6px` — the intentional right-edge bleed, since the page is not centred. At 1280px the cut edge reads as composition; at 375px there is no width left for the eye to infer the image continues, so it just looks broken. Gave it a 20px right inset matching `.inner`, all four borders, and a full radius.
- **Verified by measurement, not eyeball:** no horizontal overflow at 375px or 320px (`nav-inner.scrollWidth == clientWidth`, `document.scrollWidth == viewport`), Download flush right at both, and desktop confirmed unchanged at 1280px — wordmark back, `border-right: 0`, `radius: 6px 0 0 6px`.
- ⏸️ **Not fixed, and worth a decision:** a 1600×1004 desktop screenshot displayed at 301px is illegible on a phone — contained now, but unreadable. Every product shot on the page has this problem. The options are a phone-specific crop of each shot, or accepting them as texture rather than as evidence.
- 📸 **Tooling note, same class as the cached-CSS trap below:** the browser pane reported itself hidden, which silently suspends `window.scrollTo` — it returned `scrollY: 0` with no error while the page was 8012px tall. Shifting the document with a temporary negative `margin-top` got the off-screen element into frame for a screenshot. A scroll that reports no movement is worth reading as a stuck pane, not a mis-measured offset.

### Stop the page scrolling sideways on a phone

- **Jay found it on his own phone** — "you have to scroll a bit to the right to see the whole screen" — and guessed it was not an issue. It was: horizontal scroll on mobile is a real defect, and mobile-usability problems surface in Search Console, which matters on a domain with deliberate SEO standing.
- **Measured rather than guessed.** At 375px the document was 436px wide — 61px of overflow — and walking every element for `right > viewport` pinned it on the nav: brand + Features + Docs + GitHub + Download in a non-wrapping flex row simply do not fit a phone.
- **Fix: let the tab strip scroll, not the page.** `overflow-x: auto` on `.nav-inner` below 900px, scrollbar hidden, links `nowrap`. That is also what an editor's tab strip does when tabs outrun the window, so the fix is on-brand rather than a patch. Download drops out of first view but is repeated in the hero immediately below.
- **Verified at 375px and 320px:** `document.scrollWidth` equals the viewport at both, so no page-level horizontal scroll; the strip carries the overflow internally (436px inside 375px).
- ⚠️ **Process note:** the first verification said the fix had not worked — the browser was serving cached CSS (`overflow-x: visible`). Confirm the *computed* value changed before concluding a CSS fix failed.

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

### Product screenshots, and the three defects taking them exposed

- **Scope granted by Jay, narrowly:** capture PaddleBoard screenshots for these assets only, nothing else on the machine. Implemented as window-scoped capture — enumerate via `CGWindowListCopyWindowInfo` (a `swift` one-liner; no pyobjc here), filter to windows owned by PaddleBoard, then `screencapture -o -l<windowID>`. **No full-screen capture was ever taken**, so nothing else on his desktop could enter frame. Recorded in [[feedback-marketing-screenshot-access]].
- **Apple Events are blocked on this Mac** (`-1743`), so windows cannot be positioned or clicked by script, and the CLI has no flag to open a panel. Editor shots were driven via `Contents/MacOS/cli <path>`; every panel shot needed Jay to open it. That split — he clicks, I frame and name — worked well and is the pattern to repeat.
- **Shot against `samples/demo` only**, so no private repo, path, or account appears. One redaction was needed: the Usage tab renders `/Users/jaysmith/...`, painted out with the modal's own sampled background before cropping.
- **Six sections now carry real assets:** hero (editor), persona (AI Dock → Personas), models (18 providers with Local Models in the same list), dock (AI Dock → Agents), sandbox (Sandbox Backend, cropped), setsail (six platforms). MCP-tab variant kept in `alt/`.
- 🐛 **Photographing the product found three defects that reading code had not:**
  1. **"Zed Agent" led the Agents tab, described as a "First-party agent"** — true for Zed, false for a fork, and the first thing a visitor would see in the flagship panel. Fixed in app [PR #111](https://github.com/jasonsmithio/paddleboard/pull/111): moved below Antigravity, reworded. **Antigravity turned out to already be in the catalog** — it was simply below the visible fold.
  2. **My own sandbox copy overclaimed.** "Zero setup" — but the modal shows the built-in microVM tier covers *one-shot commands only*; services, sandboxed MCP and REPL kernels still need Podman. Copy narrowed to match, with a comment recording why so it cannot drift back.
  3. **Usage tab rejected as a section**: `Today 0`, `7 days 0`, three provider rows of zeros. The image argues against the feature it illustrates. Capability stays legible via the AI Dock tab strip.
- **Scion added as a deliberate final section**, styled quieter than the built-ins (muted label, dashed rule, "add-on" in the label) because it is opt-in and self-installed via `go` — presenting it alongside built-ins would promise a one-click experience that does not exist. Jay's call, explicitly reversible.
- **Prototype is complete and live** at `jasonsmithio/paddleboard-demo` (GitHub Pages, `noindex`). ⚠️ **The Pages site is publicly reachable even though the repo is private** — unlisted, not secret.
- **Open:** `persona` and `dock` are now both AI Dock modal shots and may read as similar frames down a scrolling page. Next real work is porting the design into the Hugo templates — everything so far lives outside this repo.

## 2026-07-28

### Redesign direction settled, and a first prototype to react to

- **Diagnosed *why* the site reads generic**, which Jay had summarised as "looks like a generic OSS site made by Claude." Reading the actual layout/CSS: centered hero + radial gradient glow, eyebrow pill, `border-radius:999px` buttons, a three-across icon `feature-card` grid, everything inside a centered ~1080px container, a `cta-band` before the footer, and a `-apple-system, BlinkMacSystemFont…` font stack. That is the full default shape of an LLM-generated dev-tool page — **so most of the fix is deletion, not addition.**
- **Direction chosen (Jay): product-led + editor-native. Typography and product shots only** — no illustration, no commissioned mark, no designer. The logo is already the work of a human designer and stays as-is.
- **Typography answer came free.** The editor renders in **Lilex** (mono) and **IBM Plex Sans** — the real identities behind `.ZedMono`/`.ZedSans` — both OFL, both already in the app repo's `assets/fonts/`. Using them makes "editor-native" literally true rather than a mood, at zero licensing cost.
- **Prototype A built** (`prototype-a.html`, self-contained, fonts embedded): tab-strip nav, a line-number gutter running the page height, section labels coloured as **real syntax tokens** pulled from `paddleboard.json` (keyword/function/string/type/number), a fixed status-bar footer mirroring the app's own, left-aligned hero with the shot bleeding off the right edge, and alternating feature sections. Gone: glow, eyebrow pill, pill buttons, icon-card grid, CTA band, reflexive centering.
- ⚠️ **Caught only by reading computed styles:** the syntax-token colours were silently dead on the first build — `.feat p` sets the muted prose colour at `0,1,1` specificity and beat `.tok-kw` at `0,1,0`, so every label rendered grey and the page's signature device simply wasn't there. It looked fine in a screenshot. The CSS now carries a comment explaining why that specificity is load-bearing.
- **Blocking dependency:** the five product screenshots. The campaign plan schedules them at T-2 (week of Aug 4), but this direction depends on them *now* — capture has to move earlier. Open question with Jay: whether he shoots them or grants scope for me to (my app-driving permission is Glowup-scoped and marketing capture sits outside it).
- **Not yet decided:** hero mono at 68px (striking vs too much), whether the gutter reads as intentional, whether the status bar earns its permanent 34px. Nothing merged — the prototype lives outside the repo pending Jay's reaction.

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
