#!/usr/bin/env bash
#
# Cloudflare Pages build for the STAGING/PREVIEW site.
#
# Production is a different thing entirely: it deploys from `main` to GitHub
# Pages via .github/workflows/hugo.yml and serves paddleboard.dev. Nothing
# Cloudflare builds is ever production, which is why this script can blanket
# noindex everything it produces.
#
# Cloudflare Pages → Settings → Builds:
#   Build command:     bash script/cf-build.sh
#   Output directory:  public
#   Env var:           HUGO_VERSION = 0.162.0
#
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.162.0}"

if ! command -v hugo >/dev/null 2>&1; then
  echo "==> installing hugo_extended ${HUGO_VERSION}"
  curl -sSL -o /tmp/hugo.tar.gz \
    "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
  tar -xzf /tmp/hugo.tar.gz -C /tmp hugo
  export PATH="/tmp:$PATH"
fi

# CF_PAGES_URL is the URL of THIS deployment — unique per PR. Without it every
# preview would emit absolute links to paddleboard.dev (hugo.toml's baseURL) and
# a preview would silently navigate you onto production, which defeats the point.
BASE="${CF_PAGES_URL:-http://localhost:1313}/"
echo "==> building with baseURL ${BASE} (branch: ${CF_PAGES_BRANCH:-unknown})"

hugo --gc --minify --baseURL "$BASE"

# Keep staging out of the index. paddleboard.dev has real SEO standing behind
# its "open source AI IDE" keywords; an indexable copy would compete with it,
# and unreleased beta copy should not be crawlable before launch.
# Belt and braces: a header for the crawlers that honour it, robots.txt for the
# rest. `_headers` is Cloudflare-specific and ignored by GitHub Pages.
cat > public/_headers <<'HEADERS'
/*
  X-Robots-Tag: noindex, nofollow
HEADERS

cat > public/robots.txt <<'ROBOTS'
User-agent: *
Disallow: /
ROBOTS

echo "==> staging build complete (noindex applied)"
