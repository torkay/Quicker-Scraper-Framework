require "./types"
require "./config"
require "./normalizer"
require "../plugins/registry"

module Scraper
  class Pipeline
    property config : Config
    property normalizer : Normalizer

    def initialize(@config : Config)
      @normalizer = Normalizer.new
    end

    def run(job : ScrapeJob) : ScrapeResult
      result = ScrapeResult.new(job)
      start = Time.instant

      begin
        vendor_config = @config.load_vendor(job.vendor)

        unless vendor_config.enabled
          result.errors << "Vendor '#{job.vendor}' is disabled"
          result.duration_seconds = (Time.instant - start).total_seconds
          return result
        end

        adapter = VendorRegistry.get(job.vendor)
        unless adapter
          result.errors << "No adapter registered for vendor '#{job.vendor}'"
          result.duration_seconds = (Time.instant - start).total_seconds
          return result
        end

        # Execute search
        query = job.query || Hash(String, String).new
        raw_listings = adapter.search(query, job.limit, job.pages)
        result.listings_raw = raw_listings

        # Normalize
        raw_listings.each do |raw|
          normalized = @normalizer.normalize(raw, job.vendor, vendor_config.normalization_rules)
          result.listings_normalized << normalized
        end
      rescue ex
        result.errors << ex.message.to_s
      end

      result.duration_seconds = (Time.instant - start).total_seconds
      result
    end
  end
end
