require "./vendor_adapter"

module Scraper
  class VendorRegistry
    @@vendors = Hash(String, VendorAdapter).new

    def self.register(adapter : VendorAdapter)
      @@vendors[adapter.name] = adapter
    end

    def self.get(name : String) : VendorAdapter?
      @@vendors[name]?
    end

    def self.all : Hash(String, VendorAdapter)
      @@vendors
    end
  end
end
