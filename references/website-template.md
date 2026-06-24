# Building the property website

A polished single-page site is the centerpiece of the kit. Use
`assets/website-template.html` — a self-contained, dependency-light template (Google Fonts +
inline CSS, vanilla JS). A finished render of it lives at the sample kit's source listing.

## Steps
1. Copy `assets/website-template.html` → `04-website/index.html`.
2. Create `04-website/assets/img/` and `04-website/assets/video/`; copy in the chosen
   enhanced + source photos and the two clips. Keep filenames stable (the template expects
   `hero-twilight.jpg`, `pool-sunset.jpg`, `interior-greatroom.jpg`, `patio-family.jpg`,
   `aerial-sunset.jpg`, `firepit-dusk.jpg`, `beach-sunset.jpg`, `tour-hero.mp4`,
   `tour-vertical.mp4` — rename your picks to match, or update the `src`s).
3. Replace the `{{PLACEHOLDERS}}`:
   - `{{PROPERTY_NAME}}`, `{{LOCATION_LINE}}`, `{{HERO_HEADLINE}}` (two lines via `<br>`),
     `{{HERO_SUB}}`
   - stat numbers: `{{BEDS}}`, `{{BATHS}}`, `{{SLEEPS}}`, `{{FEATURE_STAT}}`
   - `{{STORY_PARAGRAPH}}`, the three `{{SPLIT_*}}` blocks, `{{AMENITIES}}` (list items),
     `{{STRIP_*}}` quick facts, `{{CONTACT_EMAIL}}`
4. Preview it (Launch panel / open the file). Check the hero video autoplays muted+looped
   with the enhanced photo as its poster, the gallery hovers, and mobile collapses cleanly.
5. **Leave the footer AI-asset disclosure in place.**

## Design notes (already in the template) — cinematic, scroll-driven
- Editorial/architectural palette (warm sand + ink + oak accent), `Fraunces` italic display +
  `Inter` UI. Fixed brand topbar (mix-blend over media), top scroll-progress bar, side-dot nav.
- **The signature section is `.film`** — a sticky full-viewport media that **crossfades between
  rooms** as you scroll, while floating **glass spec-cards** and big italic captions advance per
  "act" (Arrival → Living → Water → Golden Hour). An IntersectionObserver (`rootMargin:-48%`)
  activates the matching `.film__layer` + `.step.on` card + updates the act label/caption. This
  is what makes the site *immediately, unmistakably about the property* — each scroll beat is a
  different real room with its own specs.
- To retarget: keep the **same number** of `.film__layer` images and `.step` blocks (4), and
  swap each layer's image + its step's `data-i/data-act/data-cap` and card specs together.
- Sections: HERO (video) · `.film` scrollytelling acts · HOST split (tour video + minis) ·
  GALLERY mosaic · "dossier" facts sheet + amenities · CTA · footer. Responsive at 820px.
- **Verify by scrolling**, not just loading: screenshot the hero and each act depth (the sticky
  crossfade only shows under real scroll). A live render of this template ships as the Clearwater
  site in the sample kit's source listing.

## Deploying (optional)
If the user wants it live, it's static — any of: drag the `04-website/` folder to Netlify
Drop, `vercel deploy`, or GitHub Pages. The Vercel MCP (`deploy_to_vercel`) can do it directly.
Offer this; don't deploy without being asked.

## Marketing copy file (`05-marketing-copy/copy.md`)
Generate alongside the site: hero headline options, one-line summary, long description,
feature bullets, social captions (IG/Reel, Facebook, TikTok hook), and the **owner-outreach
email** (subject + body with `{owner_first_name}`, `{website_link}`, `{assets_link}`,
`{your_name}` placeholders). See the sample kit's `copy.md`.
