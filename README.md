# 🏝️ Property Marketing Kit — a Claude Code Skill

Turn **any** real-estate or vacation-rental listing into a complete, owner-ready marketing kit —
automatically. Point it at a listing URL and it scrapes the photos, enhances them, films a
cinematic tour **and** a host walkthrough (optionally *you*), builds a polished website, writes
the copy, and drops it all in one organized folder.

> Built on the **Higgsfield MCP** (image/video generation) + **Firecrawl** (scraping), driven by
> Claude Code.

```
listing URL
   │  scrape details + photos (Firecrawl, headless-browser fallback)
   ▼
organized kit folder
   │  enhance hero photos        →  Nano Banana Pro (relight, twilight, declutter)
   │  cinematic property tour     →  Veo 3.1 + Cinema Studio, stitched with ffmpeg
   │  host / agent walkthrough     →  composite a real person into the real rooms, then animate
   │  vertical UGC reel            →  9:16 for Reels / TikTok / Shorts
   │  one-page website             →  self-contained index.html
   │  marketing copy + owner email →  copy.md
   ▼
hand off the folder  ·  email a digest  ·  run it on a schedule across many listings
```

## ✨ See it — real output

`assets/sample-kit/` contains **actual** assets this skill produced for a real Clearwater Beach,
FL beachfront estate (5BR/3BA, private Gulf beachfront):

| | |
|---|---|
| `img/enhanced-hero-twilight.jpg` | Day exterior → magazine-grade twilight hero (Nano Banana Pro) |
| `img/host-*.jpg` | A real person composited into the actual rooms as the tour host |
| `video/tour-hero-cinematic.mp4` | Veo 3.1 cinematic push-in (with audio) |
| `video/property-tour-cinematic.mp4` | Multi-shot tour stitched from 5+ clips |
| `video/host-tour.mp4` | The host walking you through the home |
| `video/tour-vertical-reel.mp4` | 9:16 UGC reel |
| `website/` | The finished one-page site |
| `copy.md` | Headlines, captions, owner-outreach email |

## 🚀 Install

```bash
git clone https://github.com/Samin12/property-marketing-kit.git
cd property-marketing-kit && ./install.sh
```
Restart Claude Code, then:
> **"Use the property-marketing-kit skill on `<listing URL>`."**

Full requirements in [`INSTALL.md`](INSTALL.md) (Higgsfield MCP, Firecrawl, ffmpeg).

## 🧩 What's in the box

```
SKILL.md                     the playbook Claude follows
references/                   step-by-step guides
  firecrawl-setup.md          ensure/verify Firecrawl (bot-blocked portals are fine for it)
  scraping-listings.md        scrape details + photos, with provenance checks
  higgsfield-models.md        models, prompts, costs, concurrency notes
  host-walkthrough.md         put a real person (composite or trained Soul) in the tour
  video-stitching.md          ffmpeg recipes to build the tour
  website-template.md         build the site
  autopilot-routine.md        schedule + email handoff
scripts/                      new_kit.sh, download_images.sh
assets/
  website-template.html       reusable site template
  sample-kit/                 real example output (the bar)
workflows/
  batch-build-kits.workflow.js  fan out across many listings at once (Workflow tool)
```

## ⚡ Scale it (dynamic workflows)

For more than one property, `workflows/batch-build-kits.workflow.js` is a ready-to-run
**Workflow** that fans out: discover/scrape N listings → build each kit in parallel → verify →
digest. Run it with the Workflow tool (or ask Claude to "run the batch-build-kits workflow on
these listings"). Set a per-run credit cap so unattended runs stay bounded.

## 💳 Credits & concurrency

Generation uses Higgsfield credits (a one-property kit ≈ **25–90 credits** depending on how many
enhanced photos, tour clips, and host shots you generate). Claude always preflights cost with
`get_cost` before spending. Some plans cap **concurrent jobs** (e.g. 3) — the skill queues
generations in waves automatically.

## 🛡️ Honesty & use

Enhanced photos and tour videos are **AI-generated / AI-enhanced**; the skill keeps an AI-asset
disclosure on shipped sites and preserves the originals. Use the host feature only with the
person's consent. Scrape only public listing pages. Don't bulk-send owner outreach — drafts are
reviewed first.

---
MIT licensed. Built with Claude Code + Higgsfield.
