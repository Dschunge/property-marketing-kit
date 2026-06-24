# Ensuring Firecrawl is available

Firecrawl is the preferred scraper for this skill (clean markdown + structured extraction).
It is **not required** — there is a built-in headless-browser fallback (see
`scraping-listings.md`) — but check for it first.

> **Bot-blocked portals are not a problem for Firecrawl.** Realtor.com, Zillow and Redfin
> reject a bare `curl`/`fetch` with `403`/`429` — but Firecrawl rotates proxies and renders
> headlessly, so it scrapes them fine. A block from raw `curl` does **not** mean the site is
> unscrapable; reach for Firecrawl (or the headless-browser fallback) rather than giving up on
> the listing.

## 1. Is it already connected?

Run `ToolSearch` with query `firecrawl scrape crawl` (or `select:firecrawl_scrape`).
Firecrawl MCP tools are typically named `firecrawl_scrape`, `firecrawl_crawl`,
`firecrawl_search`, `firecrawl_extract`. If they appear, you're done.

## 2. If not connected, offer to add it

Firecrawl ships an MCP server. Tell the user you can add it and, with their OK, run **one** of:

**Hosted (needs a free API key from firecrawl.dev):**
```bash
claude mcp add firecrawl -e FIRECRAWL_API_KEY=fc-XXXX -- npx -y firecrawl-mcp
```

**Self-hosted / local endpoint:**
```bash
claude mcp add firecrawl -e FIRECRAWL_API_URL=http://localhost:3002 -- npx -y firecrawl-mcp
```

After adding, the user must reload so the MCP connects, then re-run `ToolSearch`.

> `claude mcp add` writes to the user's MCP config — treat it as a real change: confirm
> first, show the exact command, and don't store a key the user didn't provide.

## 3. Using Firecrawl in this skill

- **Details + copy:** `firecrawl_scrape` the listing URL with `formats: ["markdown"]`;
  parse name, beds/baths, description, amenities.
- **Photos:** ask for `formats: ["links"]` or use `firecrawl_extract` with a schema like
  `{ "images": ["string (absolute photo URLs)"] }`. Many listing sites lazy-load images, so
  if Firecrawl returns too few, switch to the Playwright DOM-harvest fallback.
- **Search:** `firecrawl_search` to find listings matching the user's criteria, then scrape
  the chosen result.

If Firecrawl is missing and the user doesn't want to add it, say so plainly and use the
headless-browser fallback — never silently stall.
