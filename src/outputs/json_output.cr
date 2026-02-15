require "json"
require "./output_driver"
require "../scraper/types"

module Scraper
  class JsonOutput < OutputDriver
    property path : String

    def initialize(@path : String)
    end

    def write(listings : Array(NormalizedListing))
      json = JSON.build(indent: 2) do |builder|
        builder.array do
          listings.each do |listing|
            listing.to_json(builder)
          end
        end
      end
      File.write(@path, json)
    end
  end
end
