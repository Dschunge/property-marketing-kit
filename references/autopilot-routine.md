# Autopilot routine + email handoff

Two layers: (A) the per-run handoff, and (B) a scheduled "find listings → build kits → email
me" routine. **Outreach to a property owner is never sent automatically** — draft, then a human
approves.

## A. Per-run handoff (default)
1. Make sure the kit folder is complete and self-contained:
   `01-source-photos/ 02-enhanced-photos/ 03-tour-video/ 04-website/ 05-marketing-copy/ listing.json`.
2. Surface the website file to the user (Launch panel / `open 04-website/index.html`) and the
   two clips.
3. Write a top-level `README.md` in the kit (what's inside, credits spent, source URL).
4. If asked to email: create a **Gmail draft** (don't send) — see below.

## B. Scheduled routine ("on autopilot, then send an email")
Use the **`/schedule`** skill (or `scheduled-tasks` / `claude-mgr` orchestrator MCP) to run a
cron agent. The agent's instructions should be:

> 1. Invoke the **property-marketing-kit** skill.
> 2. Search `<user's criteria>` (city, type, price/nightly band, platform) and pick the top
>    `N` new listings not already in `property-marketing-kits/`.
> 3. For each: scrape → organize → enhance 1–2 heroes → 1 tour video → (optional vertical) →
>    website → copy. **Preflight credits; respect a per-run credit cap of `{{CAP}}`.**
> 4. Email me a digest (see template) with a thumbnail, the website file/link, and the credit
>    spend per property. Leave any owner-outreach emails as **drafts**.

Pick the schedule with the user (e.g. weekly Mon 8am). Example creation via `/schedule`:
> "Every Monday at 8am, run the property-marketing-kit skill for new <criteria> listings, cap
> 60 credits/run, and email me a digest at <address> with the websites and credit spend."

### Credit safety for unattended runs
Always `get_cost`-preflight; enforce the cap; if a run would exceed it, build fewer assets
(skip the vertical reel first, then the hero video) and note what was skipped in the email.
Consider Higgsfield auto-refill only if the user opts in.

## Email step (Gmail MCP)
Tools: `mcp__…__create_draft` (drafts), `search_threads`, `list_drafts`. **Create a draft, do
not send**, unless the user explicitly says to send.

**Internal digest draft (safe to send to the user themselves):**
> Subject: `New property kits — {{DATE}} ({{COUNT}} built, {{CREDITS}} credits)`
> Body: per property — name, location, one-line pitch, website file/link, asset list, credits.

**Owner-outreach draft (always review before sending):** use the owner-email template in the
kit's `05-marketing-copy/copy.md`. Attach or link the website + hero assets. Never bulk-send;
never scrape private contact info — use what the owner has published publicly.

## Guardrails
- Drafts over sends for anything leaving the user's own inbox.
- Disclose AI-enhanced/-generated imagery.
- Keep a per-run and per-day credit ceiling on scheduled jobs.
