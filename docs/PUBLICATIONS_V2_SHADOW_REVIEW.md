# Publications v2 Stage A/B Shadow Review

## Scope and result

This review covers only the Stage A baseline and Stage B shadow-data migration
defined in `docs/PUBLICATIONS_V2_RFC.md`. The legacy include remains the
production source, the shadow dataset is not referenced by any template, and no
public URL or rendered publication page is changed.

The migration preserves all 52 CV records in their existing order. Each
canonical `citation` is the corresponding legacy `<li>` text after deterministic
HTML entity decoding only; whitespace and punctuation are not normalized.

## Metadata inventory

| Check | Count | Interpretation |
|---|---:|---|
| Total records | 52 | Matches the current CV bibliography |
| Explicit DOI present | 7 | DOI appears directly in the accepted citation text |
| DOI missing | 45 | Left `null`; no DOI lookup or inference was performed |
| Article URL present | 7 | Derived only as `https://doi.org/{bare DOI}` |
| Title separation incomplete | 52 | Structured `title` remains `null` |
| Author separation incomplete | 52 | `authors.display` is `null`; `authors.parsed` is empty |
| Venue-name separation incomplete | 52 | Structured venue name remains `null` |
| Volume separation incomplete | 52 | Structured volume remains `null` |
| Issue separation incomplete | 52 | Structured issue remains `null` |
| Page/article-number separation incomplete | 52 | Both fields remain `null` |
| Publication type `unknown` | 52 | Type classification is deferred |
| Research-program assignments | 0 | Editorial classification is deferred |
| Keyword assignments | 0 | Keyword curation is deferred |
| `partially-verified` provenance | 7 | Limited to records with an explicit DOI |
| `unparsed` provenance | 45 | Citation parity is verified, but structured metadata is not parsed |
| `verified` provenance | 0 | No record is promoted to fully verified in Stage B |
| PDF actions | 0 | Every `links.pdf` value is `null` |
| Code actions | 0 | No approved code links were available in the migration sources |
| Data actions | 3 | Existing approved GEO links for the scFLUENT-seq detail record |
| Graphical abstracts in shadow data | 0 | No graphical-abstract metadata was added |
| Detail slugs | 1 | The already-existing `2025-scfluent-seq` detail record only |

“Incomplete” above means that the dedicated structured field was deliberately
left empty. It does not mean that the accepted citation string was altered or
dropped; every record remains fully available through its exact citation.

## Assumptions and deliberate nulls

- The legacy `<li>` sequence is the only authority for the 52 citation strings
  in this stage.
- HTML entity decoding uses Ruby's standard-library `CGI.unescapeHTML`. No
  trimming, whitespace collapsing, punctuation normalization, or title/author
  parsing is performed.
- The full-sequence checksum serializes the decoded citations in order, joined
  by a single LF byte with no trailing LF.
- Stable IDs use the approved semantic ID `pub-2025-scfluent-seq` for the one
  existing detail record and zero-padded source-order IDs (`pub-cv-002` through
  `pub-cv-052`) for the remaining records. IDs must not be recycled if future
  curation changes display order.
- A DOI is populated only when an explicit `doi:` token occurs in the accepted
  citation. It is stored as a bare DOI, and its article URL is derived without
  changing the DOI value.
- Titles, authors, venue parts, years, dates, PMID, ISBN, publication types,
  research programs, and keywords remain unresolved where this stage would
  require parsing, external verification, or editorial judgment.
- The existing scFLUENT-seq GEO links, featured state, selected state, and real
  detail slug are copied from its approved collection record. Its absent local
  PDF remains `null`; the PDF path written in the legacy detail front matter is
  not carried into the shadow data because the file does not exist and has not
  been approved for public distribution.
- The existing scFLUENT-seq graphical abstract remains part of the unchanged
  detail page. No graphical-abstract path is added to the canonical shadow
  bibliography.
- No unpublished manuscript record or title is added. The checker enforces
  exact citation parity and keeps all free-form structured bibliographic fields
  empty in this stage.

## Deferred editorial work

Research-program classification is intentionally a later, separate editorial
review. It must use only the RFC values and must not be inferred from paper
titles alone. Publication-type classification and structured parsing of title,
authors, venue, date, volume, issue, pages, and article numbers are likewise
deferred until each value has an approved source or explicit editorial decision.

## Reproducibility and validation

The baseline records per-citation SHA-256 values and one checksum for the full
ordered sequence. The verifier regenerates the expected legacy sequence in
memory, decodes entities deterministically, and checks the JSON baseline and
YAML shadow data against it.

Run:

```bash
ruby _tools/verify_publications_shadow.rb
JEKYLL_ENV=production bundle exec jekyll build
bundle exec htmlproofer ./_site --disable-external
git diff --check
git status --short
```

The optional generation mode is deterministic and is intended only for
rebuilding the two derived artifacts from the unchanged approved sources:

```bash
ruby _tools/verify_publications_shadow.rb --generate
```

After generation, the verifier must be run normally. Production rendering must
continue to use `_includes/full-publications.html`; `_data/publications.yml`
must remain unused until a separately reviewed implementation stage.

## Files added in Stage A/B

- `docs/publications-v2-baseline.json`
- `_data/publications.yml`
- `_tools/verify_publications_shadow.rb`
- `docs/PUBLICATIONS_V2_SHADOW_REVIEW.md`

No existing website, collection, style, layout, configuration, dependency,
asset, workflow, or deployment file is modified.
