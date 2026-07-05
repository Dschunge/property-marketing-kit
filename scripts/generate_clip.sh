#!/usr/bin/env bash
# generate_clip.sh — generate one image-to-video tour clip via the belt (inference.sh) CLI
# and save it into a kit's 03-tour-video/. A CLI-based alternative to the Higgsfield MCP path.
#
# Usage:
#   generate_clip.sh <kit_dir> <image_url> <prompt> [options]
#
# Options (env or flags):
#   -m MODEL     app id           (default: bytedance/seedance-2-0; alt: falai/wan-2-5, alibaba/happyhorse-1-0-i2v)
#   -d SECONDS   duration 4-15    (default: 8)
#   -r RATIO     aspect ratio     (default: 16:9; use 9:16 for Reels)
#   -q RES       resolution       (default: 1080p; e.g. 720p, 4k)
#   -a on|off    generate audio   (default: on)
#   -n NAME      output basename  (default: auto clip-NN.mp4, next free number in 03-tour-video/)
#
# <image_url> must be a PUBLIC URL (belt has no local-file upload). To animate a local enhanced
# photo, host it first (the kit's Cloudinary MCP or any bucket) and pass that URL.
#
# Prereqs: `belt login` (paid inference.sh account). Prints cost note; does not preflight spend.
set -euo pipefail

BELT="${BELT:-$HOME/.local/bin/belt}"
command -v "$BELT" >/dev/null 2>&1 || BELT="$(command -v belt || true)"
[ -x "$BELT" ] || { echo "error: belt CLI not found. Install it, then 'belt login'." >&2; exit 1; }

kit="${1:?usage: generate_clip.sh <kit_dir> <image_url> <prompt> [options]}"; shift
image="${1:?missing <image_url> (must be a public URL)}"; shift
prompt="${1:?missing <prompt>}"; shift

model="bytedance/seedance-2-0"
duration=8
ratio="16:9"
resolution="1080p"
audio="on"
name=""
while getopts "m:d:r:q:a:n:" opt; do
  case "$opt" in
    m) model="$OPTARG" ;;
    d) duration="$OPTARG" ;;
    r) ratio="$OPTARG" ;;
    q) resolution="$OPTARG" ;;
    a) audio="$OPTARG" ;;
    n) name="$OPTARG" ;;
    *) echo "unknown option" >&2; exit 2 ;;
  esac
done

case "$image" in
  http://*|https://*) : ;;
  *) echo "error: <image_url> must be a public http(s) URL, got: $image" >&2
     echo "       belt has no local upload — host the photo first (Cloudinary MCP, S3, …)." >&2
     exit 2 ;;
esac

outdir="$kit/03-tour-video"
mkdir -p "$outdir"

# Pick next free clip-NN.mp4 if no name given
if [ -z "$name" ]; then
  i=1
  while [ -e "$(printf '%s/clip-%02d.mp4' "$outdir" "$i")" ]; do i=$((i+1)); done
  name="$(printf 'clip-%02d.mp4' "$i")"
fi
[ "${name%.mp4}" = "$name" ] && name="$name.mp4"
outfile="$outdir/$name"
resultjson="$outdir/${name%.mp4}.result.json"

gen_audio=true; [ "$audio" = "off" ] && gen_audio=false

# Build input JSON safely (prompt may contain quotes/newlines)
input="$(jq -nc \
  --arg image "$image" \
  --arg prompt "$prompt" \
  --arg ratio "$ratio" \
  --arg resolution "$resolution" \
  --argjson duration "$duration" \
  --argjson audio "$gen_audio" \
  '{image:$image, prompt:$prompt, duration:$duration, ratio:$ratio, resolution:$resolution, generate_audio:$audio}')"

echo "→ model:      $model"
echo "→ image:      $image"
echo "→ out:        $outfile"
echo "→ spec:       ${duration}s · ${ratio} · ${resolution} · audio=$audio"
echo "  (paid: inference.sh bills per generation — check your credits)"
echo ""

# Run; --save writes the result JSON (contains the output video URL)
"$BELT" app run "$model" --input "$input" --save "$resultjson"

# Extract the video URL from the result and download the clip
video_url="$(jq -r '.. | .video? // empty | select(type=="string")' "$resultjson" 2>/dev/null | head -1)"
if [ -z "$video_url" ]; then
  echo "warning: no video URL found in $resultjson — inspect it manually." >&2
  jq . "$resultjson" 2>/dev/null | head -30 || cat "$resultjson"
  exit 1
fi

echo "→ downloading clip…"
curl -fsSL "$video_url" -o "$outfile"

echo ""
echo "Saved: $outfile"
if command -v ffprobe >/dev/null 2>&1; then
  dur="$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$outfile" 2>/dev/null || true)"
  dim="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$outfile" 2>/dev/null || true)"
  echo "  ${dur%.*}s · ${dim}"
fi
echo "Next: generate the rest of the shots, then stitch with references/video-stitching.md (ffmpeg)."
