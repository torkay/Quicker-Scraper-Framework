require "../scraper/types"

module Scraper
  abstract class VendorAdapter
    abstract def name : String
    abstract def search(query : Hash(String, String), limit : Int32, pages : Int32) : Array(RawListing)

    def extract_detail(url : String) : Hash(String, String)?
      nil
    end

    def supports_detail? : Bool
      false
    end

    protected def log(message : String)
      puts "[#{name}] #{message}"
    end

    protected def log_error(message : String)
      STDERR.puts "[#{name}] ERROR: #{message}"
    end
  end
end
