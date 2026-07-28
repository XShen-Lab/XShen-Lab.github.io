#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "digest"
require "open3"
require "tempfile"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "_config.yaml")
LEGACY_PATH = File.join(ROOT, "_includes", "full-publications.html")
DATA_PATH = File.join(ROOT, "_data", "publications.yml")
APPROVED_SEQUENCE_SHA256 = "2526131b41eae70abd0d7e1d4509543c590e9b9246771471e193cbe6b7bcde52".freeze
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
  fail_unless(config.dig("publications_v2", "enabled") == false,
              "publications_v2.enabled must remain false in the default configuration")
end

def build_shadow_pages
  Dir.mktmpdir("publications-v2-renderer-") do |destination|
    Tempfile.create(["publications-v2-enabled", ".yml"]) do |override|
      override.write(YAML.dump("publications_v2" => { "enabled" => true }))
      override.flush

      command = [
        "bundle", "exec", "jekyll", "build",
        "--config", "#{CONFIG_PATH},#{override.path}",
        "--destination", destination
      ]
      stdout, stderr, status = Open3.capture3(
        { "JEKYLL_ENV" => "production" },
        *command,
        chdir: ROOT
      )
      fail_unless(status.success?,
                  "shadow Jekyll build failed:\n#{stdout}#{stderr}")

      english_path = File.join(destination, "publications", "index.html")
      chinese_path = File.join(destination, "zh", "publications", "index.html")
      fail_unless(File.file?(english_path), "shadow English publication page was not generated")
      fail_unless(File.file?(chinese_path), "shadow Chinese publication page was not generated")

      return {
        "English" => File.read(english_path, encoding: "UTF-8"),
        "Chinese" => File.read(chinese_path, encoding: "UTF-8")
      }
    end
  end
end

def extract_shadow_citations(html, label)
  lists = html.scan(/<ol\b([^>]*)>(.*?)<\/ol>/mi).select do |attributes, _content|
    attributes.match?(/\bclass\s*=\s*["'][^"']*\bfull-publications\b[^"']*["']/i)
  end
  fail_unless(lists.length == 1,
              "#{label} shadow output contains #{lists.length} full-publications lists, expected 1")

  list_content = lists.first[1]
  fail_unless(list_content !~ /<(?:a|button|img)\b/i,
              "#{label} shadow list contains a link, button, or image")

  items = list_content.scan(/<li\b([^>]*)>(.*?)<\/li>/mi)
  fail_unless(items.length == EXPECTED_COUNT,
              "#{label} shadow count is #{items.length}, expected #{EXPECTED_COUNT}")

  citations = items.each_with_index.map do |(attributes, content), index|
    fail_unless(attributes.strip.empty?,
                "#{label} shadow item #{index + 1} has attributes or metadata")
    fail_unless(content !~ /<[^>]+>/,
                "#{label} shadow item #{index + 1} contains nested markup or metadata")
    citation = CGI.unescapeHTML(content)
    fail_unless(!citation.strip.empty?, "#{label} shadow item #{index + 1} is empty")
    citation
  end

  remainder = list_content.gsub(/<li\b[^>]*>.*?<\/li>/mi, "")
  fail_unless(remainder.strip.empty?,
              "#{label} shadow list contains content outside its citation items")
  citations
end

def verify!
  verify_default_configuration!

  legacy = legacy_citations
  canonical = canonical_citations
  verify_approved_sequence!("legacy bibliography", legacy)
  verify_approved_sequence!("canonical data", canonical)
  fail_unless(canonical == legacy,
              "canonical citation order or visible text differs from the legacy bibliography")

  pages = build_shadow_pages
  english = extract_shadow_citations(pages.fetch("English"), "English")
  chinese = extract_shadow_citations(pages.fetch("Chinese"), "Chinese")

  fail_unless(english == legacy,
              "English shadow order or visible text differs from the legacy bibliography")
  fail_unless(chinese == legacy,
              "Chinese shadow order or visible text differs from the legacy bibliography")
  fail_unless(english == chinese, "English and Chinese shadow sequences differ")
  verify_approved_sequence!("English shadow output", english)
  verify_approved_sequence!("Chinese shadow output", chinese)

  puts "PASS publications renderer: legacy=52; shadow English=52/Chinese=52; " \
       "exact order and decoded visible-text parity; checksum=#{APPROVED_SEQUENCE_SHA256}; " \
       "citation-only items; bilingual sequences identical."
end

begin
  verify!
rescue RendererVerificationError, KeyError => e
  warn "FAIL publications renderer: #{e.message}"
  exit 1
end
