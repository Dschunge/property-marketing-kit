# Belt (inference.sh) — CLI video path

An alternative to the Higgsfield MCP for generating tour clips, driven from the shell via the
`belt` CLI. Use it when you want a scriptable, non-MCP path (batch jobs, cron, CI). Output drops
into the same `03-tour-video/` folder and feeds the same ffmpeg stitch in `video-stitching.md`.

## Prereqs
- `belt` CLI on PATH (`~/.local/bin/belt`) and `belt login` (paid inference.sh account).
- Photos must be **public URLs** — belt has no local-file upload. Host enhanced photos first
  (the kit's Cloudinary MCP, S3, any bucket) and pass the URL.

## One clip
```bash
scripts/generate_clip.sh <kit_dir> <image_url> "<prompt>" [-m MODEL -d SECS -r RATIO -q RES -a on|off -n NAME]
```
Defaults: `bytedance/seedance-2-0`, 8s, 16:9, 1080p, audio on. Saves the next free
`03-tour-video/clip-NN.mp4` (plus its `.result.json`) and prints duration/dimensions.

Example — animate an enhanced twilight exterior:
```bash
scripts/generate_clip.sh property-marketing-kits/clearwater-beachfront-estate \
  "https://res.cloudinary.com/…/enhanced-01.jpg" \
  "Cinematic luxury real-estate tour. Slow aerial push-in toward this illuminated estate at twilight, warm window light, palms swaying, pool reflecting the sky. Gentle ocean-breeze ambient. No text, no people, no warping of the architecture." \
  -d 8 -r 16:9 -q 1080p
```

## Models (image-to-video)
| App id | Notes |
|--------|-------|
| `bytedance/seedance-2-0` | default; sync audio, up to 1080p, `duration` 4-15 |
| `bytedance/seedance-2-0-fast` | faster/cheaper, same inputs |
| `falai/wan-2-5` | animate any image |
| `alibaba/happyhorse-1-0-i2v` | up to 1080P/15s |
| `alibaba/happyhorse-1-0-r2v` | character-preserving from references |

Inspect any app's exact input schema first: `belt app get <app-id>`.
Cost is token-based and varies by resolution/length — check credits before batch runs.

## Vertical (Reels/TikTok)
Add `-r 9:16` (and often `-q 720p`, `-d 5`). Or normalize a 16:9 clip to 9:16 in
`video-stitching.md` step 4.

## Higgsfield vs belt — which path
- **Higgsfield MCP** (`higgsfield-models.md`): richer real-estate presets (`veo3_1`,
  `cinematic_studio_video_v2`), `get_cost` preflight, animates enhancement **job ids** directly
  (no re-hosting). Best for interactive, single-kit work.
- **belt CLI** (this doc): scriptable/batchable, but needs hosted image URLs. Best for automation.

Pick one path per kit; both write clips into `03-tour-video/` for the same stitch step.
