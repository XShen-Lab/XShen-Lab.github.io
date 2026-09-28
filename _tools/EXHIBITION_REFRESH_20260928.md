# Exhibition refresh — 2026-09-28

## Scope and decisions

- Replaced the Goodsell artwork in the homepage/gallery display with an original, AI-generated conceptual Pol II illustration labeled RPB1–RPB12. This is not an atomic reconstruction and does not claim experimental subunit positions or dimensions. The factual reference is [Armache et al., J Biol Chem, 2005](https://doi.org/10.1074/jbc.M413038200), [PDB 1WCM](https://www.rcsb.org/structure/1WCM).
- Replaced the apple with the user-supplied geometric “98% noncoding DNA” artwork. Existing assets were retained.
- Added shared five-second automatic tours to Home, Research, People, Blog and the Gallery viewer. Transitions are eased. Tours pause on mouse hover, offscreen/hidden pages, keyboard tab interaction or the compact pause button. Reduced-motion preference disables autoplay by default; manual navigation remains available.
- Added an original CSS wooden wardrobe entrance with double opening doors, brass-colored handles and light beyond the doors. Clicking opens the Gallery viewer. No film still or copied Narnia artwork was used.
- Increased small/body typography, tightened spacing, reduced Research headings, and fixed inherited low-contrast dark-background text and excessive Research wrapper padding.
- Added a Research dropdown with overview and four existing section URLs, plus clickable research topics on the homepage. All existing permalinks remain unchanged.
- Technology now has five stages: Molecular (single-cell genomics and nascent transcriptomics), Spatial, Perturbation (AID), Biochemical reconstitution and Modeling, in both languages.
- Changed RNA as Nuclear Matter to an additive “and/既…也是…” relationship.
- Removed editorial title punctuation; preserved scientific compound terms, grammatical possessives and bibliographic records.
- Used the imagegen skill for the new scientific artwork; then set the RPB labels with an explicit verified Arial Bold font file.

## Figure provenance and watermarks

The user confirmed that Research 01's cover/title figure and all four Research 04 figures are published. Other Research images are unpublished. The same unpublished source artwork used in Home and Gallery also receives a watermark.

- Research 01: [Lu et al., Cell Research, 2021 — Homotypic clustering of L1 and B1/Alu repeats compartmentalizes the 3D genome](https://doi.org/10.1038/s41422-020-00466-6). Image attribution explicitly confirmed by the user.
- Research 04: [Ma et al., Cell, 2025 — Single-cell nascent transcription reveals sparse genome usage and plasticity](https://doi.org/10.1016/j.cell.2025.09.003). Existing graphical abstract, Fig. 2E–F, Fig. 7Diii and Fig. 7C assets retained.
- Published captions contain linked paper sources; the Gallery viewer also exposes the source link.
- The manifest `_data/figure_sources.yml` has 18 unpublished original-asset entries. Public display copies have two burned-in `XShen Lab · Unpublished` labels and use the `-watermarked` suffix. The original files remain untouched as required.
- Nine Gallery WebP derivatives are provided at actual 480/960-pixel widths. Three initial undersized preview variants were moved out of the repository into the task scratch archive; no pre-existing files were deleted.
- Watermarks identify publication status; they are not access controls. Existing original assets remain in the repository.
- No manuscript titles, invented bibliography fields or new public PDF buttons were added.

## Fonts and reproduction

Verified macOS metadata identifies:

- `/System/Library/Fonts/Supplemental/Arial.ttf` as Arial / ArialMT.
- `/System/Library/Fonts/Supplemental/Arial Bold.ttf` as Arial Bold / Arial-BoldMT.

Sharp's text renderer receives these explicit font files. The final RPB labels were visually inspected. No claim is made that other text already embedded in user-supplied/source images was converted to Arial.

Run with the existing Node environment exposing `sharp` and `playwright` through NODE_PATH:

```sh
node _tools/watermark-figures.cjs /absolute/path/to/Arial.ttf
node _tools/label-pol-ii.cjs /absolute/path/to/pol-ii-original-generated.png "/absolute/path/to/Arial Bold.ttf"
JEKYLL_ENV=production bundle exec jekyll build
bundle exec htmlproofer ./_site --disable-external
ruby _tools/verify_publications_shadow.rb
ruby _tools/verify_publications_renderer.rb
node _tools/verify-exhibitions.cjs
git diff --check
```

The browser check assumes a local production-build server at port 4181; SITE_URL and CHROME_PATH are optional overrides. This task used the bundled Node runtime and installed Google Chrome. The renderer check must run with plain `ruby` rather than nested `bundle exec ruby` in this local environment, because nested Bundler activation produced a LoadError after building; the plain-Ruby run passed both modes.

Final new display assets:

- `images/home/information-flow/pol-ii-subunits.webp` — 1254 × 1254.
- `images/home/information-flow/noncoding-genome-art.webp` — 1196 × 1082.

The generated illustration's geometry is intentionally conceptual. It should not be reused as a measured structural result. The source and limitation are explicit in the gallery caption.

## Validation

- Production Jekyll build passed.
- HTMLProofer internal checks passed: 80 HTML files, 130 internal links, hash checks in 77 files.
- Browser checks passed: five-second tours in all five relevant areas; pause/manual controls; Research wraparound; single-story Blog filters; Gallery opening, citation and focus restoration; reduced motion; published/unpublished exclusions.
- 24 responsive bilingual page/width combinations passed at 1440, 768, 390 and 320 pixels with no horizontal overflow or detected broken loaded images.
- Desktop/mobile Research, Gallery and navigation previews were visually inspected.
- Publication shadow and production/rollback renderer checks passed. All 52 records remain intact, with 13 representative cards in each language.
- Bibliography checksum: `2526131b41eae70abd0d7e1d4509543c590e9b9246771471e193cbe6b7bcde52`.
- Publication detail checksum: `fb5111662587f5715d0872014940ad509d15b75c6913a02212d0f05a27a4989d`.
- No GitHub Actions, deployment configuration, English directories, public URLs or bibliography data were changed.
- `git diff --check` passed.

## Storage

The Elements archive initially could not be accessed, so the authorized local pending directory was used. The volume became available during final validation and was checked as mounted, writable and with approximately 3.4 TiB free. The archive destination is:

`/Volumes/Elements/lab_mirror/lab_website/xshen-lab/exhibition-refresh_20260928/`

It contains the two source image originals, final previews, reproducible tools/manifest and this report. Archive integrity is recorded in `archive-manifest.json`. Scratch previews are not website assets and are not deployed.

## Image-generation prompt

> Use case: scientific-educational. Asset type: original scientific illustration for a university molecular biology lab website, square high-resolution 2048x2048. Create a clean conceptual schematic of the COMPLETE twelve-subunit eukaryotic RNA polymerase II complex, not an atomic structure. Make exactly twelve distinguishable connected, softly sculpted lobed protein subunits, each identified once with large readable Arial bold labels: RPB1, RPB2, RPB3, RPB4, RPB5, RPB6, RPB7, RPB8, RPB9, RPB10, RPB11, RPB12. Conceptual topology: RPB1 and RPB2 form the two large central lobes separated by the active-center cleft; RPB4/RPB7 form the protruding peripheral stalk as a pair; RPB3/RPB11 form a small assembly pair at the base; RPB5 near the front jaw, RPB6 at the RPB1 side, RPB8 at the opposite periphery, RPB9 at the upper jaw, RPB10/RPB12 small peripheral assembly units at the base. Large RPB1 slate blue, RPB2 warm ochre; other ten in distinct muted teal, moss, coral, plum colors with dark readable labels and fine leader lines where needed. View is educational and diagrammatic, not a claimed atomic reconstruction. Generous white or warm ivory background, centered compact composition, crisp forms and thin restrained outlines, tasteful softly shaded journal-cover quality. Do not include DNA or RNA because this is the apo complex; no molecular crowding, no cell environment, no copied artwork, no signatures, no additional headline or legend. Each of twelve labels must be legible and appear exactly once. Original layout created from the factual subunit composition of Saccharomyces cerevisiae Pol II (PDB 1WCM; Armache et al 2005).

The image tool returned a 1254-pixel square image; the delivered dimensions are reported as returned, not as the requested size.

## Complete repository file manifest

### Modified (29)

- `_data/gallery.yml`
- `_data/home.yml`
- `_data/research_page.yml`
- `_data/research_programs.yml`
- `_includes/blog/contribute.html`
- `_includes/blog/controls.html`
- `_includes/gallery/page.html`
- `_includes/header.html`
- `_includes/home.html`
- `_includes/people/gallery.html`
- `_includes/research/page.html`
- `_includes/scripts.html`
- `_layouts/default.html`
- `_posts/2026-08-23-simple-rules-of-life-rotation-zh.md`
- `_posts/2026-08-23-simple-rules-of-life-rotation.md`
- `_scripts/blog-flow.js`
- `_scripts/gallery.js`
- `_scripts/hero-carousel.js`
- `_scripts/member-gallery.js`
- `_scripts/research-flow.js`
- `_styles/-theme.scss`
- `_styles/editorial.scss`
- `_styles/gallery.scss`
- `_styles/paragraph.scss`
- `assets/css/site.scss`
- `blog/contribute/index.md`
- `blog/index.md`
- `zh/blog/contribute/index.md`
- `zh/blog/index.md`

### Created (39)

- `_data/figure_sources.yml`
- `_includes/figure-source.html`
- `_includes/research/menu.html`
- `_scripts/exhibit-autoplay.js`
- `_scripts/research-menu.js`
- `_styles/exhibitions.scss`
- `_tools/EXHIBITION_REFRESH_20260928.md`
- `_tools/label-pol-ii.cjs`
- `_tools/verify-exhibitions.cjs`
- `_tools/watermark-figures.cjs`
- `images/gallery/chromatin-rnp-mesh-watermarked.jpg`
- `images/gallery/noise-to-order-watermarked-480.webp`
- `images/gallery/noise-to-order-watermarked-960.webp`
- `images/gallery/noise-to-order-watermarked.jpg`
- `images/gallery/nuclear-rna-systems-model-watermarked-480.webp`
- `images/gallery/nuclear-rna-systems-model-watermarked.jpg`
- `images/gallery/productive-genome-usage-watermarked-480.webp`
- `images/gallery/productive-genome-usage-watermarked-960.webp`
- `images/gallery/productive-genome-usage-watermarked.jpg`
- `images/gallery/rna-as-matter-watermarked-480.webp`
- `images/gallery/rna-as-matter-watermarked-960.webp`
- `images/gallery/rna-as-matter-watermarked.jpg`
- `images/gallery/two-paradoxes-watermarked-480.webp`
- `images/gallery/two-paradoxes-watermarked-960.webp`
- `images/gallery/two-paradoxes-watermarked.jpg`
- `images/home/information-flow/information-flow-framework-watermarked.webp`
- `images/home/information-flow/noncoding-genome-art.webp`
- `images/home/information-flow/pol-ii-subunits.webp`
- `images/home/information-flow/transcription-dichotomy-watermarked.webp`
- `images/research/genome-organization/chromatin-rnp-nanodomains-watermarked.webp`
- `images/research/genome-organization/nuclear-architecture-dstorm-watermarked.webp`
- `images/research/rna-chromatin-dstorm-thumb-watermarked.png`
- `images/research/rna-chromatin-dstorm-watermarked.png`
- `images/research/rna-rbp-mesh-em-watermarked.png`
- `images/research/transcriptional-surveillance/ctd-perturbation-timecourse-watermarked.png`
- `images/research/transcriptional-surveillance/mechanism-model-watermarked.png`
- `images/research/transcriptional-surveillance/surveillance-core-watermarked.png`
- `images/research/transcriptional-surveillance/zga-activity-model-watermarked.png`
- `images/research/transcriptional-surveillance/zga-pol-ii-ser2p-watermarked.png`

### Deleted

None. All pre-existing assets are retained.
