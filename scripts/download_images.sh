#!/usr/bin/env bash
# download_images.sh — download listing photos into a kit's 01-source-photos/.
# Usage:
#   download_images.sh <dest_dir> <url> [url ...]
#   printf '%s\n' "$URL1" "$URL2" | download_images.sh <dest_dir> -
# Saves sequential photo-01.jpg, photo-02.jpg, …  Prints HTTP status + bytes per file.
set -euo pipefail

dest="${1:?usage: download_images.sh <dest_dir> <url|-> [url ...]}"; shift
mkdir -p "$dest"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

urls=()
if [ "${1:-}" = "-" ]; then
  while IFS= read -r line; do [ -n "$line" ] && urls+=("$line"); done
else
  urls=("$@")
fi

i=1
for u in "${urls[@]}"; do
  n=$(printf "photo-%02d.jpg" "$i")
  curl -sL -A "$UA" -o "$dest/$n" "$u" -w "$n  HTTP %{http_code}  %{size_download}B  %{content_type}\n"
  i=$((i+1))
done
echo "Downloaded $((i-1)) file(s) to $dest"
echo "Next: Read each photo, drop any that aren't this property, then write the photo manifest into listing.json."
