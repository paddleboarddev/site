# PaddleBoard website

The source for [paddleboard.dev](https://paddleboard.dev), built with [Hugo](https://gohugo.io)
and deployed to GitHub Pages via the workflow in `.github/workflows/hugo.yml`.

## Local development

```sh
hugo server
```

Then open http://localhost:1313.

## Deploy

Pushing to `main` triggers the Hugo build + Pages deploy. The custom domain is
configured via `static/CNAME` (`paddleboard.dev`).

## Staging / previews

**Production and staging are deliberately different systems.** Production is
GitHub Pages, from `main`, serving `paddleboard.dev` — that path is untouched.
Staging is Cloudflare Pages, which builds *every branch and pull request* and
gives each one its own URL, so a change can be looked at before it is live.

Cloudflare's build is `script/cf-build.sh`, which does two things the production
build must never do:

- Sets `--baseURL` from `$CF_PAGES_URL`, the unique URL of that deployment.
  Without it, Hugo would emit absolute links from `hugo.toml`'s `baseURL` and
  clicking around a preview would quietly walk you onto production.
- Writes `_headers` (`X-Robots-Tag: noindex, nofollow`) and a `Disallow: /`
  `robots.txt`. `paddleboard.dev` has real search standing behind "open source
  AI IDE"; an indexable copy would compete with it, and unreleased copy should
  not be crawlable before launch. Neither file affects the GitHub Pages build —
  `_headers` is Cloudflare-only, and `robots.txt` is generated at build time
  rather than committed.

Cloudflare Pages settings: build command `bash script/cf-build.sh`, output
directory `public`, env var `HUGO_VERSION=0.162.0`.

Note that `docs.paddleboard.dev` and the Bluesky link stay absolute in previews.
That is correct — they are other properties, not this site.
