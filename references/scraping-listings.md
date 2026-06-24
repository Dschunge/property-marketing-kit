# Scraping listings & pulling photos

Goal: from a listing URL, get (a) structured details + copy, and (b) **direct
full-resolution photo URLs that belong to *this* property.**

## Order of attack
1. **Firecrawl** (`firecrawl_scrape` / `firecrawl_extract`) — best for details/markdown.
2. **Headless browser** (Playwright MCP `mcp__playwright__*`, or Chrome MCP) — needed for
   photos on JS-app listing sites (Airbnb, Vrbo, Booking, Guesty, most modern Zillow). This
   is the reliable path for galleries and is the method used to build the sample kit.
3. **`curl`** — only works on server-rendered sites; most big portals (Realtor.com, Zillow,
   Redfin) return 403/429 to a bare request. **That's a `curl` limitation, not the site's
   verdict** — Firecrawl and the headless browser get through, so don't abandon a listing just
   because `curl` was blocked.

## Headless-browser DOM-harvest (the dependable method)

```
navigate(listingUrl) → wait ~4s → (open the "Show all photos" control) → scroll to lazy-load
→ collect <img> srcs on the listing's CDN → normalize to full resolution → verify provenance
```

Key `browser_evaluate` moves (adapt selectors per site):

```js
// 1) open the gallery, then scroll it to force lazy-load
const showAll = [...document.querySelectorAll('button,a,div')]
  .find(e => /show all|view all|photos/i.test(e.innerText||'') && (e.innerText||'').length<20);
showAll && showAll.click();
const s = document.scrollingElement; for (let i=0;i<12;i++){ s.scrollBy(0,1200); await new Promise(r=>setTimeout(r,350)); }

// 2) harvest images on the listing's image CDN, in DOM order, de-duped by filename
const keys=[],seen=new Set();
document.querySelectorAll('img').forEach(i=>{ const src=i.currentSrc||i.src||'';
  if(/* the listing CDN host */ src.includes('assets.guesty.com')){
    const k=src.split('/').pop().split('?')[0]; if(!seen.has(k)){seen.add(k); keys.push(k);} }});
return keys;
```

**Full-resolution trick (Cloudinary-style CDNs, e.g. Guesty):** the thumbnail transform sits
between `/upload/` and `/v…/`. Swap `h_240`/`s--xxx--` for `q_auto,w_1920` to get the big file:
`…/image/upload/q_auto,w_1920/v1/<path>.jpg`. Other CDNs: strip width/height query params or
size suffixes (`_min`, `=s320`, `/240x180/`).

## ⚠️ Provenance check — do this every time
Listing pages embed "similar listings", featured carousels, and lazy-load neighboring
properties' photos into the same DOM/CDN folder. **Not every harvested image is the target
property.** After downloading, `Read` a sample of the images and **drop any that are clearly a
different house** (different architecture, a competitor's watermark/branding, a city you didn't
search). The DOM-order images *immediately around the hero* are the safest; trailing images are
often the "you might also like" strip. In the sample build, 3 of the first batch were strays
from other listings and were removed.

## What to capture into `listing.json`
name, tagline, city/state, neighborhood, type, beds, baths, sleeps/sqft, view, a `highlights[]`
array, the full description text, the source URL + scrape date, and a **photo manifest**: one
line per downloaded file describing the scene + its best use (hero / pool / interior /
lifestyle / closer). You write the manifest *after* looking at each photo — it drives which
shots get enhanced and animated.
