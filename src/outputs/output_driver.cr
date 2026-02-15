require "../scraper/types"

module Scraper
  abstract class OutputDriver
    abstract def write(listings : Array(NormalizedListing))
  end
end
