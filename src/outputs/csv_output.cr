require "csv"
require "./output_driver"
require "../scraper/types"

module Scraper
  class CsvOutput < OutputDriver
    property path : String

    def initialize(@path : String)
    end

    def write(listings : Array(NormalizedListing))
      return if listings.empty?

      # Collect all unique field keys across listings
      headers = ["id", "source", "extracted_at", "normalized_at"]
      field_keys = [] of String
      listings.each do |listing|
        listing.fields.each_key do |key|
          field_keys << key unless field_keys.includes?(key)
        end
      end
      headers.concat(field_keys)

      File.open(@path, "w") do |file|
        csv = CSV::Builder.new(file)
        csv.row headers

        listings.each do |listing|
          row = [
            listing.id,
            listing.source,
            listing.extracted_at.to_s,
            listing.normalized_at.to_s,
          ]
          field_keys.each do |key|
            value = listing.fields[key]?
            row << (value ? value.to_s : "")
          end
          csv.row row
        end
      end
    end
  end
end
