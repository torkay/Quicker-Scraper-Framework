require "yaml"
require "./types"

module Scraper
  class Config
    property framework : YAML::Any
    property vendors : YAML::Any

    def initialize(config_dir : String = "config")
      @framework = YAML.parse(File.read(File.join(config_dir, "framework.yaml")))
      @vendors = YAML.parse(File.read(File.join(config_dir, "vendors.yaml")))
    end

    def load_vendor(name : String) : VendorConfig
      vendor_data = @vendors["vendors"][name]
      raise "Vendor '#{name}' not found in config" unless vendor_data

      config = VendorConfig.new(name, vendor_data["base_url"].as_s)
      config.enabled = vendor_data["enabled"]?.try(&.as_bool) || true
      config.mode = vendor_data["mode"]?.try(&.as_s) || "ingest"
      config.rate_limit_rps = vendor_data["rate_limit_rps"]?.try(&.as_f) || 1.0
      config.timeout_seconds = vendor_data["timeout_seconds"]?.try(&.as_i) || 30

      if rules = vendor_data["extraction_rules"]?
        config.extraction_rules = Hash(String, String).new.tap do |h|
          rules.as_h.each { |k, v| h[k.as_s] = v.as_s }
        end
      end

      if rules = vendor_data["normalization_rules"]?
        config.normalization_rules = Hash(String, String).new.tap do |h|
          rules.as_h.each { |k, v| h[k.as_s] = v.as_s }
        end
      end

      config
    end

    def outputs : Array(String)
      format = @framework["output"]?.try(&.["format"]?).try(&.as_s) || "json"
      path = @framework["output"]?.try(&.["path"]?).try(&.as_s) || "./output/"
      [format, path]
    end

    def vendor_names : Array(String)
      names = Array(String).new
      if vendors = @vendors["vendors"]?
        vendors.as_h.each_key { |k| names << k.as_s }
      end
      names
    end

    def global_timeout : Int32
      @framework["global"]?.try(&.["timeout_seconds"]?).try(&.as_i) || 30
    end

    def user_agent : String
      @framework["global"]?.try(&.["user_agent"]?).try(&.as_s) || "GenericScraper/1.0"
    end
  end
end
