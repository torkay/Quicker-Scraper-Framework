# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-16

### Added

- Core type system: `RawListing`, `NormalizedListing`, `ScrapeJob`, `ScrapeResult`
- Pipeline orchestrator with concurrent fiber execution
- `VendorAdapter` base class for plugin-based vendor support
- `HttpClient` with connection pooling and retry logic
- `RateLimiter` with per-vendor configurable delays
- Normalizer for cleaning and standardizing extracted data
- Output drivers: JSON and CSV
- CLI with `scrape` command and flag parsing
- YAML-based vendor configuration system
- Example configs for vehicles, real estate, and jobs
- Dockerfile for single-binary deployment
