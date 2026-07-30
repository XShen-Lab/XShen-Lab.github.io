#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "digest"
require "json"
require "open3"
require "tempfile"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "_config.yaml")
LEGACY_PATH = File.join(ROOT, "_includes", "full-publications.html")
LIST_PATH = File.join(ROOT, "_includes", "publications", "list.html")
DATA_PATH = File.join(ROOT, "_data", "publications.yml")
PAGE_PATHS = {
  "English" => File.join("publications", "index.html"),
  "Chinese" => File.join("zh", "publications", "index.html")
}.freeze
PAGE_SOURCE_PATHS = [
  File.join(ROOT, "publications", "index.md"),
  File.join(ROOT, "zh", "publications", "index.md")
].freeze
DETAIL_PATH = File.join("publications", "2025-scfluent-seq", "index.html")
EXPECTED_SWITCH = "{% if site.publications_v2.enabled %}{% include publications/list.html %}" \
                  "{% else %}{% include full-publications.html %}{% endif %}"
APPROVED_SEQUENCE_SHA256 = "2526131b41eae70abd0d7e1d4509543c590e9b9246771471e193cbe6b7bcde52".freeze
APPROVED_PRE_REFACTOR_DETAIL_SHA256 =
  "fb5111662587f5715d0872014940ad509d15b75c6913a02212d0f05a27a4989d".freeze
EXPECTED_COUNT = 52

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

def canonical_citations
  data = load_yaml(DATA_PATH)
  records = data["records"]
  fail_unless(records.is_a?(Array) && records.length == EXPECTED_COUNT,
              "canonical record count is #{records&.length || 0}, expected #{EXPECTED_COUNT}")

  sorted = records.sort_by { |record| record.fetch("cv_order") }
  orders = sorted.map { |record| record["cv_order"] }
  fail_unless(orders == (1..EXPECTED_COUNT).to_a,
              "canonical cv_order must be exactly 1 through #{EXPECTED_COUNT}")

  sorted.map.with_index do |record, index|
    citation = record["citation"]
    fail_unless(citation.is_a?(String) && !citation.strip.empty?,
                "canonical citation #{index + 1} is empty")
    citation
  end
end

def verify_default_configuration!
  config = load_yaml(CONFIG_PATH)
  fail_unless(config.dig("publications_v2", "enabled") == true,
              "production publications_v2.enabled must be true")
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

  PAGE_SOURCE_PATHS.each do |path|
    source = File.read(path, encoding: "UTF-8")
    fail_unless(source.include?(EXPECTED_SWITCH),
                "#{path.delete_prefix(ROOT + "/")} does not preserve the verified feature-flag switch")
  end
end

def read_built_pages(destination, mode)
  pages = PAGE_PATHS.to_h do |language, relative_path|
    path = File.join(destination, relative_path)
    fail_unless(File.file?(path),
                "#{mode} #{language} page is missing at /#{relative_path.delete_suffix("index.html")}")
    [language, File.read(path, encoding: "UTF-8")]
  end

  detail = File.join(destination, DETAIL_PATH)
  fail_unless(File.file?(detail),
              "#{mode} scFLUENT-seq detail URL /publications/2025-scfluent-seq/ is missing")
  pages["Detail"] = File.read(detail, encoding: "UTF-8")
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

def extract_publication_list(html, label)
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
  fail_unless(list_content !~ /<(?:a|button|img)\b/i,
              "#{label} list contains a link, button, or image")

  items = list_content.scan(/<li\b([^>]*)>(.*?)<\/li>/mi)
  fail_unless(items.length == EXPECTED_COUNT,
              "#{label} count is #{items.length}, expected #{EXPECTED_COUNT}")

  citations = items.each_with_index.map do |(item_attributes, content), index|
    fail_unless(item_attributes.strip.empty?,
                "#{label} item #{index + 1} has attributes or metadata")
    fail_unless(content !~ /<[^>]+>/,
                "#{label} item #{index + 1} contains nested markup or metadata")
    citation = CGI.unescapeHTML(content)
    fail_unless(!citation.strip.empty?, "#{label} item #{index + 1} is empty")
    citation
  end

  remainder = list_content.gsub(/<li\b[^>]*>.*?<\/li>/mi, "")
  fail_unless(remainder.strip.empty?,
              "#{label} list contains content outside its citation items")
  { citations: citations, html: full_html }
end

def verify_mode!(pages, mode, legacy)
  lists = PAGE_PATHS.keys.to_h do |language|
    list = extract_publication_list(pages.fetch(language), "#{mode} #{language}")
    fail_unless(list[:citations] == legacy,
                "#{mode} #{language} order or visible citation text differs from legacy")
    verify_approved_sequence!("#{mode} #{language}", list[:citations])
    [language, list]
  end

  fail_unless(lists.fetch("English")[:citations] == lists.fetch("Chinese")[:citations],
              "#{mode} English and Chinese citation sequences differ")
  verify_detail_output!(pages.fetch("Detail"), mode)
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

def verify_detail_output!(html, mode)
  signature, payload = detail_signature(html)
  fail_unless(signature == APPROVED_PRE_REFACTOR_DETAIL_SHA256,
              "#{mode} scFLUENT-seq detail text/actions/image differ from the approved pre-refactor output")
  fail_unless(html.include?(
                "<title>Single-cell nascent transcription reveals sparse genome usage and plasticity | XShen Lab</title>"
              ), "#{mode} scFLUENT-seq browser title changed")
  fail_unless(payload.fetch("links").length == 4,
              "#{mode} scFLUENT-seq detail must contain one DOI and three GEO links")
  fail_unless(!html.include?("scfluent-seq-cell-2025.pdf") &&
              html !~ /<a\b[^>]*>\s*PDF\s*<\/a>/i,
              "#{mode} scFLUENT-seq detail exposes an unapproved PDF action")
end

def without_publication_list(page, list_html)
  page.sub(list_html, "<!-- verified-full-publications-list -->")
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

  fail_unless(production_pages.fetch("Detail") == rollback_pages.fetch("Detail"),
              "scFLUENT-seq detail page differs between production and rollback modes")
end

def verify!
  verify_default_configuration!
  verify_renderer_wiring!

  legacy = legacy_citations
  canonical = canonical_citations
  verify_approved_sequence!("legacy bibliography", legacy)
  verify_approved_sequence!("canonical data", canonical)
  fail_unless(canonical == legacy,
              "canonical citation order or visible text differs from the legacy bibliography")

  production_pages = build_production_pages
  production_lists = verify_mode!(production_pages, "production mode", legacy)
  puts "PASS publications renderer production mode: enabled=true; data-driven English=52/Chinese=52; " \
       "approved order, visible text, checksum, and scFLUENT-seq pre-refactor detail parity."

  rollback_pages = build_rollback_pages
  rollback_lists = verify_mode!(rollback_pages, "rollback mode", legacy)
  puts "PASS publications renderer rollback mode: enabled=false override; legacy English=52/Chinese=52; " \
       "approved order, visible text, checksum, URLs, and scFLUENT-seq pre-refactor detail parity."

  verify_mode_parity!(production_pages, production_lists, rollback_pages, rollback_lists)
  puts "PASS publications renderer mode parity: citation-only lists; bilingual sequences identical; " \
       "page content outside the list and scFLUENT-seq detail output unchanged; " \
       "bibliography checksum=#{APPROVED_SEQUENCE_SHA256}; " \
       "detail checksum=#{APPROVED_PRE_REFACTOR_DETAIL_SHA256}."
end

begin
  verify!
rescue RendererVerificationError, KeyError => e
  warn "FAIL publications renderer: #{e.message}"
  exit 1
end
