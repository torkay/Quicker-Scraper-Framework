require "../spec_helper"

describe Scraper::RateLimiter do
  it "creates with default rps" do
    limiter = Scraper::RateLimiter.new
    limiter.should be_a(Scraper::RateLimiter)
  end

  it "creates with custom rps" do
    limiter = Scraper::RateLimiter.new(rps: 5.0)
    limiter.should be_a(Scraper::RateLimiter)
  end

  it "enforces delay between requests" do
    limiter = Scraper::RateLimiter.new(rps: 10.0)

    start = Time.instant
    limiter.wait
    limiter.wait
    elapsed = (Time.instant - start).total_seconds

    elapsed.should be >= 0.08
  end

  it "allows updating rps" do
    limiter = Scraper::RateLimiter.new(rps: 1.0)
    limiter.rps = 100.0

    start = Time.instant
    limiter.wait
    limiter.wait
    elapsed = (Time.instant - start).total_seconds

    elapsed.should be < 0.5
  end
end
