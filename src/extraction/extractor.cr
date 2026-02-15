require "lexbor"
require "json"

module Scraper
  class Extractor
    def from_html(html : String, rules : Hash(String, String)) : Hash(String, String | Nil)
      result = Hash(String, String | Nil).new
      parser = Lexbor::Parser.new(html)

      rules.each do |field, selector|
        # Handle attribute extraction: "selector[attr]"
        if match = selector.match(/^(.+)\[(\w+)\]$/)
          css_selector = match[1]
          attribute = match[2]
          node = parser.css(css_selector).first?
          result[field] = node.try(&.attribute_by(attribute))
        else
          node = parser.css(selector).first?
          result[field] = node.try(&.inner_text.strip)
        end
      end

      result
    end

    def from_json(json_str : String, rules : Hash(String, String)) : Hash(String, String | Nil)
      result = Hash(String, String | Nil).new
      data = JSON.parse(json_str)

      rules.each do |field, path|
        value = resolve_json_path(data, path)
        result[field] = value.try(&.to_s)
      end

      result
    end

    private def resolve_json_path(data : JSON::Any, path : String) : JSON::Any?
      current = data
      path.split(".").each do |key|
        if idx = key.to_i?
          current = current[idx]?
        else
          current = current[key]?
        end
        return nil unless current
      end
      current
    end
  end
end
