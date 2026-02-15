require "http/client"

module Scraper
  class RateLimiter
    @mutex : Mutex
    @last_request : Time::Instant?
    @min_interval : Time::Span

    def initialize(rps : Float64 = 1.0)
      @mutex = Mutex.new
      @last_request = nil
      @min_interval = (1.0 / rps).seconds
    end

    def wait
      @mutex.synchronize do
        if last = @last_request
          elapsed = Time.instant - last
          if elapsed < @min_interval
            sleep(@min_interval - elapsed)
          end
        end
        @last_request = Time.instant
      end
    end

    def rps=(value : Float64)
      @mutex.synchronize do
        @min_interval = (1.0 / value).seconds
      end
    end
  end
end
