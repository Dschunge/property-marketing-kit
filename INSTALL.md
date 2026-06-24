# Install

This is a **Claude Code Agent Skill**. To use it, the `property-marketing-kit/` folder needs to
live in a skills directory Claude Code reads.

## Quick install (recommended)
```bash
git clone https://github.com/Samin12/property-marketing-kit.git
cd property-marketing-kit
./install.sh            # copies the skill into ~/.claude/skills/property-marketing-kit
```
Then restart Claude Code (or run `/doctor`) so it picks up the skill. Ask:
> "Use the property-marketing-kit skill on `<listing URL>`."

## Manual install
Copy this repo's contents into `~/.claude/skills/property-marketing-kit/` (user scope) or
`<project>/.claude/skills/property-marketing-kit/` (project scope). The folder must contain
`SKILL.md` at its root.

## Requirements
1. **Higgsfield MCP** connected in Claude Code (provides `generate_image` / `generate_video` /
   `models_explore` / `media_import_url` / `job_display`). A paid Higgsfield plan with credits
   is needed for generation. Note: free/low tiers may cap **concurrent jobs** (e.g. 3) — the
   skill queues generations in waves to respect that.
2. **Firecrawl** (preferred scraper) — see `references/firecrawl-setup.md` for the one-line
   `claude mcp add`. Optional: the skill falls back to a headless browser (Playwright/Chrome MCP).
3. **ffmpeg** on PATH (for stitching tour clips).
4. Optional: **Gmail MCP** (email handoff) and the **`/schedule`** skill (autopilot routine).

## What you get
Run it on a listing and it produces an organized kit: scraped + enhanced photos, a cinematic
property tour, a host/agent walkthrough (optionally **you**, via a Higgsfield composite or Soul),
a vertical UGC reel, a polished one-page website, and marketing copy. See `README.md` and
`assets/sample-kit/` for a real example.
