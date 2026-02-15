require "lexbor"
require "../../http/client"
require "../vendor_adapter"
require "../registry"

module Scraper
  class GraysVendor < VendorAdapter
    property http_client : HttpClient

    def initialize(@http_client : HttpClient = HttpClient.new)
    end

    def name : String
      "grays"
    end

    def search(query : Hash(String, String), limit : Int32, pages : Int32) : Array(RawListing)
      listings = Array(RawListing).new
      make = query["make"]? || ""
      model = query["model"]? || ""

      (1..pages).each do |page|
        break if listings.size >= limit

        url = "https://www.grays.com/search?make=#{URI.encode_www_form(make)}&model=#{URI.encode_www_form(model)}&page=#{page}"
        log("Fetching page #{page}: #{url}")

        begin
          response = @http_client.get(url)
          page_listings = parse_listings(response.body, url)
          listings.concat(page_listings)
        rescue ex
          log_error("Page #{page} failed: #{ex.message}")
        end
      end

      listings.first(limit)
    end

    private def parse_listings(html : String, source_url : String) : Array(RawListing)
      listings = Array(RawListing).new
      parser = Lexbor::Parser.new(html)

      parser.css("div.vehicle-card").each do |card|
        listing = RawListing.new(url: extract_text(card, "a.vehicle-link", "href") || source_url)
        listing.title = extract_text(card, "h2.vehicle-title")

        listing.fields["price"] = extract_text(card, "span.price")
        listing.fields["year"] = extract_text(card, "span.year")
        listing.fields["mileage"] = extract_text(card, "span.mileage")
        listing.fields["condition"] = extract_text(card, "span.condition")

        if link = extract_text(card, "a.vehicle-link", "href")
          listing.fields["url"] = link
        end

        listings << listing
      end

      listings
    end

    private def extract_text(node : Lexbor::Node, selector : String, attr : String? = nil) : String?
      found = node.css(selector).first?
      return nil unless found

      if attr
        found.attribute_by(attr)
      else
        found.inner_text.strip
      end
    end
  end
end
