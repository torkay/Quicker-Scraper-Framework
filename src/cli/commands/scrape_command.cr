require "option_parser"
require "../../scraper/types"
require "../../scraper/pipeline"
require "../../scraper/config"
require "../../outputs/json_output"
require "../../outputs/csv_output"

module Scraper
  module CLI
    class ScrapeCommand
      def self.run(args : Array(String))
        vendor = ""
        limit = 100
        output = ""
        query = ""
        config_dir = "config"

        OptionParser.parse(args) do |parser|
          parser.banner = "Usage: scraper scrape [options]"
          parser.on("--vendor NAME", "-v NAME", "Vendor to scrape") { |v| vendor = v }
          parser.on("--limit N", "-l N", "Max listings to fetch") { |n| limit = n.to_i }
          parser.on("--output PATH", "-o PATH", "Output file (json/csv by extension)") { |p| output = p }
          parser.on("--query TEXT", "-q TEXT", "Search query") { |q| query = q }
          parser.on("--config DIR", "-c DIR", "Config directory path") { |c| config_dir = c }
          parser.on("-h", "--help", "Show help") do
            puts parser
            exit 0
          end
        end

        if vendor.empty?
          STDERR.puts "Error: --vendor is required"
          exit 1
        end

        # Build job
        job = ScrapeJob.new(vendor)
        job.limit = limit
        unless query.empty?
          job.query = {"q" => query}
        end

        # Run pipeline
        config = Config.new(config_dir)
        pipeline = Pipeline.new(config)
        puts "Scraping #{vendor} (limit: #{limit})..."
        result = pipeline.run(job)

        # Report
        if result.success?
          puts "Found #{result.listings_normalized.size} listings in #{result.duration_seconds.round(2)}s"
        else
          STDERR.puts "Errors: #{result.errors.join(", ")}"
        end

        # Output
        if !output.empty? && !result.listings_normalized.empty?
          driver = if output.ends_with?(".csv")
                     CsvOutput.new(output)
                   else
                     JsonOutput.new(output)
                   end
          driver.write(result.listings_normalized)
          puts "Written to #{output}"
        elsif result.success?
          # Print to stdout as JSON
          result.listings_normalized.each do |listing|
            puts listing.to_json
          end
        end
      end
    end
  end
end
