# Contributing to Generic Scraper Framework

Thanks for your interest in contributing! This guide covers how to add vendors, submit changes, and follow project conventions.

## Adding a New Vendor

The fastest way to contribute is adding support for a new data source. Each vendor is a single file under `src/plugins/` that implements `VendorAdapter`.

### Steps

1. Create `src/plugins/your_vendor.cr`
2. Inherit from `Scraper::VendorAdapter`
3. Implement the required methods:
   - `vendor_name` — unique string identifier
   - `build_url(query, page)` — construct the search URL
   - `extract_listings(doc)` — parse HTML into `RawListing` structs
4. Add a config entry in `config/vendors.yaml`
5. Add a spec in `spec/plugins/your_vendor_spec.cr`

A vendor should be **under 100 lines of code**. If yours is significantly larger, consider whether some logic belongs in a shared utility.

### Vendor Checklist

- [ ] Respects `rate_limit` from config
- [ ] Handles missing/malformed fields gracefully
- [ ] Includes at least one spec with fixture HTML
- [ ] Tested with `crystal spec spec/plugins/your_vendor_spec.cr`

## Pull Request Guidelines

1. **Fork and branch** — Work on a feature branch, not `main`
2. **One concern per PR** — Keep changes focused
3. **Write specs** — New code needs tests. Bug fixes need regression tests.
4. **Run the full suite** before submitting:
   ```bash
   crystal spec
   crystal tool ameba
   ```
5. **Describe your changes** — PR description should explain what and why

## Crystal Style Guide

Follow the [official Crystal style guide](https://crystal-lang.org/reference/conventions/coding_style.html):

- **2-space indentation**, no tabs
- **snake_case** for methods and variables
- **PascalCase** for types and modules
- **SCREAMING_SNAKE_CASE** for constants
- Use `property` over manual getter/setter when possible
- Prefer `do...end` for multi-line blocks, `{ }` for single-line

## Project Structure

```
src/
  cli/          — Command-line interface and argument parsing
  extraction/   — HTML parsing and selector logic
  http/         — HTTP client and rate limiting
  outputs/      — Output drivers (JSON, CSV)
  plugins/      — Vendor implementations (add yours here)
  scraper/      — Core types, pipeline, normalizer
spec/
  fixtures/     — HTML fixtures for vendor specs
  plugins/      — Vendor-specific specs
config/
  examples/     — Example configs for different domains
```

## Running Tests

```bash
# Full suite
crystal spec

# Single file
crystal spec spec/plugins/your_vendor_spec.cr

# With verbose output
crystal spec --verbose
```

## Questions?

Open an issue or start a discussion. We're happy to help you get your first vendor merged.
