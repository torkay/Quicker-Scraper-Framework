require "digest/sha256"
require "json"
require "./types"

module Scraper
  class Normalizer
    def normalize(raw : RawListing, vendor : String, rules : Hash(String, String)? = nil) : NormalizedListing
      fingerprint = generate_fingerprint(raw.url, raw.title)
      listing = NormalizedListing.new(fingerprint, vendor)
      listing.extracted_at = raw.extracted_at
      listing.normalized_at = Time.utc

      # Copy raw fields to normalized fields as JSON::Any
      raw.fields.each do |key, value|
        listing.fields[key] = case value
                              when String then JSON::Any.new(value)
                              when Int32  then JSON::Any.new(value.to_i64)
                              when Float64 then JSON::Any.new(value)
                              when Nil     then JSON::Any.new(nil)
                              else          JSON::Any.new(value.to_s)
                              end
      end

      # Apply normalization rules if provided
      apply_rules(listing, rules) if rules

      listing
    end

    private def apply_rules(listing : NormalizedListing, rules : Hash(String, String))
      rules.each do |target_field, rule_str|
        parts = rule_str.split(":")
        next unless parts.size == 2
        source_field = parts[0]
        transform = parts[1]

        value = listing.fields[source_field]?.try(&.as_s?)
        next unless value

        transformed = apply_transform(value, transform)
        listing.fields[target_field] = JSON::Any.new(transformed)
      end
    end

    private def apply_transform(value : String, transform : String) : String
      case transform
      when "trim"
        value.strip
      when "upcase"
        value.upcase
      when "downcase"
        value.downcase
      when "extract_number"
        match = value.match(/[\d,]+\.?\d*/)
        match ? match[0].gsub(",", "") : value
      when "extract_price"
        match = value.match(/[\d,]+\.?\d*/)
        match ? match[0].gsub(",", "") : value
      else
        value
      end
    end

    private def generate_fingerprint(url : String, title : String?) : String
      input = "#{url}|#{title}"
      Digest::SHA256.hexdigest(input)[0, 12]
    end
  end
end
