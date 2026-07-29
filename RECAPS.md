# Recaps

Running log of completed work on the PaddleBoard marketing site, newest first. Each `## YYYY-MM-DD` groups a day; each `### ` is one coherent unit of work.

## 2026-07-28

### A staging site, because there was no way to see a change before it was live

- **The gap:** `hugo.yml` only fires on `push` to `main`, and GitHub Pages allows one site per repo — so nothing could be reviewed at a URL pre-merge. That is how the 2026-07-20 homepage work reached an ambiguous state (recap says shipped as PR #20; `origin/main` does not contain it).
- **Approach chosen (Jay): Cloudflare Pages for previews, production untouched.** `main` → GitHub Pages → paddleboard.dev stays exactly as it was. Cloudflare builds every branch and PR to its own URL. Netlify and a second Pages repo were the alternatives; the second Pages repo lost on two counts — one shared URL rather than per-PR isolation, and GitHub Pages has no auth, so a staging site there could only ever be `noindex`, never gated.
- **DNS is not on Cloudflare, and does not need to be.** Preview URLs live on `*.pages.dev` and work immediately; a custom `staging.paddleboard.dev` would be a single CNAME at the registrar.
- **`script/cf-build.sh` holds the two staging-only behaviours** in the repo rather than in dashboard config: `--baseURL` from `$CF_PAGES_URL` (without it Hugo emits absolute links from `hugo.toml` and clicking a preview walks you onto production), and blanket `noindex` via `_headers` + `robots.txt` (paddleboard.dev has real standing on "open source AI IDE"; an indexable duplicate competes with it, and pre-launch copy must not be crawlable).
- **Neither staging artefact touches production:** `_headers` is Cloudflare-only and ignored by GitHub Pages; `robots.txt` is generated at build time, not committed.
- **Verified** with a fake `CF_PAGES_URL`: internal absolute URLs rewrote to the preview host, both files written, and the only surviving `paddleboard.dev` strings were `docs.paddleboard.dev` and the Bluesky profile — correct, as those are other properties.
- Shipped as [PR #21](https://github.com/paddleboarddev/site/pull/21). **Requires a human step:** connecting the repo in the Cloudflare dashboard (build command, output dir, `HUGO_VERSION`), documented in the README.
- ⚠️ **Follow-up worth checking:** paddleboard.dev may still claim macOS builds are un-notarized and need a Gatekeeper bypass — untrue since v0.1.14 — because the correction never reached `main`.

## 2026-07-05

### Add maintainer credit to the footer

- Added "Made by [Jason (Jay) Smith](https://jasonsmith.io)" to the footer's legal line in `layouts/_default/baseof.html`, appended to the existing copyright line with the same ` · ` separator style used for the version badge.
- Built locally with `hugo --gc --minify` (4 pages, no errors) and confirmed the credit renders in `public/index.html` with the link pointing at https://jasonsmith.io. `public/` is gitignored (built by CI on deploy), so the change is template-only.
- Shipped as [PR #17](https://github.com/paddleboarddev/site/pull/17).
