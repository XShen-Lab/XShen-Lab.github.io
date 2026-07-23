# Publications v2 Architecture RFC

- **Status:** Proposal only
- **Decision:** Recommend a hybrid architecture: canonical bibliography data for all records plus enriched collection records only for papers with detail pages
- **Scope:** Publication data architecture, rendering boundaries, validation, and staged migration
- **Out of scope:** Implementing the proposal, verifying or completing bibliography metadata, changing scientific prose, and changing deployment workflows

## 1. Executive summary

Publications v2 should use `_data/publications.yml` as the single canonical source for all 52 bibliography records. The `_publications` collection should remain, but only for papers that need an enriched detail page. Each detail record must reference a canonical publication by `publication_id` and must not repeat canonical fields such as title, authors, journal, year, DOI, volume, issue, pages, or citation text.

This hybrid model is recommended because it:

1. preserves the exact 52-record CV bibliography without requiring 52 output pages;
2. gives English and Chinese pages the same canonical English bibliographic data;
3. supports filtering and sorting from structured data;
4. keeps bilingual explanatory prose separate from invariant citation fields;
5. supports selected graphical abstracts and optional detail pages;
6. enables DOI, PDF, Data, and Code actions only when their metadata passes validation;
7. preserves `/publications/2025-scfluent-seq/`; and
8. permits an incremental migration with a feature flag and a low-cost rollback.

The migration must be additive first. The current `_includes/full-publications.html` should remain the production renderer until all 52 canonical records pass count, order, and verbatim-citation parity checks. Missing metadata must remain null or absent. No migration phase may infer missing DOI, dates, authors, volume, issue, pages, publication type, or research-program assignment.

## 2. Current implementation

### 2.1 Data and rendering flow

The current implementation has two publication representations:

```text
_publications/2025-scfluent-seq.md
  -> Jekyll publications collection
  -> featured card on /publications/ and /zh/publications/
  -> detail page at /publications/2025-scfluent-seq/

_includes/full-publications.html
  -> 52 literal <li> records copied from the CV
  -> included by /publications/
  -> included by /zh/publications/
```

The English and Chinese publication pages each contain their own explanatory sections and latest-publication excerpts. Both pages share `_includes/full-publications.html` for the complete bibliography and iterate `site.publications` for the featured card.

### 2.2 Observed constraints

- `_publications/2025-scfluent-seq.md` is the only collection record.
- `_includes/full-publications.html` contains exactly 52 list items.
- The collection permalink is `/publications/:name/`.
- The scFLUENT-seq graphical abstract exists locally.
- Its front matter contains a PDF path, but that PDF file is absent. The current detail page does not render a PDF action.
- `_data/citations.yaml`, `_data/sources.yaml`, and `_cite/` belong to the upstream template's citation automation and currently contain unrelated/template data. They are not a trustworthy source for this 52-record bibliography and must not be merged into Publications v2 without a separate verification project.
- Bibliographic formatting is heterogeneous because it preserves the supplied CV. Several records lack one or more normally structured fields.

### 2.3 Architectural problem

The current full bibliography is safe as a verbatim display source but cannot support reliable filtering, sorting, per-record actions, or classification. The one structured collection record supports enrichment, but making every CV entry a collection file would create 51 additional files and, with `output: true`, would encourage unnecessary detail pages.

Publications v2 therefore needs to separate:

1. **canonical bibliography facts** shared by every language and every renderer;
2. **localized explanatory content** used only when approved;
3. **presentation and enrichment metadata** used only when an asset or action actually exists; and
4. **output pages**, which should exist only for selected records.

## 3. Goals and non-goals

### 3.1 Goals

- Maintain exactly one authoritative bibliography record for each formal CV item.
- Preserve the original English citation text and CV order.
- Allow incomplete records without placeholder or inferred values.
- Render the same English title, author, journal, DOI, and citation details on English and Chinese pages.
- Support year, publication type, research program, featured status, and other filters when those fields are explicitly curated.
- Support selected graphical abstracts without inventing asset paths.
- Support optional detail pages while preserving existing URLs.
- Render DOI, PDF, Data, and Code buttons only when the associated value is present and validated.
- Support English and Chinese explanatory summaries, captions, significance text, and UI labels.
- Make invalid or contradictory metadata fail validation before publication.
- Permit staged adoption and fast rollback.

### 3.2 Non-goals

- Completing missing bibliography fields.
- Normalizing all author or journal formatting during migration.
- Translating paper titles, author strings, journal names, DOI values, accession numbers, or citation text.
- Automatically importing publisher, ORCID, PubMed, Crossref, or Google Scholar data.
- Creating detail pages for all 52 records.
- Publishing unpublished manuscript titles.
- Adding PDF links for files that are absent or not approved for public distribution.
- Rewriting the current English or Chinese scientific narrative.

## 4. Architecture options

### 4.1 Comparison matrix

| Criterion | 1. All 52 as `_publications` files | 2. `_data/publications.yml` plus selected pages | 3. Hybrid canonical data plus enriched collection records |
|---|---|---|---|
| Single source of truth | Good if every field lives in each collection file, but canonical facts and page prose become coupled | Good if detail pages reference data; weak if pages repeat citation fields | Excellent when validators forbid canonical fields in detail records |
| Bilingual rendering | Possible, but localized fields would be repeated across many files | Strong; both language pages read the same data | Strongest; invariant bibliography is shared and enrichment is localized separately |
| Jekyll complexity | Low to medium rendering complexity; high collection/output management complexity | Medium; requires data lookup from selected pages | Medium upfront; reusable join helpers and validation reduce long-term complexity |
| Maintenance burden | High: 52 files plus future details | Low for bibliography; selected pages may use a second page convention | Low: one bibliography file plus a small number of thin enriched records |
| Detail-page support | Excellent but implicitly encourages a page for every record | Adequate; selected pages need manual data lookup and route conventions | Excellent for selected records; collection already provides stable page routing |
| Filtering and sorting | Strong through `site.publications` | Strong through `site.data.publications` | Strong through canonical data; enrichment is joined only where needed |
| Graphical abstracts | Easy, but asset fields appear in 52 records whether needed or not | Easy in data or selected pages; ownership can become ambiguous | Clear: selected detail record owns approved visual enrichment |
| PDF/Data/Code support | Easy, but weak separation between verified links and page content | Easy in canonical data; selected-page duplication must be prevented | Strong: public action metadata is canonical and validated; detail records add presentation only |
| Migration risk | High: split a trusted 52-item list into 52 files and change output behavior at once | Medium: safe for list migration, but current collection detail page becomes a special case | Lowest: migrate bibliography independently, then thin the existing detail record after parity |
| scFLUENT-seq compatibility | Natural file location, but its fields must be reconciled with 51 new peers | Awkward unless the existing collection remains as an exception | Natural: preserve the collection record and URL, replace duplicated facts with `publication_id` |

### 4.2 Approach 1: one collection file for every publication

Under this model, all 52 publications become files in `_publications/`. The full list, filters, cards, and detail pages all iterate `site.publications`.

**Advantages**

- Jekyll natively exposes every record as a document.
- Per-record front matter is convenient for detail layouts.
- Filtering and sorting are straightforward.
- Assets and action buttons can be declared near page content.

**Disadvantages**

- Fifty-one new files are required before the architecture becomes authoritative.
- With the collection configured as `output: true`, every record tends to acquire a public detail URL even when no meaningful detail content exists.
- Citation facts, bilingual explanatory prose, and page routing are coupled in the same file.
- Global schema changes require touching many files.
- Migration from a trusted ordered HTML list to 52 independent files creates a high risk of dropped, duplicated, or reordered records.
- A record with only a verbatim citation would still need a mostly empty front matter document.

**Assessment**

This option is attractive for a publication-heavy site in which nearly every paper has a curated detail page. It does not fit the current site, where only one paper has enrichment and many records are intentionally incomplete.

### 4.3 Approach 2: one data bibliography plus selected detail pages

Under this model, `_data/publications.yml` stores all 52 records. Selected detail pages are ordinary Markdown pages or retained collection pages that look up a data record by ID.

**Advantages**

- Compact and maintainable canonical bibliography.
- Excellent list filtering and sorting.
- Both languages can render identical citation fields.
- Records without details do not create pages.
- Migration can begin with verbatim citation strings and add parsed fields later.

**Disadvantages**

- Jekyll data objects do not have native document URLs.
- Selected detail pages need a separate lookup and permalink convention.
- Without explicit validation, a detail page can duplicate and drift from the data record.
- The existing `_publications/2025-scfluent-seq.md` becomes an exception or must be moved, increasing compatibility risk.

**Assessment**

This is a strong model for the complete list, but by itself it does not explain how the existing collection page and future selected pages should be governed.

### 4.4 Approach 3: hybrid canonical bibliography and enriched featured records

Under this model:

- `_data/publications.yml` is authoritative for every bibliographic fact, classification, and public external/internal action.
- `_publications/*.md` exists only for selected records with a detail page.
- A detail record contains `publication_id` and enrichment fields only.
- Shared includes resolve the canonical record by ID and combine it with approved localized enrichment.
- Validators reject missing IDs, duplicated canonical fields, invalid enumerations, absent local assets, and invalid button targets.

**Advantages**

- Strong single-source-of-truth behavior.
- Minimal file count.
- Existing collection URL remains intact.
- Detail pages remain optional.
- Bilingual prose is possible without translating citation facts.
- The complete list can migrate before the detail page is refactored.
- Graphical abstracts and detail prose stay limited to curated papers.
- Filters read a single stable dataset.

**Disadvantages**

- Requires a small join layer in Liquid.
- Requires explicit validation because canonical data and enrichment live in different files.
- Contributors must understand which fields belong in canonical data and which belong in detail records.

**Assessment**

The additional rules are worthwhile because they prevent the two sources from drifting. This option best fits the present one-detail-page architecture and the desired future feature set.

## 5. Recommendation

Adopt **Approach 3: hybrid canonical bibliography data plus enriched collection records**.

The governing rule is:

> A bibliographic or public-link fact may exist only in `_data/publications.yml`. A `_publications` document may reference that fact by `publication_id`, but may contain only page routing and approved enrichment.

This rule should be enforced by a build-time validator, not only by contributor documentation.

## 6. Proposed file tree

The following is the target architecture. It is a proposal, not an implementation performed by this RFC.

```text
_config.yaml

_data/
  publications.yml                 # canonical 52-record bibliography
  publications_ui.yml              # localized UI labels and filter labels

_publications/
  2025-scfluent-seq.md             # thin enriched English detail record
  ...                              # only future papers with approved detail pages

zh/
  publications/
    index.md                        # Chinese list/explanatory page
    2025-scfluent-seq/
      index.md                      # optional thin Chinese route stub

_layouts/
  publication.html                 # shared detail-page layout

_includes/
  publications/
    list.html                       # canonical list iterator
    citation.html                   # verbatim/structured citation renderer
    card.html                       # selected/featured card
    actions.html                    # DOI/PDF/Data/Code actions
    filters.html                    # filter controls and data attributes
    detail.html                     # joins canonical data with enrichment

_plugins/
  validate_publications.rb          # build-time schema and cross-file validation

_scripts/
  publications.js                  # optional client-side filters, no data ownership

_styles/
  _publications.scss                # existing publication styles extended as needed

publications/
  index.md                          # English page retains reviewed narrative

docs/
  PUBLICATIONS_V2_RFC.md

# retained during migration only
_includes/
  full-publications.html            # legacy renderer and rollback source
```

The existing collection permalink `/publications/:name/` should remain unchanged. The current scFLUENT-seq English URL must therefore remain `/publications/2025-scfluent-seq/`.

## 7. Canonical bibliography schema

### 7.1 File envelope

`_data/publications.yml` should use a versioned envelope rather than a bare array:

```yaml
schema_version: 2
source:
  name: X.Shen CV FULL PUBLICATIONS
  record_count: 52
  policy: preserve-verbatim-citation

records:
  - id: pub-2025-scfluent-seq
    cv_order: 1
    citation: >-
      Ma S*, Hong Y, Chen J, Xu J, Shen X*. Single-cell nascent
      transcription reveals sparse genome usage and plasticity. Cell.
      2025. doi: 10.1016/j.cell.2025.09.003. (* co-corresponding).

    title: Single-cell nascent transcription reveals sparse genome usage and plasticity
    authors:
      display: Ma S*, Hong Y, Chen J, Xu J, Shen X*
      parsed: []
    venue:
      name: Cell
      volume: null
      issue: null
      pages: null
      article_number: null
    year: 2025
    date: null
    date_precision: year
    publication_type: research-article

    identifiers:
      doi: 10.1016/j.cell.2025.09.003
      pmid: null
      isbn: null

    research_programs:
      - cell-fate-dynamics
    keywords: []

    links:
      article: https://doi.org/10.1016/j.cell.2025.09.003
      pdf: null
      data:
        - label: GSE278775
          url: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278775
        - label: GSE278776
          url: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278776
        - label: GSE278777
          url: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278777
      code: []
      supplementary: []

    presentation:
      featured: true
      selected: true
      detail_slug: 2025-scfluent-seq

    provenance:
      source_record: 1
      citation_verbatim: true
      structured_fields_status: partially-verified
      notes: []
```

The example demonstrates shape only. Migration must preserve the accepted citation exactly and must not copy currently unverified fields into the canonical record merely because they appear in another site field.

### 7.2 Field reference

| Field | Type | Required | Rules |
|---|---|---:|---|
| `schema_version` | integer | yes | Must equal the validator-supported major version |
| `source.name` | string | yes | Human-readable provenance; not shown as a citation |
| `source.record_count` | integer | yes | Must equal `records.length`; initially 52 |
| `source.policy` | enum | yes | Initially `preserve-verbatim-citation` |
| `records` | array | yes | Exactly one object per formal bibliography record |
| `records[].id` | string | yes | Stable, unique, lowercase slug matching `^pub-[a-z0-9][a-z0-9-]*$`; never recycled |
| `records[].cv_order` | integer | yes | Unique positive integer; initial migration must be exactly 1–52 |
| `records[].citation` | string | yes | Canonical English display citation; preserved verbatim except YAML-safe encoding |
| `records[].title` | string/null | no | English only; null when not safely separable from source |
| `records[].authors.display` | string/null | no | English source display form; may preserve contribution symbols |
| `records[].authors.parsed` | array | no | Optional verified structured authors; empty until deliberately curated |
| `records[].authors.parsed[].family` | string/null | conditional | Must not be guessed from ambiguous source formatting |
| `records[].authors.parsed[].given` | string/null | conditional | Must not expand initials without an approved source |
| `records[].authors.parsed[].literal` | string | conditional | Safe fallback for unparsed author tokens |
| `records[].authors.parsed[].roles` | array | no | Closed values such as `corresponding`, `co-first`; only when explicitly supported |
| `records[].venue.name` | string/null | no | English journal, book, series, or venue text |
| `records[].venue.volume` | string/null | no | String preserves suffixes and nonnumeric values |
| `records[].venue.issue` | string/null | no | String preserves combined or nonnumeric issues |
| `records[].venue.pages` | string/null | no | Preserve source punctuation and article ranges; no normalization by inference |
| `records[].venue.article_number` | string/null | no | Used instead of pages when explicitly supplied |
| `records[].year` | integer/null | no | Only when explicitly present |
| `records[].date` | ISO date string/null | no | Never manufacture month/day for sorting |
| `records[].date_precision` | enum/null | no | `year`, `month`, or `day`; must agree with available date data |
| `records[].publication_type` | enum | yes | Use `unknown` when the source does not support a specific type |
| `records[].identifiers.doi` | string/null | no | Bare DOI, not a URL; preserve case/content, compare uniqueness case-insensitively |
| `records[].identifiers.pmid` | string/null | no | Only from an approved source |
| `records[].identifiers.isbn` | string/null | no | Only for applicable book/chapter records |
| `records[].research_programs` | array | yes | Zero or more allowed values; empty means unclassified |
| `records[].keywords` | array | yes | Curated English technical terms; empty until approved |
| `records[].links.article` | URL/null | no | Publisher or canonical article URL; DOI URL may be generated from a verified DOI |
| `records[].links.pdf` | object/null | no | Requires `path`, `public: true`, local existence, and distribution approval |
| `records[].links.data` | array | yes | Each item requires English `label` and valid URL |
| `records[].links.code` | array | yes | Each item requires English `label` and valid URL |
| `records[].links.supplementary` | array | yes | Optional verified supplementary resources |
| `records[].presentation.featured` | boolean | yes | Controls featured-card eligibility, not scientific importance |
| `records[].presentation.selected` | boolean | yes | Controls selected-list eligibility |
| `records[].presentation.detail_slug` | string/null | no | Must match exactly one detail record when non-null |
| `records[].provenance.source_record` | integer | yes | Corresponds to the formal CV order/source item |
| `records[].provenance.citation_verbatim` | boolean | yes | Must be true for initial migration |
| `records[].provenance.structured_fields_status` | enum | yes | `unparsed`, `partially-verified`, or `verified` |
| `records[].provenance.notes` | array | yes | Internal migration notes; must not render publicly by default |

### 7.3 Public PDF object

PDF actions require additional safeguards:

```yaml
links:
  pdf:
    path: /files/publications/example/example.pdf
    public: true
    label: PDF
```

The validator must reject the object unless:

- `path` is an absolute site path under an approved public files directory;
- the referenced file exists;
- `public` is exactly `true`; and
- the record does not rely on a remote or guessed file path.

The current absent scFLUENT-seq PDF must remain `null` and must not produce a button.

## 8. Enriched detail-record schema

A selected `_publications/*.md` record should become a thin reference plus approved enrichment:

```yaml
---
publication_id: pub-2025-scfluent-seq
layout: publication

graphical_abstract:
  path: /images/publications/2025-scfluent-seq/graphical-abstract.webp
  alt:
    en: Graphical abstract for Single-cell nascent transcription reveals sparse genome usage and plasticity
    zh-CN: Single-cell nascent transcription reveals sparse genome usage and plasticity 图文摘要
  credit: null

localized:
  en:
    short_title: Sparse single-cell genome usage
    summary: scFLUENT-seq reveals sparse and stochastic genome usage in individual cells and links transcriptional diversity to cellular plasticity.
    metric: 0.02–3.1% of the genome transcribed per cell
    sections: []
  zh-CN:
    short_title: null
    summary: null
    metric: null
    sections: []
---
```

Rules for detail records:

- `publication_id` is required and must match one canonical record.
- Canonical keys are forbidden: `title`, `authors`, `journal`, `venue`, `year`, `date`, `doi`, `volume`, `issue`, `pages`, `identifiers`, `links`, and `citation`.
- `layout` must be the shared publication layout.
- `graphical_abstract` is optional and its local path must exist.
- `localized` may contain only `en` and `zh-CN`.
- Explanatory fields are optional and must be approved text, not generated translations.
- Empty or absent Chinese enrichment falls back according to Section 11 rather than inventing content.
- The file name and collection permalink preserve the existing English detail URL.

An optional Chinese route stub may reference the same record without duplicating enrichment:

```yaml
---
layout: publication
lang: zh-CN
publication_id: pub-2025-scfluent-seq
detail_source: 2025-scfluent-seq
permalink: /zh/publications/2025-scfluent-seq/
---
```

Chinese detail routes should be introduced only when approved. They are not required to migrate the full bibliography.

## 9. Allowed publication types

`publication_type` is a closed enum:

- `research-article`
- `review`
- `commentary`
- `editorial`
- `methods-protocol`
- `book-chapter`
- `conference-proceeding`
- `preprint`
- `correction`
- `other`
- `unknown`

`unknown` is the required value when the source does not justify a more specific classification. `unpublished` is intentionally not allowed for the public 52-record bibliography because unpublished manuscript titles must not be exposed.

Changing a record from `unknown` to another type requires an approved source or explicit editorial decision.

## 10. Allowed research-program values

`research_programs` is a zero-or-more array containing only:

- `genome-organization`
- `rna-networks`
- `transcriptional-surveillance`
- `cell-fate-dynamics`
- `foundations`

Multiple values are allowed for cross-program papers. An empty array means “not yet classified” and must remain visible in the complete bibliography. No `other` or `unclassified` pseudo-program is needed because absence already represents that state.

Program assignments are editorial metadata, not bibliographic facts. They must be reviewed separately from the initial 52-record migration and must not be inferred solely from a title.

## 11. Bilingual field strategy

### 11.1 Language-invariant English fields

The following remain in English and have one shared value:

- citation;
- title;
- author display and parsed author names;
- venue/journal/book names;
- volume, issue, pages, and article numbers;
- DOI, PMID, ISBN, and other identifiers;
- data accession numbers;
- code repository names;
- software names; and
- technical link labels that are proper names, such as `GSE278775`.

These fields must never be duplicated as `title_zh`, `authors_zh`, or similar translated variants.

### 11.2 Localized fields

Only explanatory or interface text is localized:

- short title used as a site editorial label;
- summary;
- significance statement;
- metric explanation;
- graphical-abstract alt text;
- detail-page section headings and prose;
- filter labels;
- action button labels such as “View article” / “查看论文”; and
- empty-state and accessibility text.

Localized values use an explicit map:

```yaml
summary:
  en: Approved English explanatory text.
  zh-CN: 经审核的中文说明文字。
```

UI strings belong in `_data/publications_ui.yml`, not in each publication record.

### 11.3 Localized fallback

- Canonical bibliographic fields always render their single English value.
- A missing `zh-CN` optional explanatory value may fall back to the approved English value.
- A missing optional field in both languages is omitted; no placeholder sentence is generated.
- Required UI labels must exist in both languages; missing labels fail validation.
- A page must never machine-translate or synthesize missing text at build time.

## 12. Rendering behavior and fallbacks

### 12.1 Complete bibliography

- Default order remains `cv_order` ascending to reproduce the formal CV list.
- The canonical `citation` string is the safe fallback renderer for every record.
- Structured rendering may be introduced only after parity review; until then, filters may use structured fields while display remains verbatim.
- A record with incomplete structured fields still appears through `citation`.

### 12.2 Sorting

- “Formal CV order” uses `cv_order` only.
- “Newest first” uses explicit `year` descending, then explicit `date` where available, then `cv_order` ascending as the deterministic tie breaker.
- Missing month/day must not be represented as January 1 or any other synthetic date.
- Records with null `year` remain in the full list and sort after dated records in year-based views.

### 12.3 Detail links

- If `presentation.detail_slug` is present and validated, title/card links may point to the detail page.
- Without a detail page, the title is plain text or links to the verified article URL when appropriate.
- No empty detail route or placeholder page is generated.

### 12.4 Graphical abstracts

- Render only when an approved local asset exists.
- If absent, use a text-only card layout; do not insert a fake graphical abstract path.
- Missing localized alt text falls back to approved English alt text.
- An absent image must not trigger a broken `<img>` element.

### 12.5 Actions

- DOI/Article: render only for a valid DOI or approved article URL.
- PDF: render only for a present, approved local public file.
- Data: render one action per verified dataset URL/accession.
- Code: render one action per verified repository or code URL.
- Supplementary: render only for approved URLs.
- Omit the entire action group when no actions exist.

### 12.6 Filtering

- Filters operate on canonical fields only.
- Initial filters may include year, publication type, research program, featured, and selected.
- Empty classifications remain accessible through “All publications”; they are not silently excluded.
- Client-side filtering enhances a fully rendered list. The complete bibliography remains usable without JavaScript.

## 13. Validation rules

Validation should run during `bundle exec jekyll build` through `_plugins/validate_publications.rb`. It should fail the build with record IDs and actionable messages.

### 13.1 Dataset integrity

1. `schema_version` is supported.
2. `source.record_count` equals the array length.
3. Initial migration contains exactly 52 records.
4. IDs are unique and match the ID pattern.
5. `cv_order` values are unique and initially equal 1–52 without gaps.
6. Every record has a nonblank canonical `citation`.
7. Initial citation strings match an approved migration snapshot or checksum.
8. No record is silently dropped because structured fields are absent.

### 13.2 Metadata types and enums

1. All values match the schema types.
2. `publication_type` is allowed.
3. Every research-program value is allowed.
4. Localized maps contain only `en` and `zh-CN`.
5. `date_precision` agrees with the actual date value.
6. `year` and date values do not contradict each other.
7. Nullable fields use null/absence, not strings such as `TBD`, `unknown`, or guessed zeros.

### 13.3 Identifiers and links

1. DOI values use a bare DOI shape and are unique case-insensitively when present.
2. Generated DOI URLs must be derived without changing the DOI value.
3. Public URLs use supported schemes.
4. Internal paths resolve to generated pages or existing files.
5. PDF metadata requires an existing local file and `public: true`.
6. Data and Code entries require nonblank labels and URLs.
7. No action renders from an empty or invalid value.

### 13.4 Detail records and assets

1. Every detail record references exactly one canonical publication.
2. A canonical record may have at most one English collection detail record.
3. `detail_slug` matches the collection document and expected permalink.
4. Detail front matter contains no forbidden canonical fields.
5. Graphical-abstract paths exist and use approved asset locations.
6. Required alt text exists in English.
7. Optional Chinese route stubs reference an existing detail source.
8. The current scFLUENT-seq URL remains unchanged.

### 13.5 Rendered-output tests

1. English and Chinese full lists contain 52 records.
2. Their canonical citation sequences are identical.
3. The full-list order matches `cv_order`.
4. Filters do not remove records from the no-JavaScript baseline.
5. No broken image or empty action link is emitted.
6. Every rendered detail link resolves.
7. The scFLUENT-seq detail page still renders its title, citation facts, approved image, summary, metric, DOI, and three GEO links.
8. No PDF button renders while its approved local file is absent.

## 14. Migration sequence

### Phase 0: freeze and baseline

- Record the current 52-item count and exact displayed order.
- Save a machine-readable checksum of each current `<li>` text after deterministic HTML entity decoding only.
- Capture generated English and Chinese publication pages and the scFLUENT-seq detail page for comparison.
- Add tests that assert current public URLs.
- Do not change production rendering.

### Phase 1: create canonical data in shadow mode

- Create `_data/publications.yml` with 52 IDs, `cv_order`, exact `citation`, provenance, and only safely explicit structured fields.
- Use `unknown`, null, or empty arrays where classification/metadata is unresolved.
- Do not add filters or change existing pages.
- Validate count, unique IDs, order, and citation parity against the legacy include.

### Phase 2: add schema and build validation

- Add `_plugins/validate_publications.rb`.
- Add closed enums and link/asset validation.
- Validate the existing scFLUENT-seq asset and explicitly keep its PDF action absent.
- Keep `_includes/full-publications.html` authoritative in production.

### Phase 3: introduce data-driven full-list rendering behind a flag

- Add `_includes/publications/citation.html` and `_includes/publications/list.html`.
- Add a temporary `_config.yaml` flag such as `publications_v2.enabled: false`.
- When false, pages use `_includes/full-publications.html`.
- In review builds, enable v2 and compare all 52 English and Chinese rendered entries.
- Do not remove the legacy include.

### Phase 4: cut over the complete bibliography

- Enable the canonical data renderer after exact parity approval.
- Keep existing English and Chinese explanatory prose untouched.
- Confirm both languages render the same English citations.
- Keep the legacy include for immediate rollback for at least one release.

### Phase 5: refactor the scFLUENT-seq detail record

- Add `publication_id` to `_publications/2025-scfluent-seq.md`.
- Move canonical title/authors/journal/year/date/DOI/citation/link facts into `_data/publications.yml` only after parity validation.
- Retain graphical abstract and approved bilingual explanatory enrichment in the detail record.
- Add the shared publication layout and action include.
- Preserve `/publications/2025-scfluent-seq/` and compare generated output.
- Do not add the absent PDF button.

### Phase 6: add filters and classification

- Curate research-program values in a dedicated reviewed change.
- Add publication-type values only where supported; otherwise retain `unknown`.
- Add progressive-enhancement filter controls and client-side behavior.
- Verify all 52 records remain visible in the default/no-JavaScript view.

### Phase 7: add selected enrichment incrementally

- Add graphical abstracts only when approved local assets exist.
- Add optional detail records only when meaningful content is available.
- Add verified Data and Code actions per paper.
- Add Chinese detail routes and localized explanatory text only after review.

### Phase 8: retire legacy rendering

- Remove `_includes/full-publications.html` only in a separate cleanup change after at least one stable release.
- Remove the temporary feature flag only after rollback is no longer operationally necessary.
- Retain Git history and migration checksum artifacts for auditability.

## 15. Rollback plan

### 15.1 Before cutover

No public rollback is needed because canonical data and validators are additive. Disable shadow checks or revert the additive files if they block unrelated work.

### 15.2 After full-list cutover

Set `publications_v2.enabled: false` to restore `_includes/full-publications.html`. Because English and Chinese pages retain the legacy include path during the stabilization period, rollback requires no bibliography reconstruction.

### 15.3 After detail-page refactor

Revert the isolated scFLUENT-seq refactor commit while leaving the canonical dataset in place. The permalink remains unchanged, so rollback does not require redirects.

### 15.4 After legacy removal

Revert the separate cleanup commit that removed `_includes/full-publications.html`, then disable the v2 flag. Legacy removal must not be combined with schema migration or new enrichment in the same commit.

### 15.5 Data-integrity incident

If count, order, citation parity, or URL validation fails, fail the build and publish nothing. Do not silently fall back record-by-record because partial fallback could hide omissions. Roll back the renderer as a whole.

## 16. Exact files affected by a future implementation

This RFC itself creates only `docs/PUBLICATIONS_V2_RFC.md`. A future implementation is expected to affect the following exact files.

### 16.1 Files to create

- `_data/publications.yml`
- `_data/publications_ui.yml`
- `_layouts/publication.html`
- `_includes/publications/list.html`
- `_includes/publications/citation.html`
- `_includes/publications/card.html`
- `_includes/publications/actions.html`
- `_includes/publications/filters.html`
- `_includes/publications/detail.html`
- `_plugins/validate_publications.rb`
- `_scripts/publications.js` only when filters are implemented
- `zh/publications/2025-scfluent-seq/index.md` only when a Chinese detail route is approved

### 16.2 Files to modify

- `_config.yaml` for the temporary feature flag and publication layout defaults
- `_publications/2025-scfluent-seq.md` to become a thin enriched record after canonical parity
- `publications/index.md` to call shared v2 includes without rewriting reviewed narrative
- `zh/publications/index.md` to call the same shared v2 includes without rewriting reviewed narrative
- `_styles/_publications.scss` for filters, text-only cards, action states, and optional detail layout

### 16.3 Files to retain unchanged during initial migration

- `_includes/full-publications.html`
- `.github/workflows/*`
- `Gemfile`
- `Gemfile.lock`
- current scientific prose outside the publication rendering calls
- existing assets and public URLs

### 16.4 File to delete only in the final cleanup phase

- `_includes/full-publications.html`

The legacy include must not be deleted in the same change that first introduces canonical data or changes the scFLUENT-seq detail record.

## 17. Staged implementation plan

Each stage should be independently reviewable and reversible.

| Stage | Deliverable | Public behavior change | Exit criteria |
|---|---|---|---|
| A | Baseline tests and citation checksums | None | 52 items, current order, and URLs recorded |
| B | Canonical `_data/publications.yml` | None | Validator confirms 52 unique ordered verbatim records |
| C | Build-time validator and enums | None except invalid metadata blocks builds | All canonical and cross-file rules pass |
| D | Shadow data renderer | None in default configuration | V2 output matches legacy citations in both languages |
| E | Full-list cutover behind rollback flag | Complete list becomes data-driven | Build, HTML-Proofer, count/order parity, bilingual parity pass |
| F | scFLUENT-seq thin detail record | Internal data ownership changes; URL/content remain stable | Detail-page HTML and actions match approved baseline |
| G | Reviewed classifications and filters | Users can filter; default list unchanged | No-JavaScript list shows all 52; filters are deterministic |
| H | Incremental selected assets/actions/details | Only approved paper-specific enhancements | Each asset/link/detail passes validation and review |
| I | Legacy cleanup | No intended visible change | One stable release completed; rollback commit documented |

No stage should combine bibliography migration with scientific-copy edits or external metadata enrichment.

## 18. Maintenance workflow after migration

### Adding a bibliography record

1. Obtain an approved source record.
2. Add one canonical record with a new stable ID and explicit order policy.
3. Preserve the accepted citation text.
4. Populate only supported structured fields.
5. Leave type `unknown`, programs empty, and links null/empty when unresolved.
6. Run build validation and rendered list tests.

### Adding enrichment to an existing record

1. Confirm the canonical record ID.
2. Add or update a thin `_publications` record.
3. Add only approved local assets and localized explanatory text.
4. Add public actions to canonical data, not the detail record.
5. Validate the detail URL and all assets/actions.

### Correcting bibliography metadata

1. Perform the correction in `_data/publications.yml` only.
2. Record the approved source in provenance notes.
3. Review the English and Chinese output because both consume the same record.
4. Never patch only one language page.

## 19. Risks and mitigations

| Risk | Mitigation |
|---|---|
| A record is omitted or reordered during migration | Enforce 52 records, contiguous `cv_order`, and legacy citation checksums |
| Incomplete fields are accidentally filled by inference | Nullable schema, `unknown` enum, provenance status, and editorial review |
| Detail page drifts from canonical bibliography | Forbid canonical keys in detail front matter and validate `publication_id` |
| Chinese and English citations diverge | Both pages render the same canonical English record |
| An absent PDF becomes a broken/public button | Require local existence and explicit `public: true` |
| A graphical abstract path is invented | Require local asset existence; otherwise render a text-only card |
| Filters hide unclassified records | Full default list contains every record; filters are progressive enhancement |
| Existing scFLUENT-seq URL changes | Retain collection file name and `/publications/:name/` permalink |
| Template citation automation overwrites curated data | Keep Publications v2 independent of `_cite/` and `_data/citations.yaml` |
| Migration and cleanup become hard to roll back | Separate additive data, cutover, detail refactor, and legacy deletion into distinct changes |

## 20. Acceptance criteria for Publications v2

Publications v2 is complete only when:

- one canonical dataset contains every formal record exactly once;
- English and Chinese pages render the same 52 English citations in approved order;
- no missing metadata has been invented;
- filterable fields are schema-valid and explicitly curated;
- detail records cannot duplicate canonical facts;
- the current scFLUENT-seq URL and approved content remain valid;
- graphical abstracts render only from existing approved assets;
- DOI, PDF, Data, and Code buttons render only from validated values;
- pages remain usable without JavaScript;
- build-time validation, Jekyll build, HTML-Proofer, and rendered-output assertions pass; and
- the legacy renderer can be restored until the final cleanup stage is deliberately approved.

## 21. Decision

Proceed, in a future implementation task, with the hybrid architecture described in Approach 3. Begin with a shadow canonical dataset and validation. Do not restructure the existing scFLUENT-seq detail page or switch public rendering until all 52 records have passed exact count, order, and citation parity checks.
