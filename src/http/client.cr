require "http/client"
require "./rate_limiter"

module Scraper
  class HttpClient
    property timeout : Int32
    property user_agent : String
    property rate_limiter : RateLimiter
    property max_retries : Int32

    def initialize(
      @timeout : Int32 = 30,
      @user_agent : String = "Scraper/1.0",
      @rate_limiter : RateLimiter = RateLimiter.new,
      @max_retries : Int32 = 3
    )
    end

    def get(url : String, headers : HTTP::Headers? = nil) : HTTP::Client::Response
      uri = URI.parse(url)
      retries = 0

      loop do
        @rate_limiter.wait

        begin
          client = HTTP::Client.new(uri)
          client.connect_timeout = @timeout.seconds
          client.read_timeout = @timeout.seconds

          request_headers = headers || HTTP::Headers.new
          request_headers["User-Agent"] = @user_agent unless request_headers["User-Agent"]?

          response = client.get(uri.request_target, headers: request_headers)

          if response.status_code == 429 || response.status_code >= 500
            retries += 1
            raise "HTTP #{response.status_code}" if retries > @max_retries
            sleep((2.0 ** retries).seconds)
            next
          end

          return response
        rescue ex : IO::Error | IO::TimeoutError
          retries += 1
          raise ex if retries > @max_retries
          sleep((2.0 ** retries).seconds)
        end
      end
    end

    def get_many(urls : Array(String), headers : HTTP::Headers? = nil) : Array(HTTP::Client::Response)
      channel = Channel(Tuple(Int32, HTTP::Client::Response)).new(urls.size)

      urls.each_with_index do |url, index|
        spawn do
          response = get(url, headers)
          channel.send({index, response})
        end
      end

      results = Array(HTTP::Client::Response?).new(urls.size, nil)
      urls.size.times do
        index, response = channel.receive
        results[index] = response
      end

      results.map(&.not_nil!)
    end
  end
end
