# Stitching clips into a tour (ffmpeg)

Higgsfield returns short clips (5–8s). Stitch them into one continuous tour. Clips can vary in
size/fps, so **normalize first, then concat** — never concat mismatched streams.

## 1. Normalize every clip to a common spec
Target 1920×1080 @ 24fps, H.264 + AAC. Scale to fit, pad to fill, reset timestamps:
```bash
norm() {  # norm <in> <out>
  ffmpeg -y -i "$1" \
    -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:black,fps=24,format=yuv420p,setsar=1" \
    -c:v libx264 -crf 19 -preset medium \
    -c:a aac -b:a 160k -ar 48000 -af "aresample=async=1:first_pts=0" \
    -movflags +faststart "$2"
}
```
If a clip has no audio, add a silent track so concat stays in sync:
`-f lavfi -t <dur> -i anullsrc=channel_layout=stereo:sample_rate=48000` mapped as its audio.

## 2. Order the shots
Cinematic property tour: **aerial reveal → twilight exterior push-in → pool deck → great room
interior → firepit dusk → beach sunset closer.** Host tour: **exterior/great-room intro → patio →
pool → firepit**, host presenting in each. Lead with the strongest hero, end on a sunset.

## 3. Concat
```bash
printf "file '%s'\n" norm-*.mp4 > list.txt
ffmpeg -y -f concat -safe 0 -i list.txt -c copy property-tour-cinematic.mp4
```
Concat-demuxer `-c copy` is lossless and works because every input now shares one spec. For
crossfades instead of hard cuts, use the `xfade`/`acrossfade` filter chain (heavier; hard cuts
are fine and punchier for real-estate).

## 4. Optional polish
- **Title/lower-third:** `drawtext` (property name, beds/baths) or burn in with a PNG overlay.
- **Music bed:** mix a licensed track under the ambient with `amix`; duck under host speech.
- **Vertical cut (9:16) for Reels:** re-run normalize with `scale=...:1080:1920` + center crop.
- **Upscale** the final to 4K with Higgsfield `upscale_video` (topaz/bytedance) if desired.

## 5. Verify
`ffprobe` the output (duration = sum of clips), extract a few frames (`-ss`), and watch for the
seams. Re-encode any clip whose face/architecture warped before it ships.
