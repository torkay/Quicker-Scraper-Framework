# Generic Scraper Framework

> 10x faster web scraping. Build in minutes. Deploy as single binary.

[![Crystal](https://img.shields.io/badge/crystal-%3E%3D1.19.1-black?logo=crystal)](https://crystal-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/torkay/generic-scraper/actions/workflows/ci.yml/badge.svg)](https://github.com/torkay/generic-scraper/actions)

A high-performance, plugin-based web scraping framework written in Crystal. Domain-agnostic by design — scrape vehicles, real estate, jobs, or anything else by writing a simple vendor plugin.

## Features

- **Plugin-based vendors** — Add a new data source in <100 lines of code
- **Concurrent green threads** — Leverage Crystal fibers for massive parallelism
- **Config-driven** — YAML configuration for vendors, rate limits, and output
- **Single binary** — Compile once, deploy anywhere with zero dependencies
- **Domain-agnostic** — Not tied to any industry; scrape anything structured
- **Built-in rate limiting** — Respectful scraping with configurable delays
- **Self-healing extraction** — CSS + XPath selectors with fallback chains

## Quick Start

### Install

```bash
# Clone the repo
git clone https://github.com/torkay/generic-scraper.git
cd generic-scraper

# Install dependencies
shards install

# Build the binary
crystal build src/main.cr -o bin/scraper --release
```

### Configure a vendor

```yaml
# config/vendors.yaml
vendors:
  example_site:
    enabled: true
    base_url: "https://example.com/listings"
    rate_limit:
      requests_per_second: 2
    selectors:
      listing: ".listing-card"
      title: "h2.title"
      price: ".price"
      link: "a@href"
```

### Run

```bash
# Scrape with a vendor
./bin/scraper scrape --vendor example_site --limit 50

# Output as JSON
./bin/scraper scrape --vendor example_site --output results.json

# Output as CSV
./bin/scraper scrape --vendor example_site --output results.csv
```

## Architecture

```
                    ┌─────────────┐
                    │  CLI / App  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Config    │  ← YAML vendor definitions
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Pipeline   │  ← Orchestrates the scrape
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
       ┌──────▼──────┐ ┌──▼───┐ ┌──────▼──────┐
       │ HttpClient  │ │Vendor│ │ RateLimiter │
       │  (fetch)    │ │Plugin│ │  (throttle) │
       └──────┬──────┘ └──┬───┘ └─────────────┘
              │            │
       ┌──────▼────────────▼──────┐
       │      Normalizer          │
       └──────────┬───────────────┘
                  │
       ┌──────────▼───────────────┐
       │   Output Driver          │
       │  (JSON / CSV / stdout)   │
       └──────────────────────────┘
```

## Writing a Custom Vendor

Create a new file in `src/plugins/`:

```crystal
# src/plugins/my_vendor.cr
require "../scraper/vendor_adapter"

class MyVendor < Scraper::VendorAdapter
  def vendor_name : String
    "my_vendor"
  end

  def build_url(query : String, page : Int32) : String
    "https://example.com/search?q=#{URI.encode_www_form(query)}&page=#{page}"
  end

  def extract_listings(doc : Lexbor::Parser) : Array(RawListing)
    doc.css(".listing-card").map do |node|
      RawListing.new(
        title: node.css("h2").first.inner_text.strip,
        price: node.css(".price").first.inner_text.strip,
        url: node.css("a").first["href"]? || "",
        source: vendor_name,
        raw_fields: {} of String => String
      )
    end.to_a
  end
end
```

Register it in your config and you're done. That's it — under 30 lines.

## Example Configs

See [`config/examples/`](config/examples/) for ready-to-use configurations:

- [`vehicles.yaml`](config/examples/vehicles.yaml) — Car listing aggregation
- [`real_estate.yaml`](config/examples/real_estate.yaml) — Property listings
- [`jobs.yaml`](config/examples/jobs.yaml) — Job board scraping

## Performance

| Metric | Crystal (this) | Python (Scrapy) | Node (Puppeteer) |
|--------|:--------------:|:---------------:|:----------------:|
| Startup time | ~5ms | ~500ms | ~300ms |
| Memory (1k listings) | ~15 MB | ~120 MB | ~200 MB |
| Throughput (pages/sec) | ~200 | ~30 | ~20 |
| Binary size | ~5 MB | N/A (runtime) | N/A (runtime) |
| Dependencies | 0 (single binary) | pip + venv | node_modules |

*Benchmarks on M1 MacBook Pro, 10 concurrent fibers, local test server.*

## Development

```bash
# Run tests
crystal spec

# Run linter
crystal tool ameba

# Build debug binary
crystal build src/main.cr -o bin/scraper
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding vendors, submitting PRs, and coding style.

## License

[MIT](LICENSE) - see LICENSE file for details.
