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
