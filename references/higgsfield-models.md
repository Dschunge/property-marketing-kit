# Higgsfield: models, prompts & costs for property assets

All generation goes through the Higgsfield MCP. Core tools:
`media_import_url` → `generate_image` / `generate_video` → `job_display` (poll) → download.
Use `models_explore(action:"recommend"|"get")` when unsure. **Always preflight with
`get_cost: true`** and report credits before spending.

## Importing source media
Generation `medias[].value` must be a Higgsfield `media_id` or a prior **job id** — never a raw
URL. Import each chosen photo first:
```
media_import_url(url:"https://…/photo.jpg", type:"image") → media_id
```
To animate an *enhanced* photo, pass the enhancement's **job id** as the video `start_image` so
the clip inherits the polished look (this is what the sample kit does).

## Photo enhancement — `nano_banana_pro`
Image-to-image relight/restyle that keeps the structure. Params: `resolution:"2k"` (or `4k`),
`aspect_ratio` (usually `"16:9"`), `medias:[{role:"image", value: <media_id>}]`.
**Cost ≈ 2 credits / image.**

Enhancement recipe (fill the specifics from the actual photo):
> "Professional luxury real-estate photography enhancement of this exact <scene>. Keep the
> architecture, layout, landscaping and composition **completely identical**. Brighten and
> balance exposure, enrich the sky into a vivid <twilight magenta-blue / golden-pink sunset>,
> add warm inviting glow to interior windows, make pool water crisp and reflective, deepen the
> lawn green, remove hoses/clutter, ultra-sharp, high dynamic range, magazine-quality MLS photo."

Keep `keep … identical` in the prompt — it's what prevents the model from inventing a different
house. Twilight conversion on a daytime exterior is the single highest-impact edit.

## Hero tour video (16:9) — `veo3_1`
Ultra-realistic cinematic with native audio. Params: `duration:8` (`[4,6,8]`),
`aspect_ratio:"16:9"`, `quality:"basic"` (bump to `high` for spend), `medias:[{role:"start_image",
value: <enhanced job id>}]`. **Cost ≈ 16 credits / 8s.**
> "Cinematic luxury real-estate tour. Slow, smooth aerial push-in drifting toward this
> illuminated estate at twilight … warm light from the windows, palms swaying, pool reflecting
> the sky. Calm, premium, aspirational. Gentle ocean-breeze ambient sound. **No text, no people,
> no warping of the architecture.**"

## Vertical UGC reel (9:16) — `cinematic_studio_video_v2`
Higgsfield-native, cheaper, great for Reels/TikTok/Shorts. Params: `duration:5`,
`aspect_ratio:"9:16"`, `genre:"intimate"`, `sound:"on"`, `medias:[{role:"image", value:<media_id>}]`.
Use a **lifestyle** still (people on the patio/in the pool). **Cost ≈ 5 credits / 5s.**
> "Cozy UGC-style vertical clip from the covered patio at sunset: a gentle handheld move past
> the family on the sofa, revealing the pool and open Gulf horizon in golden-pink light, warm
> string lights, palms swaying. Warm, inviting, lifestyle vacation feel."

## Handling preset suggestions
`generate_video` may return a `preset_recommendation` instead of running. Either use the preset
(`model:"higgsfield_preset", preset_id:…`) or re-send your literal prompt with
`declined_preset_id: <that id>`.

## Polling
After submit you get a job id with `status:"pending"`. Call `job_display(id)` until
`status:"completed"`, then download `results.rawUrl`. Images ~15–30s; `veo3_1` ~2–3 min;
`cinematic_studio_video_v2` ~1–2 min. Don't spin — check, do other work, check again.

## Model alternatives (via `models_explore`)
- Cheaper hero video: `cinematic_studio_video_v2` (~5cr) or `kling3_0` pro (~9cr).
- Top-tier images/text overlays: `nano_banana_pro 4k`, `gpt_image_2`, `seedream` family.
- `upscale_image` / `upscale_video` to push a final pick to 4K.

## Sample-run ledger (the kit in `assets/sample-kit/`)
2× `nano_banana_pro` 2k enhance (≈4cr) + 1× `veo3_1` 8s hero (≈16cr) +
1× `cinematic_studio_video_v2` 5s vertical (≈5cr) ≈ **~25 credits total.**
