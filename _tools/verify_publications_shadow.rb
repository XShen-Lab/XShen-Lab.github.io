#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "digest"
require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
LEGACY_PATH = File.join(ROOT, "_includes", "full-publications.html")
BASELINE_PATH = File.join(ROOT, "docs", "publications-v2-baseline.json")
DATA_PATH = File.join(ROOT, "_data", "publications.yml")
DETAIL_PATH = File.join(ROOT, "_publications", "2025-scfluent-seq.md")
PUBLICATIONS_COLLECTION_PATH = File.join(ROOT, "_publications")
CHINESE_DETAIL_PATH = File.join(ROOT, "zh", "publications", "2025-scfluent-seq", "index.md")
LANGUAGE_PAIRS_PATH = File.join(ROOT, "_data", "language_pairs.yml")
APPROVED_SEQUENCE_SHA256 = "2526131b41eae70abd0d7e1d4509543c590e9b9246771471e193cbe6b7bcde52".freeze

EXPECTED_URLS = [
  "/publications/",
  "/zh/publications/",
  "/publications/2025-scfluent-seq/"
].freeze

RECORD_KEYS = %w[
  id cv_order citation title authors venue year date date_precision
  publication_type identifiers research_programs keywords links presentation
  provenance
].freeze

ALLOWED_PUBLICATION_TYPES = %w[
  research-article review commentary editorial methods-protocol book-chapter
  conference-proceeding preprint correction other unknown
].freeze

ALLOWED_RESEARCH_PROGRAMS = %w[
  genome-organization rna-networks transcriptional-surveillance
  cell-fate-dynamics foundations
].freeze

ALLOWED_PROVENANCE_STATUSES = %w[
  unparsed partially-verified verified
].freeze

SCFLUENT_ID = "pub-2025-scfluent-seq".freeze
SCFLUENT_SLUG = "2025-scfluent-seq".freeze
SCFLUENT_ENGLISH_URL = "/publications/#{SCFLUENT_SLUG}/".freeze
SCFLUENT_CHINESE_URL = "/zh/publications/#{SCFLUENT_SLUG}/".freeze
SCFLUENT_STRUCTURED_FIELDS = {
  "title" => "Single-cell nascent transcription reveals sparse genome usage and plasticity",
  "authors" => {
    "display" => "Shaoqian Ma, Yantao Hong, Junhan Chen, Jingzhao Xu, and Xiaohua Shen",
    "parsed" => []
  },
  "venue" => {
    "name" => "Cell",
    "volume" => "188",
    "issue" => nil,
    "pages" => "6873–6891",
    "article_number" => nil
  },
  "year" => 2025,
  "date" => nil,
  "date_precision" => "year",
  "publication_type" => "research-article"
}.freeze
SCFLUENT_DATA_LINKS = [
  {
    "label" => "GSE278775",
    "url" => "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278775"
  },
  {
    "label" => "GSE278776",
    "url" => "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278776"
  },
  {
    "label" => "GSE278777",
    "url" => "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE278777"
  }
].freeze
DETAIL_ALLOWED_KEYS = %w[
  graphical_abstract layout localized publication_id
].freeze
DETAIL_FORBIDDEN_CANONICAL_KEYS = (RECORD_KEYS + %w[
  data doi featured image issue journal pages pdf short_title volume
]).uniq.freeze

class VerificationError < StandardError; end

def fail_unless(condition, message)
  raise VerificationError, message unless condition
end

def legacy_citations
  html = File.binread(LEGACY_PATH).force_encoding(Encoding::UTF_8)
  fragments = html.scan(/<li\b[^>]*>(.*?)<\/li>/mi).flatten

  fail_unless(fragments.length == 52,
              "legacy bibliography contains #{fragments.length} records, expected 52")
  fragments.each_with_index do |fragment, index|
    fail_unless(fragment !~ /<[^>]+>/,
                "legacy record #{index + 1} contains nested markup; decoder must be reviewed")
  end

  fragments.map { |fragment| CGI.unescapeHTML(fragment) }
end

def sequence_sha256(citations)
  Digest::SHA256.hexdigest(citations.join("\n"))
end

def verify_approved_sequence!(label, citations)
  actual = sequence_sha256(citations)
  fail_unless(actual == APPROVED_SEQUENCE_SHA256,
              "#{label} full-sequence checksum #{actual} does not match approved checksum")
end

def explicit_doi(citation)
  match = citation.match(/\bdoi\s*:\s*(10\.\d{4,9}\/\S+)/i)
  return nil unless match

  match[1].sub(/[.,;:]+\z/, "")
end

def detail_front_matter
  front_matter_and_body(DETAIL_PATH, "scFLUENT-seq detail record").first
end

def front_matter_and_body(path, label)
  source = File.read(path, encoding: "UTF-8")
  match = source.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  fail_unless(match, "#{label} has no YAML front matter")
  front_matter = YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
  body = source.delete_prefix(match[0])
  [front_matter, body]
rescue Errno::ENOENT, Psych::Exception => e
  raise VerificationError, "cannot load #{path.delete_prefix(ROOT + "/")}: #{e.message}"
end

def enrichment_documents
  paths = Dir.glob(File.join(PUBLICATIONS_COLLECTION_PATH, "**", "*.{md,markdown,html}"))
             .select { |path| File.file?(path) }
             .sort
  paths.map do |path|
    front_matter, body = front_matter_and_body(
      path, "publication enrichment #{path.delete_prefix(ROOT + "/")}"
    )
    {
      path: path,
      relative_path: path.delete_prefix(ROOT + "/"),
      slug: File.basename(path, File.extname(path)),
      front_matter: front_matter,
      body: body
    }
  end
end

def baseline_document(citations)
  {
    "schema_version" => 2,
    "source_file" => "_includes/full-publications.html",
    "record_count" => citations.length,
    "entity_decoding" => "CGI.unescapeHTML; no whitespace normalization",
    "checksum" => {
      "algorithm" => "SHA-256",
      "sequence_serialization" => "UTF-8 citations joined by LF with no trailing LF",
      "full_sequence_sha256" => sequence_sha256(citations)
    },
    "current_public_urls" => EXPECTED_URLS,
    "records" => citations.each_with_index.map do |citation, index|
      {
        "current_index" => index + 1,
        "citation" => citation,
        "sha256" => Digest::SHA256.hexdigest(citation)
      }
    end
  }
end

def shadow_document(citations)
  {
    "schema_version" => 2,
    "source" => {
      "name" => "X.Shen CV FULL PUBLICATIONS",
      "record_count" => citations.length,
      "policy" => "preserve-verbatim-citation"
    },
    "records" => citations.each_with_index.map do |citation, index|
      order = index + 1
      doi = explicit_doi(citation)
      scfluent = order == 1

      {
        "id" => scfluent ? "pub-2025-scfluent-seq" : format("pub-cv-%03d", order),
        "cv_order" => order,
        "citation" => citation,
        "title" => scfluent ? SCFLUENT_STRUCTURED_FIELDS.fetch("title") : nil,
        "authors" => scfluent ? SCFLUENT_STRUCTURED_FIELDS.fetch("authors") : {
          "display" => nil,
          "parsed" => []
        },
        "venue" => scfluent ? SCFLUENT_STRUCTURED_FIELDS.fetch("venue") : {
          "name" => nil,
          "volume" => nil,
          "issue" => nil,
          "pages" => nil,
          "article_number" => nil
        },
        "year" => scfluent ? SCFLUENT_STRUCTURED_FIELDS.fetch("year") : nil,
        "date" => scfluent ? SCFLUENT_STRUCTURED_FIELDS.fetch("date") : nil,
        "date_precision" => scfluent ? SCFLUENT_STRUCTURED_FIELDS.fetch("date_precision") : nil,
        "publication_type" => scfluent ? SCFLUENT_STRUCTURED_FIELDS.fetch("publication_type") : "unknown",
        "identifiers" => {
          "doi" => doi,
          "pmid" => nil,
          "isbn" => nil
        },
        "research_programs" => [],
        "keywords" => [],
        "links" => {
          "article" => doi && "https://doi.org/#{doi}",
          "pdf" => nil,
          "data" => scfluent ? SCFLUENT_DATA_LINKS : [],
          "code" => [],
          "supplementary" => []
        },
        "presentation" => {
          "featured" => scfluent,
          "selected" => scfluent,
          "detail_slug" => scfluent ? "2025-scfluent-seq" : nil
        },
        "provenance" => {
          "source_record" => order,
          "citation_verbatim" => true,
          "structured_fields_status" => doi ? "partially-verified" : "unparsed",
          "notes" => []
        }
      }
    end
  }
end

def verify_detail_record!
  detail = detail_front_matter
  fail_unless(detail.is_a?(Hash), "scFLUENT-seq detail front matter must be a map")
  duplicates = detail.keys & DETAIL_FORBIDDEN_CANONICAL_KEYS
  fail_unless(duplicates.empty?,
              "scFLUENT-seq detail record duplicates canonical keys: #{duplicates.sort.join(', ')}")
  fail_unless(detail.keys.sort == DETAIL_ALLOWED_KEYS.sort,
              "scFLUENT-seq detail record must contain only thin enrichment keys")
  fail_unless(detail["layout"] == "publication",
              "scFLUENT-seq detail record must use the shared publication layout")
  fail_unless(detail["publication_id"] == SCFLUENT_ID,
              "scFLUENT-seq detail record publication_id is incorrect")

  graphical = detail["graphical_abstract"]
  fail_unless(graphical.is_a?(Hash) && graphical.keys.sort == %w[alt credit path],
              "scFLUENT-seq graphical_abstract does not match the RFC enrichment schema")
  fail_unless(graphical["path"].is_a?(String) && graphical["path"].start_with?("/images/"),
              "scFLUENT-seq graphical abstract path is invalid")
  fail_unless(File.file?(File.join(ROOT, graphical["path"].delete_prefix("/"))),
              "scFLUENT-seq graphical abstract file is missing")
  fail_unless(graphical["alt"].is_a?(Hash) &&
              graphical["alt"].keys.all? { |language| %w[en zh-CN].include?(language) } &&
              graphical.dig("alt", "en").is_a?(String) && !graphical.dig("alt", "en").strip.empty?,
              "scFLUENT-seq graphical abstract requires approved English alt text")

  localized = detail["localized"]
  fail_unless(localized.is_a?(Hash) && localized.keys.sort == %w[en zh-CN].sort,
              "scFLUENT-seq localized enrichment must contain only en and zh-CN")
  localized.each do |language, fields|
    fail_unless(fields.is_a?(Hash) && fields.keys.sort == %w[metric sections short_title summary tags],
                "scFLUENT-seq #{language} enrichment keys do not match the RFC")
    fail_unless(fields["sections"].is_a?(Array),
                "scFLUENT-seq #{language} sections must be an array")
    tags = fields["tags"]
    fail_unless(tags.is_a?(Array) && tags.all? { |tag| tag.is_a?(String) && !tag.strip.empty? },
                "scFLUENT-seq #{language} tags must be approved non-empty strings")
  end

  source = File.read(DETAIL_PATH, encoding: "UTF-8")
  body = source.match(/\A---\s*\n.*?\n---\s*\n?(.*)\z/m)&.captures&.first
  fail_unless(body && body.strip.empty?,
              "scFLUENT-seq detail record must not duplicate rendering content in its body")
end

def verify_detail_integrity!(records)
  documents = enrichment_documents
  fail_unless(!documents.empty?, "publication collection contains no enrichment documents")

  documents.each do |document|
    detail = document[:front_matter]
    fail_unless(detail.is_a?(Hash),
                "#{document[:relative_path]} front matter must be a map")
    publication_id = detail["publication_id"]
    fail_unless(publication_id.is_a?(String) && !publication_id.strip.empty?,
                "#{document[:relative_path]} must define a non-empty publication_id")
  end

  enrichment_ids = documents.map { |document| document[:front_matter]["publication_id"] }
  duplicate_ids = enrichment_ids.tally.select { |_id, count| count > 1 }.keys
  fail_unless(duplicate_ids.empty?,
              "duplicate publication_id values in enrichment documents: #{duplicate_ids.join(', ')}")

  documents.each do |document|
    publication_id = document[:front_matter]["publication_id"]
    canonical_matches = records.select { |record| record["id"] == publication_id }
    fail_unless(canonical_matches.length == 1,
                "#{document[:relative_path]} publication_id #{publication_id.inspect} matches " \
                "#{canonical_matches.length} canonical records, expected exactly 1")
    canonical = canonical_matches.first
    fail_unless(canonical["title"].is_a?(String) && !canonical["title"].strip.empty?,
                "canonical record #{publication_id} requires a non-empty title for detail rendering")
    slug = canonical.dig("presentation", "detail_slug")
    fail_unless(slug.is_a?(String) && !slug.strip.empty?,
                "canonical record #{publication_id} requires a non-empty presentation.detail_slug")
    expected_english_url = "/publications/#{slug}/"
    generated_english_url = "/publications/#{document[:slug]}/"
    fail_unless(generated_english_url == expected_english_url,
                "canonical record #{publication_id} detail_slug does not match generated English route " \
                "#{generated_english_url}")
  end

  featured_records = records.select { |record| record.dig("presentation", "featured") == true }
  featured_records.each do |record|
    slug = record.dig("presentation", "detail_slug")
    fail_unless(slug.is_a?(String) && !slug.strip.empty?,
                "featured canonical record #{record['id']} requires presentation.detail_slug")
    matches = documents.select { |document| document[:front_matter]["publication_id"] == record["id"] }
    fail_unless(matches.length == 1,
                "featured canonical record #{record['id']} has #{matches.length} enrichment documents, " \
                "expected exactly 1")
  end

  verify_detail_record!

  route, route_body = front_matter_and_body(CHINESE_DETAIL_PATH, "Chinese scFLUENT-seq detail route")
  fail_unless(route.is_a?(Hash) && route.keys.sort == %w[layout publication_id],
              "Chinese scFLUENT-seq detail route must contain only layout and publication_id")
  fail_unless(route["layout"] == "publication",
              "Chinese scFLUENT-seq detail route must use the publication layout")
  fail_unless(route["publication_id"].is_a?(String) && !route["publication_id"].strip.empty?,
              "Chinese scFLUENT-seq detail route must define a non-empty publication_id")
  canonical_matches = records.select { |record| record["id"] == route["publication_id"] }
  enrichment_matches = documents.select do |document|
    document[:front_matter]["publication_id"] == route["publication_id"]
  end
  fail_unless(canonical_matches.length == 1,
              "Chinese detail publication_id #{route['publication_id'].inspect} matches " \
              "#{canonical_matches.length} canonical records, expected exactly 1")
  fail_unless(enrichment_matches.length == 1,
              "Chinese detail publication_id #{route['publication_id'].inspect} matches " \
              "#{enrichment_matches.length} enrichment documents, expected exactly 1")
  fail_unless(route_body.strip.empty?, "Chinese scFLUENT-seq detail route must have no body content")
  fail_unless(route["publication_id"] == SCFLUENT_ID,
              "Chinese scFLUENT-seq detail route publication_id changed")

  language_pairs = load_yaml(LANGUAGE_PAIRS_PATH)
  detail_pairs = language_pairs.select do |pair|
    pair["en_page"] == SCFLUENT_ENGLISH_URL || pair["zh_page"] == SCFLUENT_CHINESE_URL
  end
  expected_pair = {
    "en_page" => SCFLUENT_ENGLISH_URL,
    "zh_page" => SCFLUENT_CHINESE_URL,
    "en_href" => SCFLUENT_ENGLISH_URL,
    "zh_href" => SCFLUENT_CHINESE_URL
  }
  fail_unless(detail_pairs == [expected_pair],
              "scFLUENT-seq detail routes require one exact reciprocal language pair")

  {
    enrichment_count: documents.length,
    featured_count: featured_records.length,
    route_count: 2
  }
end

def generate!
  fail_unless(ENV["ALLOW_PUBLICATION_BASELINE_REGEN"] == "1",
              "baseline regeneration refused; set ALLOW_PUBLICATION_BASELINE_REGEN=1 explicitly")
  citations = legacy_citations
  verify_approved_sequence!("legacy bibliography", citations)
  File.write(BASELINE_PATH, JSON.pretty_generate(baseline_document(citations)) + "\n")
  File.write(DATA_PATH, YAML.dump(shadow_document(citations)), encoding: "UTF-8")
  puts "Generated publications v2 baseline and 52-record shadow dataset."
end

def load_json(path)
  JSON.parse(File.read(path, encoding: "UTF-8"))
rescue Errno::ENOENT, JSON::ParserError => e
  raise VerificationError, "cannot load #{path.delete_prefix(ROOT + "/")}: #{e.message}"
end

def load_yaml(path)
  YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [Date], aliases: false)
rescue Errno::ENOENT, Psych::Exception => e
  raise VerificationError, "cannot load #{path.delete_prefix(ROOT + "/")}: #{e.message}"
end

def verify_baseline!(baseline, citations)
  fail_unless(baseline.keys.sort == %w[
                checksum current_public_urls entity_decoding record_count records schema_version source_file
              ].sort, "baseline envelope keys do not match the Stage A contract")
  fail_unless(baseline["schema_version"] == 2, "baseline schema_version must be 2")
  fail_unless(baseline["source_file"] == "_includes/full-publications.html",
              "baseline source_file is incorrect")
  fail_unless(baseline["record_count"] == 52, "baseline record_count must be 52")
  fail_unless(baseline["current_public_urls"] == EXPECTED_URLS,
              "baseline public URL assertions changed")
  fail_unless(baseline.dig("checksum", "algorithm") == "SHA-256",
              "baseline checksum algorithm must be SHA-256")
  fail_unless(baseline.dig("checksum", "full_sequence_sha256") == APPROVED_SEQUENCE_SHA256,
              "baseline approved full-sequence checksum changed")
  fail_unless(baseline.dig("checksum", "full_sequence_sha256") == sequence_sha256(citations),
              "baseline full-sequence checksum mismatch")

  records = baseline["records"]
  fail_unless(records.is_a?(Array) && records.length == 52,
              "baseline must contain exactly 52 records")
  verify_approved_sequence!("JSON baseline", records.map { |record| record["citation"] })
  records.each_with_index do |record, index|
    order = index + 1
    citation = citations[index]
    fail_unless(record["current_index"] == order,
                "baseline record #{order} has incorrect current_index")
    fail_unless(record["citation"] == citation,
                "baseline record #{order} citation differs from legacy source")
    fail_unless(record["sha256"] == Digest::SHA256.hexdigest(citation),
                "baseline record #{order} checksum mismatch")
  end
end

def verify_shadow!(shadow, citations)
  fail_unless(shadow.keys.sort == %w[records schema_version source],
              "shadow envelope keys do not match the RFC")
  fail_unless(shadow["schema_version"] == 2, "shadow schema_version must be 2")
  source = shadow["source"]
  fail_unless(source == {
                "name" => "X.Shen CV FULL PUBLICATIONS",
                "record_count" => 52,
                "policy" => "preserve-verbatim-citation"
              }, "shadow source metadata is incorrect")

  records = shadow["records"]
  fail_unless(records.is_a?(Array) && records.length == 52,
              "shadow dataset must contain exactly 52 records")
  verify_approved_sequence!("canonical shadow dataset",
                            records.map { |record| record["citation"] })

  detail_counts = verify_detail_integrity!(records)
  ids = []
  dois = []

  records.each_with_index do |record, index|
    order = index + 1
    legacy = citations[index]
    doi = explicit_doi(legacy)
    scfluent = order == 1

    fail_unless(record.keys.sort == RECORD_KEYS.sort,
                "record #{order} keys do not match the RFC shadow schema")
    fail_unless(record["cv_order"] == order, "record #{order} cv_order mismatch")
    fail_unless(record["citation"] == legacy,
                "record #{order} citation differs from decoded legacy citation")
    fail_unless(record["id"].is_a?(String) && record["id"].match?(/\Apub-[a-z0-9][a-z0-9-]*\z/),
                "record #{order} has invalid id")
    ids << record["id"]

    expected_id = scfluent ? SCFLUENT_ID : format("pub-cv-%03d", order)
    fail_unless(record["id"] == expected_id, "record #{order} canonical ID changed")

    if scfluent
      SCFLUENT_STRUCTURED_FIELDS.each do |key, expected|
        fail_unless(record[key] == expected,
                    "scFLUENT-seq approved #{key} enrichment changed")
      end
    else
      fail_unless(record["title"].nil?, "record #{order} title must remain unparsed")
      fail_unless(record["authors"] == { "display" => nil, "parsed" => [] },
                  "record #{order} authors must remain unparsed")
      fail_unless(record["venue"] == {
                    "name" => nil, "volume" => nil, "issue" => nil,
                    "pages" => nil, "article_number" => nil
                  }, "record #{order} venue fields must remain unparsed")
      fail_unless(record["year"].nil? && record["date"].nil? && record["date_precision"].nil?,
                  "record #{order} date fields must remain unparsed")
    end

    type = record["publication_type"]
    fail_unless(ALLOWED_PUBLICATION_TYPES.include?(type),
                "record #{order} has invalid publication_type")
    expected_type = scfluent ? "research-article" : "unknown"
    fail_unless(type == expected_type,
                "record #{order} publication_type is outside the approved Stage F scope")
    programs = record["research_programs"]
    fail_unless(programs.is_a?(Array) && (programs - ALLOWED_RESEARCH_PROGRAMS).empty?,
                "record #{order} has invalid research_programs")
    fail_unless(programs.empty?, "record #{order} research programs must be deferred")
    fail_unless(record["keywords"] == [], "record #{order} keywords must be empty")

    identifiers = record["identifiers"]
    fail_unless(identifiers == { "doi" => doi, "pmid" => nil, "isbn" => nil },
                "record #{order} identifiers do not match explicit source metadata")
    dois << doi.downcase if doi

    links = record["links"]
    fail_unless(links.keys.sort == %w[article code data pdf supplementary],
                "record #{order} link keys are invalid")
    fail_unless(links["article"] == (doi && "https://doi.org/#{doi}"),
                "record #{order} article URL is not derived from its explicit DOI")
    fail_unless(links["pdf"].nil?, "record #{order} must not expose a PDF action")
    fail_unless(links["code"] == [] && links["supplementary"] == [],
                "record #{order} has unapproved Code or Supplementary links")
    fail_unless(links["data"] == (scfluent ? SCFLUENT_DATA_LINKS : []),
                "record #{order} has unapproved or missing Data links")

    expected_presentation = {
      "featured" => scfluent,
      "selected" => scfluent,
      "detail_slug" => scfluent ? "2025-scfluent-seq" : nil
    }
    fail_unless(record["presentation"] == expected_presentation,
                "record #{order} presentation metadata is not approved")

    provenance = record["provenance"]
    expected_status = doi ? "partially-verified" : "unparsed"
    fail_unless(ALLOWED_PROVENANCE_STATUSES.include?(provenance["structured_fields_status"]),
                "record #{order} has invalid provenance status")
    fail_unless(provenance == {
                  "source_record" => order,
                  "citation_verbatim" => true,
                  "structured_fields_status" => expected_status,
                  "notes" => []
                }, "record #{order} provenance does not match Stage B policy")
  end

  fail_unless(ids.uniq.length == 52, "publication IDs are not unique")
  fail_unless(dois.uniq.length == dois.length, "explicit DOI values are not unique")
  fail_unless(records.first["id"] == SCFLUENT_ID,
              "scFLUENT-seq record ID changed")
  fail_unless(File.file?(DETAIL_PATH), "scFLUENT-seq detail record is missing")

  {
    doi_present: dois.length,
    doi_missing: 52 - dois.length,
    unparsed: records.count { |record| record.dig("provenance", "structured_fields_status") == "unparsed" },
    partially_verified: records.count do |record|
      record.dig("provenance", "structured_fields_status") == "partially-verified"
    end,
    enrichment_count: detail_counts[:enrichment_count],
    featured_count: detail_counts[:featured_count],
    detail_route_count: detail_counts[:route_count]
  }
end

def verify!
  citations = legacy_citations
  verify_approved_sequence!("legacy bibliography", citations)
  baseline = load_json(BASELINE_PATH)
  shadow = load_yaml(DATA_PATH)
  verify_baseline!(baseline, citations)
  counts = verify_shadow!(shadow, citations)

  puts "PASS publications shadow: 52 records; exact order/citation/hash parity; " \
       "DOI #{counts[:doi_present]} present/#{counts[:doi_missing]} missing; " \
       "status #{counts[:partially_verified]} partially-verified/#{counts[:unparsed]} unparsed; " \
       "approved scFLUENT-seq enrichment 1/other records structurally unparsed 51; " \
       "featured #{counts[:featured_count]}/enrichment #{counts[:enrichment_count]}/" \
       "detail routes #{counts[:detail_route_count]}; canonical/enrichment duplicates 0; " \
       "PDF actions 0; unpublished-title exposure 0."
end

begin
  if ARGV == ["--generate"]
    generate!
  elsif ARGV.empty?
    verify!
  else
    warn "Usage: ruby _tools/verify_publications_shadow.rb [--generate]"
    exit 2
  end
rescue VerificationError, KeyError => e
  warn "FAIL publications shadow: #{e.message}"
  exit 1
end
