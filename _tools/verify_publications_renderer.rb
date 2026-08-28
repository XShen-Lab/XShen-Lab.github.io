#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "digest"
require "json"
require "open3"
require "tempfile"
require "tmpdir"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "_config.yaml")
LEGACY_PATH = File.join(ROOT, "_includes", "full-publications.html")
LIST_PATH = File.join(ROOT, "_includes", "publications", "list.html")
DATA_PATH = File.join(ROOT, "_data", "publications.yml")
BROWSER_DATA_PATH = File.join(ROOT, "_data", "publication_browser.yml")
BROWSER_INCLUDE_PATH = File.join(ROOT, "_includes", "publications", "browser.html")
REPRESENTATIVES_INCLUDE_PATH = File.join(ROOT, "_includes", "publications", "representatives.html")
LAYOUT_PATH = File.join(ROOT, "_layouts", "publication.html")
META_PATH = File.join(ROOT, "_includes", "meta.html")
ENRICHMENT_PATH = File.join(ROOT, "_publications", "2025-scfluent-seq.md")
PAGE_PATHS = {
  "English" => File.join("publications", "index.html"),
  "Chinese" => File.join("zh", "publications", "index.html")
}.freeze
DETAIL_PATHS = {
  "English Detail" => File.join("publications", "2025-scfluent-seq", "index.html"),
  "Chinese Detail" => File.join("zh", "publications", "2025-scfluent-seq", "index.html")
}.freeze
AUXILIARY_PAGE_PATHS = {
  "Research" => File.join("research", "index.html")
}.freeze
PAGE_SOURCE_PATHS = [
  File.join(ROOT, "publications", "index.md"),
  File.join(ROOT, "zh", "publications", "index.md")
].freeze
EXPECTED_SWITCH = "{% if site.publications_v2.enabled %}{% include publications/list.html %}" \
                  "{% else %}{% include full-publications.html %}{% endif %}"
APPROVED_SEQUENCE_SHA256 = "2526131b41eae70abd0d7e1d4509543c590e9b9246771471e193cbe6b7bcde52".freeze
APPROVED_PRE_REFACTOR_DETAIL_SHA256 =
  "fb5111662587f5715d0872014940ad509d15b75c6913a02212d0f05a27a4989d".freeze
EXPECTED_COUNT = 52
EXPECTED_REPRESENTATIVE_IDS = %w[
  pub-cv-013
  pub-cv-016
  pub-cv-015
  pub-cv-005
  pub-cv-010
  pub-cv-025
  pub-cv-024
  pub-cv-031
  pub-cv-032
  pub-2025-scfluent-seq
  pub-cv-040
  pub-cv-051
  pub-cv-043
].freeze
EXPECTED_REPRESENTATIVE_MODULE_IDS = %w[
  genome-organization
  rna-networks
  transcriptional-surveillance
  cell-fate-dynamics
  foundations
].freeze
EXPECTED_FIGURE_REPRESENTATIVE_IDS = (EXPECTED_REPRESENTATIVE_IDS - %w[
  pub-cv-015
  pub-2025-scfluent-seq
]).freeze
SCFLUENT_ID = "pub-2025-scfluent-seq".freeze
ENGLISH_DETAIL_URL = "/publications/2025-scfluent-seq/".freeze
CHINESE_DETAIL_URL = "/zh/publications/2025-scfluent-seq/".freeze
SITE_URL = "https://xshen-lab.github.io".freeze
ENGLISH_DETAIL_ABSOLUTE_URL = "#{SITE_URL}#{ENGLISH_DETAIL_URL}".freeze
CHINESE_DETAIL_ABSOLUTE_URL = "#{SITE_URL}#{CHINESE_DETAIL_URL}".freeze
RESEARCH_ABSOLUTE_URL = "#{SITE_URL}/research/".freeze
GRAPHICAL_ABSTRACT_ABSOLUTE_URL =
  "#{SITE_URL}/images/publications/2025-scfluent-seq/graphical-abstract.webp".freeze
CHINESE_METRIC = "每个细胞转录约 0.02%–3.1% 的基因组".freeze

class RendererVerificationError < StandardError; end

def fail_unless(condition, message)
  raise RendererVerificationError, message unless condition
end

def load_yaml(path)
  YAML.safe_load(File.read(path, encoding: "UTF-8"), permitted_classes: [Date], aliases: false)
rescue Errno::ENOENT, Psych::Exception => e
  raise RendererVerificationError, "cannot load #{path.delete_prefix(ROOT + "/")}: #{e.message}"
end

def sequence_sha256(citations)
  Digest::SHA256.hexdigest(citations.join("\n"))
end

def verify_approved_sequence!(label, citations)
  checksum = sequence_sha256(citations)
  fail_unless(checksum == APPROVED_SEQUENCE_SHA256,
              "#{label} checksum #{checksum} does not match approved checksum")
end

def legacy_citations
  html = File.read(LEGACY_PATH, encoding: "UTF-8")
  items = html.scan(/<li\b([^>]*)>(.*?)<\/li>/mi)
  fail_unless(items.length == EXPECTED_COUNT,
              "legacy count is #{items.length}, expected #{EXPECTED_COUNT}")

  items.each_with_index.map do |(attributes, content), index|
    fail_unless(attributes.strip.empty?, "legacy item #{index + 1} has unexpected attributes")
    fail_unless(content !~ /<[^>]+>/, "legacy item #{index + 1} contains nested markup")
    citation = CGI.unescapeHTML(content)
    fail_unless(!citation.strip.empty?, "legacy item #{index + 1} is empty")
    citation
  end
end

def canonical_records
  data = load_yaml(DATA_PATH)
  records = data["records"]
  fail_unless(records.is_a?(Array) && records.length == EXPECTED_COUNT,
              "canonical record count is #{records&.length || 0}, expected #{EXPECTED_COUNT}")

  sorted = records.sort_by { |record| record.fetch("cv_order") }
  orders = sorted.map { |record| record["cv_order"] }
  fail_unless(orders == (1..EXPECTED_COUNT).to_a,
              "canonical cv_order must be exactly 1 through #{EXPECTED_COUNT}")

  sorted.each_with_index do |record, index|
    citation = record["citation"]
    fail_unless(citation.is_a?(String) && !citation.strip.empty?,
                "canonical citation #{index + 1} is empty")
  end
  sorted
end

def canonical_citations(records)
  records.map { |record| record.fetch("citation") }
end

def enrichment_document
  source = File.read(ENRICHMENT_PATH, encoding: "UTF-8")
  match = source.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  fail_unless(match, "scFLUENT-seq enrichment document has no YAML front matter")
  YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
rescue Errno::ENOENT, Psych::Exception => e
  raise RendererVerificationError, "cannot load scFLUENT-seq enrichment: #{e.message}"
end

def verify_default_configuration!
  config = load_yaml(CONFIG_PATH)
  fail_unless(config.dig("publications_v2", "enabled") == true,
              "production publications_v2.enabled must be true")
  fail_unless(config["url"] == SITE_URL,
              "production site.url must be #{SITE_URL} for absolute page metadata")
end

def verify_renderer_wiring!
  list_source = File.read(LIST_PATH, encoding: "UTF-8")
  fail_unless(list_source.include?("site.data.publications.records"),
              "data-driven list no longer reads site.data.publications.records")
  fail_unless(list_source.include?('sort: "cv_order"'),
              "data-driven list no longer sorts by cv_order")
  fail_unless(list_source.include?("publications/citation.html"),
              "data-driven list no longer uses the canonical citation include")
  fail_unless(!list_source.include?("full-publications.html"),
              "data-driven list unexpectedly delegates to the legacy include")

  browser_source = File.read(BROWSER_INCLUDE_PATH, encoding: "UTF-8")
  fail_unless(browser_source.include?(EXPECTED_SWITCH),
              "publication browser does not preserve the verified feature-flag switch")
  fail_unless(browser_source.include?('site.data.publications.records | sort: "cv_order"'),
              "publication browser does not sort canonical records by cv_order")
  fail_unless(browser_source.include?("site.data.publication_browser"),
              "publication browser no longer reads the year/category display mapping")

  representatives_source = File.read(REPRESENTATIVES_INCLUDE_PATH, encoding: "UTF-8")
  fail_unless(representatives_source.include?('site.data.publications.records | sort: "cv_order"'),
              "representative collection does not sort canonical records by cv_order")
  fail_unless(representatives_source.include?('where: "id", representative.publication_id'),
              "representative collection does not resolve canonical records by publication_id")
  fail_unless(representatives_source.include?('site.publications | where: "publication_id", publication.id'),
              "representative collection does not resolve scFLUENT enrichment by publication_id")
  fail_unless(representatives_source.include?('for category in browser_data.categories') &&
              representatives_source.include?('where: "category", category.id'),
              "representative collection no longer renders the five scientific modules")

  PAGE_SOURCE_PATHS.each do |path|
    source = File.read(path, encoding: "UTF-8")
    fail_unless(source.include?("publications/representatives.html"),
                "#{path.delete_prefix(ROOT + "/")} does not render the representative collection")
    fail_unless(source.include?("publications/browser.html"),
                "#{path.delete_prefix(ROOT + "/")} does not render the year/category browser")
    fail_unless(!source.include?('site.publications | sort: "date"') &&
                !source.include?("paper.url"),
                "#{path.delete_prefix(ROOT + "/")} still depends on collection date/order or filename URL")
  end


  layout_source = File.read(LAYOUT_PATH, encoding: "UTF-8")
  fail_unless(layout_source.include?('site.data.publications.records | where: "id", page.publication_id'),
              "publication layout does not resolve canonical data by page.publication_id")
  fail_unless(layout_source.include?('site.publications | where: "publication_id", page.publication_id'),
              "publication layout does not resolve the unique enrichment by page.publication_id")
  fail_unless(layout_source.include?("enrichment=enrichment"),
              "publication layout does not pass resolved enrichment to the detail renderer")

  meta_source = File.read(META_PATH, encoding: "UTF-8")
  fail_unless(meta_source.include?("page.url | absolute_url"),
              "meta include does not derive URLs from the current page")
  fail_unless(meta_source.include?('<link rel="canonical" href="{{ url }}">'),
              "meta include does not emit the page-specific canonical URL")
  fail_unless(meta_source.include?('site.publications | where: "publication_id", page.publication_id'),
              "meta include does not resolve publication enrichment by publication_id")
  fail_unless(meta_source.include?("publication_localized.summary"),
              "meta include does not use the localized publication summary")
  fail_unless(meta_source.include?("publication_enrichment.graphical_abstract.path | absolute_url"),
              "meta include does not use an absolute graphical-abstract social image")
end

def verify_browser_data!(records)
  data = load_yaml(BROWSER_DATA_PATH)
  canonical_ids = records.map { |record| record.fetch("id") }
  mapping = data.fetch("records")
  category_ids = data.fetch("categories").map { |category| category.fetch("id") }
  years = data.fetch("years")
  representatives = data.fetch("representatives")
  representative_order = data.fetch("representative_order")

  fail_unless(mapping.keys.sort == canonical_ids.sort,
              "publication browser mapping must cover each canonical record exactly once")
  fail_unless(mapping.values.all? { |entry| years.include?(entry["year"]) },
              "publication browser contains a year outside the horizontal year rail")
  fail_unless(mapping.values.all? { |entry| category_ids.include?(entry["category"]) },
              "publication browser contains an unknown research category")
  records.each do |record|
    journal = mapping.fetch(record.fetch("id"))["journal"]
    fail_unless(journal.is_a?(String) && !journal.empty?,
                "publication #{record.fetch('id')} has no journal display metadata")
    fail_unless(record.fetch("citation").scan(journal).length == 1,
                "publication #{record.fetch('id')} journal must occur exactly once in its canonical citation")
  end

  representative_ids = representatives.map { |entry| entry.fetch("publication_id") }
  fail_unless(representative_order == EXPECTED_REPRESENTATIVE_IDS,
              "representative display order differs from the approved within-module journal priority")
  fail_unless(representative_ids.sort == EXPECTED_REPRESENTATIVE_IDS.sort,
              "representative collection IDs differ from the approved 13-paper selection")
  fail_unless(representative_ids.uniq.length == EXPECTED_REPRESENTATIVE_IDS.length,
              "representative collection contains duplicate records")
  representatives.each do |entry|
    fail_unless(canonical_ids.include?(entry.fetch("publication_id")),
                "representative collection references a non-canonical publication")
    fail_unless(category_ids.include?(entry.fetch("category")),
                "representative collection contains an unknown category")
    fail_unless(entry.fetch("title").is_a?(String) && !entry.fetch("title").empty? &&
                entry.fetch("venue").is_a?(String) && !entry.fetch("venue").empty? &&
                entry.fetch("year").is_a?(Integer),
                "representative collection contains incomplete display metadata")

    canonical = records.find { |record| record.fetch("id") == entry.fetch("publication_id") }
    fail_unless(canonical.fetch("citation").scan(entry.fetch("title")).length == 1,
                "representative #{entry.fetch('publication_id')} title must occur exactly once in its canonical citation")

    next unless EXPECTED_FIGURE_REPRESENTATIVE_IDS.include?(entry.fetch("publication_id"))

    figure = entry["figure"]
    fail_unless(figure.is_a?(Hash),
                "representative #{entry.fetch('publication_id')} has no source figure")
    figure_path = figure.fetch("path")
    fail_unless(figure_path.start_with?("/images/publications/representative/") &&
                File.file?(File.join(ROOT, figure_path.delete_prefix("/"))),
                "representative #{entry.fetch('publication_id')} figure file is missing")
    %w[en zh-CN].each do |language|
      fail_unless(figure.dig("alt", language).is_a?(String) && !figure.dig("alt", language).empty? &&
                  figure.dig("source", language).is_a?(String) && !figure.dig("source", language).empty?,
                  "representative #{entry.fetch('publication_id')} figure lacks #{language} alt/source text")
      fail_unless(entry.dig("summary", language).is_a?(String) && !entry.dig("summary", language).empty?,
                  "representative #{entry.fetch('publication_id')} lacks a #{language} card summary")
      fail_unless(entry.dig("tags", language).is_a?(Array) && entry.dig("tags", language).length >= 4,
                  "representative #{entry.fetch('publication_id')} lacks four #{language} keywords")
    end
  end
end

def read_built_pages(destination, mode)
  pages = PAGE_PATHS.to_h do |language, relative_path|
    path = File.join(destination, relative_path)
    fail_unless(File.file?(path),
                "#{mode} #{language} page is missing at /#{relative_path.delete_suffix("index.html")}")
    [language, File.read(path, encoding: "UTF-8")]
  end

  DETAIL_PATHS.each do |label, relative_path|
    detail = File.join(destination, relative_path)
    fail_unless(File.file?(detail),
                "#{mode} #{label} URL /#{relative_path.delete_suffix('index.html')} is missing")
    pages[label] = File.read(detail, encoding: "UTF-8")
  end
  AUXILIARY_PAGE_PATHS.each do |label, relative_path|
    path = File.join(destination, relative_path)
    fail_unless(File.file?(path), "#{mode} auxiliary page /#{relative_path.delete_suffix('index.html')} is missing")
    pages[label] = File.read(path, encoding: "UTF-8")
  end
  pages
end

def run_build(destination, mode, config_argument)
  command = [
    "bundle", "exec", "jekyll", "build",
    "--config", config_argument,
    "--destination", destination
  ]
  stdout, stderr, status = Open3.capture3(
    { "JEKYLL_ENV" => "production" },
    *command,
    chdir: ROOT
  )
  fail_unless(status.success?, "#{mode} Jekyll build failed:\n#{stdout}#{stderr}")
  read_built_pages(destination, mode)
end

def build_production_pages
  Dir.mktmpdir("publications-v2-production-") do |destination|
    return run_build(destination, "production mode", CONFIG_PATH)
  end
end

def build_rollback_pages
  Dir.mktmpdir("publications-v2-rollback-") do |destination|
    Tempfile.create(["publications-v2-disabled", ".yml"]) do |override|
      override.write(YAML.dump("publications_v2" => { "enabled" => false }))
      override.flush
      return run_build(destination, "rollback mode", "#{CONFIG_PATH},#{override.path}")
    end
  end
end

def extract_publication_list(html, label, records)
  browser_records = load_yaml(BROWSER_DATA_PATH).fetch("records")
  matches = html.to_enum(:scan, /<ol\b([^>]*)>(.*?)<\/ol>/mi).map do
    [Regexp.last_match(0), Regexp.last_match(1), Regexp.last_match(2)]
  end
  lists = matches.select do |_full_html, attributes, _content|
    attributes.match?(/\bclass\s*=\s*["'][^"']*\bfull-publications\b[^"']*["']/i)
  end
  fail_unless(lists.length == 1,
              "#{label} contains #{lists.length} full-publications lists, expected 1")

  full_html, attributes, list_content = lists.first
  fail_unless(attributes.strip == 'class="full-publications"',
              "#{label} full-publications list has unexpected attributes or metadata")
  fail_unless(list_content !~ /<(?:button|img)\b/i,
              "#{label} list contains a button or image")

  items = list_content.scan(/<li\b([^>]*)>(.*?)<\/li>/mi)
  fail_unless(items.length == EXPECTED_COUNT,
              "#{label} count is #{items.length}, expected #{EXPECTED_COUNT}")

  production_mode = label.include?("production mode")
  citations = items.each_with_index.map do |(item_attributes, content), index|
    fail_unless(item_attributes.strip.empty?,
                "#{label} item #{index + 1} has attributes or metadata")

    link_panels = content.scan(/<details\b[^>]*\bclass="publication-links"[^>]*>.*?<\/details>/mi)
    expected_panel_count = production_mode ? 1 : 0
    fail_unless(link_panels.length == expected_panel_count,
                "#{label} item #{index + 1} has #{link_panels.length} link panels, expected #{expected_panel_count}")

    if production_mode
      panel = link_panels.first
      fail_unless(visible_text(panel).start_with?("links "),
                  "#{label} item #{index + 1} does not expose the [links] label")
      hrefs = panel.scan(/<a\b[^>]*\bhref="([^"]*)"/i).flatten.map { |href| CGI.unescapeHTML(href) }
      publication = records.fetch(index)
      expected_hrefs = []
      expected_hrefs << publication.dig("links", "article") if publication.dig("links", "article")
      expected_hrefs.concat(Array(publication.dig("links", "data")).map { |dataset| dataset.fetch("url") })
      fail_unless(hrefs[0, expected_hrefs.length] == expected_hrefs,
                  "#{label} item #{index + 1} verified article/data links differ from canonical data")
      scholar_uri = URI.parse(hrefs.last)
      scholar_query = CGI.parse(scholar_uri.query.to_s).fetch("q", []).first
      scholar_source = publication["title"].to_s.empty? ? publication.fetch("citation") : publication.fetch("title")
      fail_unless(scholar_uri.host == "scholar.google.com" && scholar_query == scholar_source,
                  "#{label} item #{index + 1} Google Scholar link does not use canonical publication text")
      fail_unless(panel.scan(/<a\b/i).length == expected_hrefs.length + 1,
                  "#{label} item #{index + 1} contains an unexpected publication link")
    end

    citation_html = content.sub(/ <details\b[^>]*\bclass="publication-links"[^>]*>.*?<\/details>\s*\z/mi, "")
    journal_markup = citation_html.scan(
      /<strong\b[^>]*\bclass="publication-journal"[^>]*>\s*<em>(.*?)<\/em>\s*<\/strong>/mi
    ).flatten
    expected_journal_count = production_mode ? 1 : 0
    fail_unless(journal_markup.length == expected_journal_count,
                "#{label} item #{index + 1} has #{journal_markup.length} formatted journals, expected #{expected_journal_count}")
    if production_mode
      expected_journal = browser_records.fetch(records.fetch(index).fetch("id")).fetch("journal")
      fail_unless(CGI.unescapeHTML(journal_markup.first) == expected_journal,
                  "#{label} item #{index + 1} formats the wrong journal")
    end
    unwrapped_citation_html = citation_html.gsub(
      /<strong\b[^>]*\bclass="publication-journal"[^>]*>\s*<em>(.*?)<\/em>\s*<\/strong>/mi,
      '\\1'
    )
    fail_unless(unwrapped_citation_html !~ /<[^>]+>/,
                "#{label} item #{index + 1} citation contains unexpected nested markup or metadata")
    citation = CGI.unescapeHTML(unwrapped_citation_html)
    fail_unless(!citation.strip.empty?, "#{label} item #{index + 1} is empty")
    citation
  end

  remainder = list_content.gsub(/<li\b[^>]*>.*?<\/li>/mi, "")
  fail_unless(remainder.strip.empty?,
              "#{label} list contains content outside its citation items")
  { citations: citations, html: full_html }
end

def visible_text(fragment)
  CGI.unescapeHTML(fragment.gsub(/<!--.*?-->/m, " ").gsub(/<[^>]+>/, " "))
     .gsub(/\s+/, " ").strip
end

def extract_featured_card(html, label)
  articles = html.to_enum(:scan, /<article\b([^>]*)>(.*?)<\/article>/mi).map do
    [Regexp.last_match(0), Regexp.last_match(1)]
  end
  cards = articles.select do |_full_html, attributes|
    attributes.match?(/\bclass\s*=\s*["'][^"']*\bpublication-entry\b[^"']*["']/i)
  end
  fail_unless(cards.length == 1, "#{label} featured-card count is #{cards.length}, expected 1")
  cards.first.first
end

def verify_featured_card!(html, label, language, publication, enrichment)
  card = extract_featured_card(html, label)
  fail_unless(publication["id"] == SCFLUENT_ID,
              "#{label} featured canonical record is #{publication['id'].inspect}, expected #{SCFLUENT_ID}")
  fail_unless(enrichment["publication_id"] == publication["id"],
              "#{label} featured card enrichment does not match the canonical publication_id")

  chinese = language == "Chinese"
  localized = enrichment.dig("localized", chinese ? "zh-CN" : "en")
  tags = localized["tags"]
  detail_url = chinese ? CHINESE_DETAIL_URL : ENGLISH_DETAIL_URL
  action_labels = chinese ? ["阅读简介", "查看论文"] : ["Read summary", "View article"]
  metric_suffix = chinese ? "（范围取决于细胞类型）" : " (cell-type dependent)"
  browser_data = load_yaml(BROWSER_DATA_PATH)
  category_id = browser_data.fetch("records").fetch(publication.fetch("id")).fetch("category")
  category = browser_data.fetch("categories").find { |entry| entry.fetch("id") == category_id }
  category_label = category.fetch("label").fetch(chinese ? "zh-CN" : "en")
  expected_text = [
    "#{publication.dig('venue', 'name')} · #{publication['year']} · #{category_label}",
    publication["title"],
    publication.dig("authors", "display"),
    localized["summary"],
    "#{localized['metric']}#{metric_suffix}",
    *tags,
    *action_labels
  ].join(" ")
  fail_unless(visible_text(card) == expected_text,
              "#{label} visible featured-card content differs from approved canonical/enrichment content")

  hrefs = card.scan(/<a\b[^>]*\bhref="([^"]*)"/i).flatten.map { |href| CGI.unescapeHTML(href) }
  expected_hrefs = [detail_url, detail_url, detail_url, publication.dig("links", "article")]
  fail_unless(hrefs == expected_hrefs,
              "#{label} featured-card links are #{hrefs.inspect}, expected #{expected_hrefs.inspect}")

  images = card.scan(/<img\b[^>]*>/i)
  fail_unless(images.length == 1, "#{label} featured card must contain exactly one image")
  image = images.first
  image_src = CGI.unescapeHTML(image[/\bsrc="([^"]*)"/i, 1].to_s)
  image_alt = CGI.unescapeHTML(image[/\balt="([^"]*)"/i, 1].to_s)
  expected_alt = enrichment.dig("graphical_abstract", "alt", chinese ? "zh-CN" : "en")
  fail_unless(image_src == enrichment.dig("graphical_abstract", "path") && image_alt == expected_alt,
              "#{label} featured-card graphical abstract source or alt text changed")
  fail_unless(card !~ /<a\b[^>]*>\s*PDF\s*<\/a>/i,
              "#{label} featured card exposes a PDF action")
end

def verify_representative_collection!(html, label, records)
  module_ids = html.scan(/<section\b[^>]*\bclass="representative-program"[^>]*\bid="representative-([^"]+)"/i).flatten
  fail_unless(module_ids == EXPECTED_REPRESENTATIVE_MODULE_IDS,
              "#{label} representative modules are #{module_ids.inspect}, expected #{EXPECTED_REPRESENTATIVE_MODULE_IDS.inspect}")

  representative_cards = html.to_enum(:scan, /<article\b([^>]*)\bdata-publication-id="([^"]+)"([^>]*)>(.*?)<\/article>/mi).map do
    [Regexp.last_match(2), Regexp.last_match(4)]
  end
  representative_ids = representative_cards.map(&:first)
  fail_unless(representative_ids == EXPECTED_REPRESENTATIVE_IDS,
              "#{label} representative card IDs/order differ from the approved 13-paper selection")

  representative_cards.each do |publication_id, card|
    fail_unless(records.any? { |record| record.fetch("id") == publication_id },
                "#{label} representative card #{publication_id} is not canonical")
    authors = card[/<p\b[^>]*\bclass="publication-entry-authors"[^>]*>(.*?)<\/p>/mi, 1]
    fail_unless(authors && !visible_text(authors).empty?,
                "#{label} representative card #{publication_id} has no visible authors")
    tags = card[/<div\b[^>]*\bclass="publication-entry-tags"[^>]*>(.*?)<\/div>/mi, 1]
    fail_unless(tags && tags.scan(/<span\b/i).length >= 4,
                "#{label} representative card #{publication_id} has fewer than four keywords")
    fail_unless(card.scan(/<img\b/i).length == 1,
                "#{label} representative card #{publication_id} must contain exactly one image")
    fail_unless(card.match?(/<div\b[^>]*\bclass="publication-entry-actions"/i),
                "#{label} representative card #{publication_id} has no action links")
  end

  json_source = html[/<script\b[^>]*\bdata-publication-records(?:="")?[^>]*>(.*?)<\/script>/mi, 1]
  fail_unless(json_source, "#{label} publication browser has no record mapping")
  browser_records = JSON.parse(json_source)
  fail_unless(browser_records.length == EXPECTED_COUNT,
              "#{label} publication browser maps #{browser_records.length} records, expected #{EXPECTED_COUNT}")
  fail_unless(browser_records.map { |record| record.fetch("id") } == records.map { |record| record.fetch("id") },
              "#{label} publication browser mapping does not preserve canonical CV order")
end

def verify_mode!(pages, mode, legacy, records, enrichment)
  lists = PAGE_PATHS.keys.to_h do |language|
    list = extract_publication_list(pages.fetch(language), "#{mode} #{language}", records)
    fail_unless(list[:citations] == legacy,
                "#{mode} #{language} order or visible citation text differs from legacy")
    verify_approved_sequence!("#{mode} #{language}", list[:citations])
    [language, list]
  end

  fail_unless(lists.fetch("English")[:citations] == lists.fetch("Chinese")[:citations],
              "#{mode} English and Chinese citation sequences differ")

  featured = records.select { |record| record.dig("presentation", "featured") == true }
  fail_unless(featured.length == 1,
              "#{mode} canonical featured-record count is #{featured.length}, expected 1")
  PAGE_PATHS.keys.each do |language|
    verify_featured_card!(
      pages.fetch(language), "#{mode} #{language}", language, featured.first, enrichment
    )
    verify_representative_collection!(pages.fetch(language), "#{mode} #{language}", records)
  end

  verify_english_detail_output!(pages.fetch("English Detail"), mode, featured.first, enrichment)
  verify_chinese_detail_output!(pages.fetch("Chinese Detail"), mode, featured.first, enrichment)
  verify_research_metadata!(pages.fetch("Research"), mode)
  pages.each do |label, html|
    fail_unless(!html.include?("scfluent-seq-cell-2025.pdf") &&
                html !~ /<a\b[^>]*>\s*PDF\s*<\/a>/i,
                "#{mode} #{label} exposes an unapproved PDF link")
  end
  lists
end

def detail_signature(html)
  main = html[/<main\b[^>]*>(.*?)<\/main>/mi, 1]
  fail_unless(main, "scFLUENT-seq detail page has no main element")

  clean = main.gsub(/<!--.*?-->/m, " ")
              .gsub(/<script\b.*?<\/script>/mi, " ")
              .gsub(/<style\b.*?<\/style>/mi, " ")
  visible_text = CGI.unescapeHTML(clean.gsub(/<[^>]+>/, " ")).gsub(/\s+/, " ").strip
  links = main.scan(/<a\b[^>]*\bhref="([^"]*)"/i).flatten.map { |href| CGI.unescapeHTML(href) }
  images = main.scan(/<img\b[^>]*>/i).map do |tag|
    {
      "src" => CGI.unescapeHTML(tag[/\bsrc="([^"]*)"/i, 1].to_s),
      "alt" => CGI.unescapeHTML(tag[/\balt="([^"]*)"/i, 1].to_s)
    }
  end
  payload = {
    "visible_text" => visible_text,
    "links" => links,
    "images" => images
  }
  [Digest::SHA256.hexdigest(JSON.generate(payload)), payload]
end

def expected_detail_links(publication)
  [publication.dig("links", "article")] +
    publication.dig("links", "data").map { |dataset| dataset.fetch("url") }
end

def verify_hreflang!(html, mode, label)
  alternates = html.scan(/<link\b[^>]*\brel="alternate"[^>]*>/i)
  %w[en zh-CN].each do |language|
    tag = alternates.find { |candidate| candidate.match?(/\bhreflang="#{Regexp.escape(language)}"/i) }
    fail_unless(tag, "#{mode} #{label} is missing hreflang=#{language}")
    href = CGI.unescapeHTML(tag[/\bhref="([^"]*)"/i, 1].to_s)
    expected_url = language == "en" ? ENGLISH_DETAIL_ABSOLUTE_URL : CHINESE_DETAIL_ABSOLUTE_URL
    fail_unless(href == expected_url,
                "#{mode} #{label} hreflang=#{language} points to #{href.inspect}, expected #{expected_url}")
  end
end

def meta_content(html, attribute, value)
  tag = html.scan(/<meta\b[^>]*>/i).find do |candidate|
    candidate.match?(/\b#{Regexp.escape(attribute)}="#{Regexp.escape(value)}"/i)
  end
  tag && CGI.unescapeHTML(tag[/\bcontent="([^"]*)"/i, 1].to_s)
end

def canonical_href(html)
  tag = html.scan(/<link\b[^>]*>/i).find { |candidate| candidate.match?(/\brel="canonical"/i) }
  tag && CGI.unescapeHTML(tag[/\bhref="([^"]*)"/i, 1].to_s)
end

def json_ld_document(html, mode, label)
  source = html[/<script\s+type="application\/ld\+json">\s*(.*?)\s*<\/script>/mi, 1]
  fail_unless(source, "#{mode} #{label} has no JSON-LD document")
  JSON.parse(source)
rescue JSON::ParserError => e
  raise RendererVerificationError, "#{mode} #{label} JSON-LD is invalid: #{e.message}"
end

def verify_publication_metadata!(html, mode, label, expected_url, description, locale)
  fail_unless(canonical_href(html) == expected_url,
              "#{mode} #{label} canonical URL is not page-specific")
  fail_unless(meta_content(html, "property", "og:url") == expected_url,
              "#{mode} #{label} og:url is not page-specific")
  fail_unless(meta_content(html, "property", "twitter:url") == expected_url,
              "#{mode} #{label} twitter:url is not page-specific")
  fail_unless(meta_content(html, "name", "description") == description,
              "#{mode} #{label} meta description is not the approved localized summary")
  fail_unless(meta_content(html, "property", "og:description") == description &&
              meta_content(html, "property", "twitter:description") == description,
              "#{mode} #{label} Open Graph/Twitter description is not localized")
  fail_unless(meta_content(html, "property", "og:image") == GRAPHICAL_ABSTRACT_ABSOLUTE_URL &&
              meta_content(html, "property", "twitter:image") == GRAPHICAL_ABSTRACT_ABSOLUTE_URL,
              "#{mode} #{label} social image is not the absolute graphical-abstract URL")
  fail_unless(meta_content(html, "property", "og:type") == "article",
              "#{mode} #{label} og:type must be article")
  fail_unless(meta_content(html, "property", "og:locale") == locale,
              "#{mode} #{label} og:locale is incorrect")
  fail_unless(html.include?(
                "<title>Single-cell nascent transcription reveals sparse genome usage and plasticity | XShen Lab</title>"
              ), "#{mode} #{label} browser title changed")
  fail_unless(meta_content(html, "name", "author").nil? &&
              meta_content(html, "property", "article:published_time").nil?,
              "#{mode} #{label} invents publication author or date metadata")

  json_ld = json_ld_document(html, mode, label)
  fail_unless(json_ld["url"] == expected_url,
              "#{mode} #{label} JSON-LD URL is not page-specific")
  fail_unless(json_ld["description"] == description,
              "#{mode} #{label} JSON-LD description is not localized")
end

def verify_research_metadata!(html, mode)
  config = load_yaml(CONFIG_PATH)
  expected_description = "#{config['subtitle']}. #{config['description']}"
  fail_unless(canonical_href(html) == RESEARCH_ABSOLUTE_URL,
              "#{mode} Research canonical URL is not page-specific")
  fail_unless(meta_content(html, "property", "og:url") == RESEARCH_ABSOLUTE_URL &&
              meta_content(html, "property", "twitter:url") == RESEARCH_ABSOLUTE_URL,
              "#{mode} Research Open Graph/Twitter URL is not page-specific")
  fail_unless(meta_content(html, "name", "description") == expected_description,
              "#{mode} ordinary-page description behavior changed")
  json_ld = json_ld_document(html, mode, "Research")
  fail_unless(json_ld["url"] == RESEARCH_ABSOLUTE_URL,
              "#{mode} Research JSON-LD URL is not page-specific")
end

def verify_english_detail_output!(html, mode, publication, enrichment)
  signature, payload = detail_signature(html)
  localized = enrichment.dig("localized", "en")
  fail_unless(signature == APPROVED_PRE_REFACTOR_DETAIL_SHA256,
              "#{mode} scFLUENT-seq detail text/actions/image differ from the approved pre-refactor output")
  fail_unless(payload.fetch("links") == expected_detail_links(publication),
              "#{mode} English scFLUENT-seq detail DOI/GEO links differ from canonical data")
  expected_image = {
    "src" => enrichment.dig("graphical_abstract", "path"),
    "alt" => enrichment.dig("graphical_abstract", "alt", "en")
  }
  fail_unless(payload.fetch("images") == [expected_image],
              "#{mode} English scFLUENT-seq image source or alt text changed")
  fail_unless(!html.include?("scfluent-seq-cell-2025.pdf") &&
              html !~ /<a\b[^>]*>\s*PDF\s*<\/a>/i,
              "#{mode} scFLUENT-seq detail exposes an unapproved PDF action")
  verify_publication_metadata!(
    html, mode, "English detail", ENGLISH_DETAIL_ABSOLUTE_URL, localized["summary"], "en_US"
  )
  verify_hreflang!(html, mode, "English detail")
end

def verify_chinese_detail_output!(html, mode, publication, enrichment)
  signature, payload = detail_signature(html)
  localized = enrichment.dig("localized", "zh-CN")
  fail_unless(localized["metric"] == CHINESE_METRIC,
              "#{mode} Chinese scFLUENT-seq metric is not the approved Chinese text")
  fail_unless(html.match?(/<html\s+lang="zh-CN"/i),
              "#{mode} Chinese scFLUENT-seq detail does not declare lang=zh-CN")
  fail_unless(html.include?('<meta property="og:locale" content="zh_CN">'),
              "#{mode} Chinese scFLUENT-seq detail does not declare og:locale=zh_CN")
  expected_text_fragments = [
    publication["title"],
    publication.dig("authors", "display"),
    localized["summary"],
    "关键指标： #{CHINESE_METRIC}",
    "查看论文",
    "数据",
    *publication.dig("links", "data").map { |dataset| dataset.fetch("label") }
  ]
  expected_text_fragments.each do |fragment|
    fail_unless(payload.fetch("visible_text").include?(fragment),
                "#{mode} Chinese scFLUENT-seq detail is missing #{fragment.inspect}")
  end
  fail_unless(payload.fetch("links") == expected_detail_links(publication),
              "#{mode} Chinese scFLUENT-seq detail DOI/GEO links differ from canonical data")
  expected_image = {
    "src" => enrichment.dig("graphical_abstract", "path"),
    "alt" => enrichment.dig("graphical_abstract", "alt", "zh-CN")
  }
  fail_unless(payload.fetch("images") == [expected_image],
              "#{mode} Chinese scFLUENT-seq graphical-abstract source or alt text is incorrect")
  fail_unless(signature != APPROVED_PRE_REFACTOR_DETAIL_SHA256,
              "#{mode} Chinese detail unexpectedly rendered the English detail content")
  fail_unless(!html.include?("scfluent-seq-cell-2025.pdf") &&
              html !~ /<a\b[^>]*>\s*PDF\s*<\/a>/i,
              "#{mode} Chinese scFLUENT-seq detail exposes an unapproved PDF action")
  verify_publication_metadata!(
    html, mode, "Chinese detail", CHINESE_DETAIL_ABSOLUTE_URL, localized["summary"], "zh_CN"
  )
  verify_hreflang!(html, mode, "Chinese detail")
end

def without_publication_list(page, list_html)
  page.sub(list_html, "<!-- verified-full-publications-list -->")
      .gsub(/\s*<!-- verified-full-publications-list -->\s*/, "\n<!-- verified-full-publications-list -->\n")
end

def verify_mode_parity!(production_pages, production_lists, rollback_pages, rollback_lists)
  PAGE_PATHS.keys.each do |language|
    production_without_list = without_publication_list(
      production_pages.fetch(language), production_lists.fetch(language)[:html]
    )
    rollback_without_list = without_publication_list(
      rollback_pages.fetch(language), rollback_lists.fetch(language)[:html]
    )
    fail_unless(production_without_list == rollback_without_list,
                "#{language} page changed outside the complete bibliography list")
  end

  DETAIL_PATHS.keys.each do |label|
    fail_unless(production_pages.fetch(label) == rollback_pages.fetch(label),
                "#{label} page differs between production and rollback modes")
  end
  AUXILIARY_PAGE_PATHS.keys.each do |label|
    fail_unless(production_pages.fetch(label) == rollback_pages.fetch(label),
                "#{label} page differs between production and rollback modes")
  end
end

def verify!
  verify_default_configuration!
  verify_renderer_wiring!

  legacy = legacy_citations
  records = canonical_records
  verify_browser_data!(records)
  canonical = canonical_citations(records)
  enrichment = enrichment_document
  verify_approved_sequence!("legacy bibliography", legacy)
  verify_approved_sequence!("canonical data", canonical)
  fail_unless(canonical == legacy,
              "canonical citation order or visible text differs from the legacy bibliography")

  production_pages = build_production_pages
  production_lists = verify_mode!(production_pages, "production mode", legacy, records, enrichment)
  puts "PASS publications renderer production mode: enabled=true; data-driven English=52/Chinese=52; " \
       "representative cards English=13/Chinese=13; bilingual scFLUENT-seq routes and localized detail output; " \
       "page-specific canonical/social/JSON-LD metadata; approved order, visible text, checksum, " \
       "and English pre-refactor detail parity."

  rollback_pages = build_rollback_pages
  rollback_lists = verify_mode!(rollback_pages, "rollback mode", legacy, records, enrichment)
  puts "PASS publications renderer rollback mode: enabled=false override; legacy English=52/Chinese=52; " \
       "representative cards English=13/Chinese=13; bilingual scFLUENT-seq routes and localized detail output; " \
       "page-specific canonical/social/JSON-LD metadata; approved order, visible text, checksum, URLs, " \
       "and English pre-refactor detail parity."

  verify_mode_parity!(production_pages, production_lists, rollback_pages, rollback_lists)
  puts "PASS publications renderer mode parity: citation-only lists; bilingual sequences identical; " \
       "page content outside the list and both scFLUENT-seq detail outputs mode-identical; " \
       "bibliography checksum=#{APPROVED_SEQUENCE_SHA256}; " \
       "detail checksum=#{APPROVED_PRE_REFACTOR_DETAIL_SHA256}."
end

begin
  verify!
rescue RendererVerificationError, KeyError => e
  warn "FAIL publications renderer: #{e.message}"
  exit 1
end
