# Recaps

Running log of completed work on the PaddleBoard marketing site, newest first. Each `## YYYY-MM-DD` groups a day; each `### ` is one coherent unit of work.

## 2026-07-05

### Add maintainer credit to the footer

- Added "Made by [Jason (Jay) Smith](https://jasonsmith.io)" to the footer's legal line in `layouts/_default/baseof.html`, appended to the existing copyright line with the same ` · ` separator style used for the version badge.
- Built locally with `hugo --gc --minify` (4 pages, no errors) and confirmed the credit renders in `public/index.html` with the link pointing at https://jasonsmith.io. `public/` is gitignored (built by CI on deploy), so the change is template-only.
- Shipped as [PR #17](https://github.com/paddleboarddev/site/pull/17).
