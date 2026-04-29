#!/bin/bash
# publish.sh — refresh index.html and push to GitHub Pages.
# Run this whenever you add, edit, or remove HTML files.

set -euo pipefail
cd "$(dirname "$0")"

generate_index() {
  local index_file="$PWD/index.html"

  cat > "$index_file" <<'HTML_HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="HTMLApps">
<title>HTMLApps</title>
<style>
  :root {
    --bg: #0f1115; --card: #1a1d24; --card-hover: #232730;
    --text: #e8eaed; --muted: #8a8f98; --accent: #7aa2f7; --border: #2a2e38;
  }
  @media (prefers-color-scheme: light) {
    :root {
      --bg: #f7f8fa; --card: #ffffff; --card-hover: #eef0f4;
      --text: #1a1d24; --muted: #6b7280; --accent: #2563eb; --border: #e2e5ea;
    }
  }
  * { box-sizing: border-box; }
  html, body {
    margin: 0; padding: 0; background: var(--bg); color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", system-ui, sans-serif;
    -webkit-font-smoothing: antialiased;
  }
  .wrap { max-width: 720px; margin: 0 auto; padding: 32px 20px 64px; }
  header { margin-bottom: 28px; }
  h1 { font-size: 28px; font-weight: 600; margin: 0 0 6px; letter-spacing: -0.02em; }
  .subtitle { color: var(--muted); font-size: 15px; margin: 0; }
  .grid { display: grid; gap: 12px; grid-template-columns: 1fr; }
  @media (min-width: 560px) { .grid { grid-template-columns: 1fr 1fr; } }
  a.card {
    display: block; padding: 18px 20px; background: var(--card);
    border: 1px solid var(--border); border-radius: 14px;
    text-decoration: none; color: inherit;
    transition: background 0.15s ease, transform 0.15s ease;
  }
  a.card:hover, a.card:active { background: var(--card-hover); transform: translateY(-1px); }
  .card-title { font-size: 16px; font-weight: 600; margin: 0 0 4px; color: var(--text); }
  .card-meta { font-size: 13px; color: var(--muted); margin: 0; word-break: break-all; }
  .empty {
    padding: 40px 20px; text-align: center; color: var(--muted);
    border: 1px dashed var(--border); border-radius: 14px;
  }
  footer { margin-top: 32px; font-size: 12px; color: var(--muted); text-align: center; }
</style>
</head>
<body>
<div class="wrap">
  <header>
    <h1>HTMLApps</h1>
    <p class="subtitle">Your launcher</p>
  </header>
  <div class="grid">
HTML_HEADER

  shopt -s nullglob
  local count=0
  for file in "$PWD"/*.html "$PWD"/*.htm; do
    local filename
    filename=$(basename "$file")
    [ "$filename" = "index.html" ] && continue
    [ ! -f "$file" ] && continue

    local title
    title=$(grep -o -i -m 1 '<title>[^<]*</title>' "$file" 2>/dev/null \
      | sed -e 's/<[Tt]itle>//' -e 's/<\/[Tt]itle>//' \
      | head -c 80 || true)
    if [ -z "$title" ]; then
      title="${filename%.*}"
      title=$(echo "$title" | tr '_-' '  ')
    fi

    local modified
    if stat -f "%Sm" -t "%b %d, %Y" "$file" >/dev/null 2>&1; then
      modified=$(stat -f "%Sm" -t "%b %d, %Y" "$file")
    else
      modified=$(stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1)
    fi

    local encoded safe_title
    encoded=$(printf '%s' "$filename" | sed 's/ /%20/g')
    safe_title=$(printf '%s' "$title" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')

    cat >> "$index_file" <<CARD
    <a class="card" href="./$encoded">
      <p class="card-title">$safe_title</p>
      <p class="card-meta">$filename · $modified</p>
    </a>
CARD
    count=$((count + 1))
  done
  shopt -u nullglob

  if [ "$count" -eq 0 ]; then
    cat >> "$index_file" <<'EMPTY'
    <div class="empty">No HTML files yet. Drop some .html files into this folder and re-run publish.sh.</div>
EMPTY
  fi

  local generated
  generated=$(date "+%b %d, %Y at %H:%M")
  cat >> "$index_file" <<FOOTER
  </div>
  <footer>$count app(s) · Generated $generated</footer>
</div>
</body>
</html>
FOOTER
}

generate_index

# Commit and push if there are changes
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Update $(date '+%Y-%m-%d %H:%M')"
  git push
  echo "Published. Allow ~30 seconds for GitHub Pages to rebuild."
else
  echo "No changes to publish."
fi
