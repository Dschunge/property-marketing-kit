#!/usr/bin/env bash
# new_kit.sh — scaffold an organized property marketing-kit folder.
# Usage: new_kit.sh <slug> [parent_dir]
#   slug        kebab-case property id, e.g. clearwater-beachfront-estate
#   parent_dir  where to create it (default: ./property-marketing-kits)
set -euo pipefail

slug="${1:?usage: new_kit.sh <slug> [parent_dir]}"
parent="${2:-./property-marketing-kits}"
base="$parent/$slug"

mkdir -p "$base"/{01-source-photos,02-enhanced-photos,03-tour-video,04-website/assets/img,04-website/assets/video,05-marketing-copy}

# seed listing.json
cat > "$base/listing.json" <<'JSON'
{
  "source": { "platform": "", "url": "", "scraped_at": "", "listing_id": "" },
  "property": {
    "name": "", "tagline": "", "city": "", "state": "", "neighborhood": "",
    "type": "", "bedrooms": 0, "bathrooms": 0, "sleeps": 0, "view": ""
  },
  "highlights": [],
  "photos": {}
}
JSON

# seed copy.md
cat > "$base/05-marketing-copy/copy.md" <<'MD'
# Marketing Copy — <PROPERTY NAME>
## Hero headline options
## One-line summary
## Long description
## Feature bullets
## Social captions (IG/Reel · Facebook · TikTok hook)
## Owner outreach email (subject + body)
MD

echo "Created kit at: $base"
find "$base" -type d | sed "s|$base|  .|"
