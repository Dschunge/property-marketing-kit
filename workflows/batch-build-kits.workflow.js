export const meta = {
  name: 'batch-build-kits',
  description: 'Fan out the property-marketing-kit pipeline across many listings in parallel',
  whenToUse: 'When you have several listing URLs and want a full marketing kit built for each.',
  phases: [
    { title: 'Scrape', detail: 'pull details + photos per listing' },
    { title: 'Generate', detail: 'enhance photos, cinematic tour, host walkthrough, reel' },
    { title: 'Assemble', detail: 'website + marketing copy per listing' },
    { title: 'Verify', detail: 'QA each kit (faces, architecture, links, disclosure)' },
  ],
}

// args: { urls: string[], creditCapPerKit?: number, hostPhotoMediaId?: string, outRoot?: string }
const urls = (args && args.urls) || (Array.isArray(args) ? args : [])
const cap = (args && args.creditCapPerKit) || 90
const host = (args && args.hostPhotoMediaId) || null
const outRoot = (args && args.outRoot) || './property-marketing-kits'
if (!urls.length) { log('No listing URLs provided in args.urls'); return { built: [] } }

log(`Building ${urls.length} kit(s); credit cap/kit=${cap}${host ? '; host enabled' : ''}`)

const KIT = {
  type: 'object', additionalProperties: true,
  properties: {
    slug: { type: 'string' },
    name: { type: 'string' },
    folder: { type: 'string' },
    assets: { type: 'array', items: { type: 'string' } },
    websitePath: { type: 'string' },
    creditsSpent: { type: 'number' },
    issues: { type: 'array', items: { type: 'string' } },
  },
  required: ['slug', 'folder'],
}

// Each listing runs the whole skill pipeline independently (no barrier between stages).
const kits = await pipeline(
  urls,

  // 1) Scrape → organized folder + listing.json + downloaded photos
  (url, _orig, i) => agent(
    `Use the property-marketing-kit skill, step 1–2, on this listing: ${url}
     Scrape details + the full photo gallery (verify each photo belongs to THIS property),
     scaffold the kit folder under ${outRoot}/<slug>/ with scripts/new_kit.sh, download the
     originals, and write listing.json with a labeled photo manifest. Return the kit folder path
     and the slug.`,
    { label: `scrape:${i + 1}`, phase: 'Scrape' }
  ),

  // 2) Generate Higgsfield assets (respect the credit cap and the 3-concurrent-job limit)
  (scrapeResult, url, i) => agent(
    `Continue the property-marketing-kit skill (steps 3–4) for the kit at: ${scrapeResult}
     Enhance 3–5 hero photos (Nano Banana Pro), generate a cinematic property tour and a 9:16
     vertical reel, and ${host ? `a HOST walkthrough using person media_id ${host} composited into the real rooms, then animated` : 'optionally a host walkthrough if a person photo is available'}.
     Stitch clips into one tour with ffmpeg (see references/video-stitching.md). PREFLIGHT every
     generation with get_cost and stay under ${cap} credits total; submit videos in waves of 3.
     Save everything into the kit folder. Return the list of asset paths and credits spent.`,
    { label: `generate:${i + 1}`, phase: 'Generate' }
  ),

  // 3) Website + copy
  (genResult, url, i) => agent(
    `Continue the property-marketing-kit skill (steps 5–6) for this listing (${url}).
     Build 04-website/index.html from assets/website-template.html using the enhanced photos,
     host shots and tour videos, and write 05-marketing-copy/copy.md (headlines, captions, owner
     email). Return the website path.`,
    { label: `assemble:${i + 1}`, phase: 'Assemble', schema: KIT }
  ),

  // 4) Verify (adversarial QA)
  (kit, url, i) => agent(
    `Adversarially QA this property kit: ${JSON.stringify(kit)}.
     Check: every website asset path resolves; host face is consistent and undistorted across
     shots; enhanced photos kept the real architecture; the AI-asset disclosure is present; the
     tour plays end to end. Return the kit with an issues[] array (empty if clean).`,
    { label: `verify:${i + 1}`, phase: 'Verify', schema: KIT }
  ),
)

const built = kits.filter(Boolean)
const clean = built.filter(k => !(k.issues && k.issues.length))
log(`Done: ${built.length} kit(s), ${clean.length} clean. Review any with issues before sending.`)
return { built, clean: clean.length }
