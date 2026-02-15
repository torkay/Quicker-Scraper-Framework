require "../spec_helper"

describe Scraper::RawListing do
  it "creates with url and default fields" do
    listing = Scraper::RawListing.new("https://example.com/1")
    listing.url.should eq "https://example.com/1"
    listing.title.should be_nil
    listing.fields.should be_empty
    listing.extracted_at.should be_a(Time)
  end

  it "creates with url and title" do
    listing = Scraper::RawListing.new("https://example.com/1", title: "Test Item")
    listing.title.should eq "Test Item"
  end

  it "allows setting fields" do
    listing = Scraper::RawListing.new("https://example.com/1")
    listing.fields["price"] = "1000"
    listing.fields["year"] = 2020
    listing.fields["price"].should eq "1000"
    listing.fields["year"].should eq 2020
  end
end

describe Scraper::NormalizedListing do
  it "creates with id and source" do
    listing = Scraper::NormalizedListing.new("abc123", "test_vendor")
    listing.id.should eq "abc123"
    listing.source.should eq "test_vendor"
    listing.schema_version.should eq "1.0"
    listing.hydrated.should be_false
    listing.fields.should be_empty
  end

  it "serializes to JSON" do
    listing = Scraper::NormalizedListing.new("abc123", "test_vendor")
    listing.fields["title"] = JSON::Any.new("Test")
    json = listing.to_json
    json.should contain "abc123"
    json.should contain "test_vendor"
    json.should contain "Test"
  end
end

describe Scraper::ScrapeJob do
  it "creates with vendor and defaults" do
    job = Scraper::ScrapeJob.new("grays")
    job.vendor.should eq "grays"
    job.limit.should eq 100
    job.pages.should eq 10
    job.priority.should eq "normal"
    job.start_page.should eq 1
  end
end

describe Scraper::ScrapeResult do
  it "reports success when listings exist and no errors" do
    job = Scraper::ScrapeJob.new("test")
    result = Scraper::ScrapeResult.new(job)
    result.success?.should be_false

    result.listings_raw << Scraper::RawListing.new("https://example.com")
    result.success?.should be_true
  end

  it "reports failure when errors present" do
    job = Scraper::ScrapeJob.new("test")
    result = Scraper::ScrapeResult.new(job)
    result.listings_raw << Scraper::RawListing.new("https://example.com")
    result.errors << "something failed"
    result.success?.should be_false
  end
end
