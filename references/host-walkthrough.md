# Host / agent walkthrough — putting a real person in the tour

Two ways to add a presenter who "shows people around" the property. Pick by goal:

| Goal | Method | Tool |
|---|---|---|
| Presenter standing **in the actual scraped rooms** (recommended for listings) | **Composite** the person into each real room photo, then animate | `generate_image` `nano_banana_pro` with 2 inputs → image-to-video |
| A **reusable brand presenter** generated in new/synthetic scenes across many properties | **Trained Soul** (digital twin), then generate per scene | `show_characters` action=train → `generate_image` `soul_2` + `soul_id` |
| Quick reusable face you drop into prompts with `<<<id>>>` | **Element** | `show_reference_elements` action=create |

For a specific listing, **composite-into-real-rooms is almost always right** — the presenter is
literally inside *this* house, not a generated lookalike room.

## Getting the person's photo
The presenter's face must be a Higgsfield `media_id`. If the user has a local photo, call
`media_upload_widget` (don't ask them to paste into chat — remote tools can't read those). If a
usable portrait already exists in their library, `show_medias(type:"image")` and reuse it. A
single clean, front-facing, well-lit head-and-shoulders shot is enough; 2–3 angles improve
likeness.

## Step 1 — Composite the host into each room (`nano_banana_pro`)
Pass **two** image inputs — the room first, the person second — and tell the model which is which:
```
medias: [{role:"image", value:<room media_id>}, {role:"image", value:<person media_id>}]
```
Prompt recipe:
> "Photorealistic composite. Take the man/woman in the SECOND image and place them as a
> friendly, well-dressed real-estate host standing in the <room> from the FIRST image, turned
> toward camera, smiling, gesturing toward <feature>. **Preserve their exact facial identity,
> hair and skin tone from the second image.** Lighting that matches the scene, correct scale and
> perspective, full upper body, sharp — looks like an agent giving a home tour."

Do 3–4 distinct spaces (great room, patio, pool, entry/firepit). Keep aspect `16:9` so the host
clips concat cleanly with the cinematic tour. **Verify identity** on each result (Read it); regen
any where the face drifted.

## Step 2 — Animate each host composite (image-to-video)
- `veo3_1` (8s, with audio) for the strongest hero host shot — best at realistic people and a
  subtle talking/gesturing motion.
- `cinematic_studio_video_v2` (5s, `genre:"intimate"`, sound on) for the rest — cheaper, consistent.
Prompt the motion lightly: *"the host gestures welcomingly and looks to camera; subtle natural
movement; gentle handheld feel; do not distort the face."* Pass the **composite's job id** as
`start_image`.

## Step 3 — Stitch into a host tour
Normalize all clips to the same size/fps and concat with ffmpeg (see `video-stitching.md`).
Result: `host-tour-<name>.mp4` — the presenter walking the buyer/guest through the home. Also
keep a 9:16 cut for Reels/TikTok.

## Honesty
This is an AI rendering of a real person composited into real photos. Use only with the
person's consent (it's the user themselves, or someone who approved it). Keep the AI-asset
disclosure on any site/clip that ships.
