require "json"
require "digest/sha256"

module Scraper
  class RawListing
    property url : String
    property title : String?
    property fields : Hash(String, String | Int32 | Float64 | Nil)
    property extracted_at : Time
    property metadata : Hash(String, String)?

    def initialize(@url : String, @title : String? = nil)
      @fields = Hash(String, String | Int32 | Float64 | Nil).new
      @extracted_at = Time.utc
      @metadata = nil
    end
  end

  class NormalizedListing
    include JSON::Serializable

    property id : String
    property source : String
    property schema_version : String
    property fields : Hash(String, JSON::Any)
    property extracted_at : Time
    property normalized_at : Time
    property hydrated : Bool

    def initialize(@id : String, @source : String)
      @schema_version = "1.0"
      @fields = Hash(String, JSON::Any).new
      @extracted_at = Time.utc
      @normalized_at = Time.utc
      @hydrated = false
    end
  end

  class VendorConfig
    include JSON::Serializable

    property name : String
    property base_url : String
    property enabled : Bool
    property mode : String
    property rate_limit_rps : Float64
    property timeout_seconds : Int32
    property extraction_rules : Hash(String, String)?
    property normalization_rules : Hash(String, String)?
    property custom : Hash(String, JSON::Any)?

    def initialize(@name : String, @base_url : String)
      @enabled = true
      @mode = "ingest"
      @rate_limit_rps = 1.0
      @timeout_seconds = 30
      @extraction_rules = nil
      @normalization_rules = nil
      @custom = nil
    end
  end

  class ScrapeJob
    include JSON::Serializable

    property vendor : String
    property query : Hash(String, String)?
    property limit : Int32
    property pages : Int32
    property priority : String
    property start_page : Int32

    def initialize(@vendor : String)
      @query = nil
      @limit = 100
      @pages = 10
      @priority = "normal"
      @start_page = 1
    end
  end

  class ScrapeResult
    property job : ScrapeJob
    property listings_raw : Array(RawListing)
    property listings_normalized : Array(NormalizedListing)
    property errors : Array(String)
    property duration_seconds : Float64
    property timestamp : Time

    def initialize(@job : ScrapeJob)
      @listings_raw = Array(RawListing).new
      @listings_normalized = Array(NormalizedListing).new
      @errors = Array(String).new
      @duration_seconds = 0.0
      @timestamp = Time.utc
    end

    def success? : Bool
      errors.empty? && !listings_raw.empty?
    end
  end
end
