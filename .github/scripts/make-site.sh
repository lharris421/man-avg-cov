#!/usr/bin/env bash
# Assemble a small static site holding the built manuscript and figures, with
# an index page that records exactly which commit and run produced them. The
# smoke-test workflow publishes this directory to GitHub Pages as proof that
# the repository builds from scratch.
#
# Usage (from the repository root, after a build):
#   .github/scripts/make-site.sh OUT_DIR
# Reads GITHUB_* variables when run inside Actions; falls back to git locally.
set -euo pipefail

out="${1:-site}"
pdf="build/avg-cov.pdf"
[ -f "$pdf" ] || { echo "make-site: $pdf not found; build the manuscript first" >&2; exit 1; }

rm -rf "$out" && mkdir -p "$out/figures"
cp "$pdf" "$out/"
cp code/out/figure*.pdf code/out/figure*.png "$out/figures/" 2>/dev/null || true

sha="${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo unknown)}"
ref="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)}"
repo="${GITHUB_REPOSITORY:-}"
server="${GITHUB_SERVER_URL:-https://github.com}"
commit_url=""; [ -n "$repo" ] && commit_url="$server/$repo/commit/$sha"
run_url="";    [ -n "$repo" ] && [ -n "${GITHUB_RUN_ID:-}" ] && run_url="$server/$repo/actions/runs/$GITHUB_RUN_ID"
when="$(date -u +'%Y-%m-%d %H:%M UTC')"
config="${BUILD_CONFIG:-config.yaml defaults}"
rver="$(Rscript -e 'cat(as.character(getRversion()))' 2>/dev/null || echo unknown)"
pages="$(qpdf --show-npages "$pdf" 2>/dev/null || echo '?')"
size="$(du -h "$pdf" | cut -f1)"
lockhash="$(python3 -c 'import hashlib;print(hashlib.sha256(open("renv.lock","rb").read()).hexdigest()[:12])')"
versions="$(python3 - <<'PY'
import json
p = json.load(open("renv.lock"))["Packages"]
print(", ".join(f"{k} {p[k]['Version']}" for k in ["ncvreg","hdrm","hdi","selectiveInference","glmnet","mgcv"] if k in p))
PY
)"

# First-page thumbnail, if poppler is available.
preview=""
if command -v pdftoppm >/dev/null 2>&1; then
  pdftoppm -png -r 50 -f 1 -l 1 "$pdf" "$out/page1" >/dev/null 2>&1 || true
  preview="$(cd "$out" && ls page1*.png 2>/dev/null | head -1 || true)"
fi

figlist="$(cd "$out/figures" && for f in $(ls | sort -V); do printf '      <li><a href="figures/%s">%s</a></li>\n' "$f" "$f"; done)"
link() { [ -n "$2" ] && printf '<a href="%s">%s</a>' "$2" "$1" || printf '%s' "$1"; }

cat > "$out/index.html" <<HTML
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>man-avg-cov smoke build</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{font:16px/1.5 system-ui,sans-serif;max-width:52rem;margin:2rem auto;padding:0 1rem;color:#222}
  .warn{background:#fff4d6;border-left:4px solid #e0a800;padding:.6rem 1rem;margin:1rem 0}
  dt{font-weight:600;margin-top:.5rem} dd{margin:0 0 0 1rem} img{max-width:260px;border:1px solid #ccc;float:right;margin:0 0 1rem 1rem}
  code{background:#f3f3f3;padding:0 .25rem}
</style></head><body>
<h1>man-avg-cov: smoke-test build</h1>
$( [ -n "$preview" ] && printf '<a href="avg-cov.pdf"><img src="%s" alt="first page of the manuscript"></a>' "$preview" )
<p><strong><a href="avg-cov.pdf">avg-cov.pdf</a></strong> ($pages pages, $size), built from scratch by the <code>smoke-test</code> workflow.</p>
<div class="warn">This PDF was produced with the smoke-test settings (<code>$config</code>): the small BRCA1 dataset and a handful of simulation iterations. It proves the pipeline builds; its numbers are not the paper's.</div>
<dl>
  <dt>Commit</dt><dd>$(link "$sha" "$commit_url") on <code>$ref</code></dd>
  <dt>Workflow run</dt><dd>$(link "${GITHUB_RUN_ID:-local build}" "$run_url")</dd>
  <dt>Built</dt><dd>$when</dd>
  <dt>R</dt><dd>$rver; renv.lock sha256 ${lockhash}…</dd>
  <dt>Method packages</dt><dd>$versions</dd>
</dl>
<h2>Figures</h2>
<ul>
$figlist
</ul>
</body></html>
HTML

# Markdown summary for the Actions job page.
{
  echo "## Smoke build"
  echo
  echo "- **PDF:** avg-cov.pdf, $pages pages, $size"
  echo "- **Commit:** $sha on \`$ref\`"
  echo "- **Settings:** \`$config\`"
  echo "- **R:** $rver, renv.lock ${lockhash}…"
  echo "- **Method packages:** $versions"
} > "$out/summary.md"

echo "make-site: wrote $out/ ($(ls "$out/figures" | wc -l | tr -d ' ') figures, preview: ${preview:-none})"
