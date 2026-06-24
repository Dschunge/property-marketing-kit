---
name: property-marketing-kit
description: >-
  Turn any real-estate or vacation-rental listing into a full marketing kit. Use
  when the user wants to market a property, build property/listing assets, "build
  a marketing kit", make a property website, generate property tour videos or UGC
  walkthrough videos, enhance/restyle listing photos, or pitch a property owner.
  Scrapes a listing (Zillow/Airbnb/Booking/Expedia/Vrbo/Guesty etc.) with Firecrawl,
  pulls the photos, organizes a kit folder, then uses the Higgsfield MCP to enhance
  hero photos and generate cinematic tour + vertical UGC videos, and builds a
  single-page property website. Also sets up an autopilot routine that emails the kit.
---

# Property Marketing Kit

Turn a single listing URL (or a search) into a complete, owner-ready marketing kit:

```
listing → scrape photos & details → organized kit folder → enhanced hero photos
        → cinematic tour video + vertical UGC reel → property website → email/handoff
```

This skill is the playbook behind the Higgsfield "analyze a listing, build the assets the
owner never had, then pitch them" workflow. A **complete worked example** ships in
`assets/sample-kit/` — real enhanced photos and a real tour reel produced by this exact
pipeline for a Clearwater Beach, FL beachfront estate. Use it as the quality bar.

## Prerequisites (check first, every run)

1. **Higgsfield MCP** — required for image/video generation. Tools are named
   `mcp__*__generate_image`, `mcp__*__generate_video`, `mcp__*__models_explore`,
   `mcp__*__media_import_url`, `mcp__*__job_display`. If you can't find them, run
   `ToolSearch` with `generate_video higgsfield`. If still absent, tell the user the
   Higgsfield MCP must be connected and stop.
2. **Firecrawl** — preferred scraper. See `references/firecrawl-setup.md` to verify it's
   installed and, if not, the one-liner to add it. **A headless-browser fallback
   (Playwright/Chrome MCP) is built in** and works without Firecrawl — see
   `references/scraping-listings.md`. Never block the run just because Firecrawl is missing;
   confirm with the user, then fall back.

> Preflight every Higgsfield generation with `get_cost: true` and tell the user the credit
> total before spending. A basic run ≈ **25–30 credits**; a full kit with a stitched multi-shot
> tour + host walkthrough ≈ **60–90 credits**. **Concurrency:** some plans cap concurrent jobs
> (pro = **3**). Submit generations in **waves of ≤3** and poll `job_display` before sending more —
> the API rejects overflow with a rate-limit error.

## The pipeline

Work through these in order. Each step has a dedicated reference — read it before doing the step.

### 1 — Intake & scrape  → `references/scraping-listings.md`
- Get the listing URL (or run a search per the user's criteria and pick one).
- Scrape with Firecrawl; if it can't render the gallery (most modern listing sites are JS
  apps that lazy-load photos), use the **Playwright DOM-harvest** technique in the reference.
- **Critical:** listing galleries often lazy-load *other* listings' photos into the DOM.
  Verify every image actually belongs to the target property (open a few; drop strays).
- Extract: name, location, beds/baths, sleeps/sqft, view, highlights, full description,
  and the **direct full-resolution image URLs**.

### 2 — Organize the kit folder  → run `scripts/new_kit.sh`
Create a self-contained folder (default under `./property-marketing-kits/<slug>/`):
```
01-source-photos/     downloaded originals (photo-01.jpg …)
02-enhanced-photos/   Higgsfield-enhanced heroes
03-tour-video/        tour + vertical reels
04-website/           index.html + assets/
05-marketing-copy/    copy.md (headlines, captions, owner email)
listing.json          structured listing data + a labeled photo manifest
```
Download originals with `scripts/download_images.sh`. Then **look at every photo** (Read
them) and write `listing.json` with a one-line label per image so later steps pick the
right shots.

### 3 — Enhance hero photos  → `references/higgsfield-models.md`
- Pick 2–3 strongest shots (a twilight/exterior hero, a pool/outdoor hero, a key interior).
- `media_import_url` each chosen original → get `media_id`.
- `generate_image` with **`nano_banana_pro`** (resolution `2k`, the listing's best aspect
  ratio, usually `16:9`), passing the original as `medias[].role:"image"`. Prompt = the
  real-estate enhancement recipe in the reference (relight, sky, crisp water, declutter,
  **keep architecture identical**). Poll with `job_display`; download results to `02-`.

### 4 — Tour videos  → `references/higgsfield-models.md` + `references/video-stitching.md`
Generate clips, then stitch into full tours. Submit in **waves of ≤3** (concurrency cap).
- **Hero tour clip (16:9):** `veo3_1` (8s, with audio), `start_image` = the *enhanced* hero's
  job id. Slow cinematic push-in, no warping, ambient sound.
- **Complex multi-shot tour:** animate 4–6 enhanced scenes (aerial, exterior, pool, great room,
  firepit, sunset) with `cinematic_studio_video_v2` (~5cr each), then **stitch with ffmpeg**
  into one `property-tour-cinematic.mp4` (~30–40s). Normalize → concat per the stitching ref.
- **Vertical UGC reel (9:16):** `cinematic_studio_video_v2` (5s, `genre:"intimate"`), a
  lifestyle shot.
- If Higgsfield returns a `preset_recommendation`, use it or re-send with `declined_preset_id`.
  Download all clips to `03-tour-video/clips/`, finished tours to `03-tour-video/`.

### 4b — Host / agent walkthrough (optional)  → `references/host-walkthrough.md`
Put a real presenter "showing people around" the home — often **the user themselves**.
- Get their photo as a `media_id` (`media_upload_widget`, or reuse one from `show_medias`).
- **Composite** them into 3–4 *real* rooms with `nano_banana_pro` (two inputs: room + person;
  "preserve exact facial identity"). Verify each face (Read it); regen drifts.
- **Animate** each composite (`veo3_1` for the hero shot, `cinematic_studio_video_v2` for the
  rest) and stitch into `host-tour-<name>.mp4`. Keep a 9:16 cut for socials.

### 5 — Build the website  → `references/website-template.md`
- Copy `assets/website-template.html` into `04-website/index.html` and drop chosen images
  into `04-website/assets/img/` and the two clips into `assets/video/`.
- Fill the placeholders (`{{PROPERTY_NAME}}`, beds/baths/sleeps, highlights, copy). The hero
  is a muted autoplay loop of the tour video with the enhanced photo as poster.
- Preview it (the Launch panel, or open `index.html`). Keep the AI-asset disclosure in the footer.

### 6 — Marketing copy  → write `05-marketing-copy/copy.md`
Headlines, long description, social captions (IG/FB/TikTok), and the **owner-outreach email**.
Template lives in `references/website-template.md` and the sample kit's `copy.md`.

### 7 — Handoff / email / autopilot  → `references/autopilot-routine.md`
- Default handoff = the organized folder (the user reviews it). Surface the website file.
- If the user wants it emailed or running on a schedule, use the routine in the reference
  (Gmail draft + the `/schedule` skill). **Never auto-send outreach without approval.**

## Guardrails
- **Honesty:** these are AI-enhanced/AI-generated assets. Keep the footer disclosure on the
  site and never imply photos are unretouched originals.
- **Respect sources:** scrape only public listing pages; don't defeat paywalls/logins.
- **Cost:** always preflight with `get_cost` and report the total before generating.
- **Verify provenance** of every scraped photo (see step 1) before it lands in the kit.
```
```
See `references/` for the full detail on each step and `assets/sample-kit/` for the finished bar.
