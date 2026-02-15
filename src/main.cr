require "./scraper/**"
require "./plugins/**"
require "./http/**"
require "./outputs/**"
require "./extraction/**"
require "./cli/**"

module GenericScraper
  VERSION = "0.1.0"
end

# Entry point
Scraper::CLI::App.run(ARGV)
