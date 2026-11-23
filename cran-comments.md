## Update to 1.0.7

This update adds explicit download failures and source-revision metadata,
absolute-instant time-zone conversion, expanded REDCap checkbox support, and
additional REDCap date/datetime validation codes. The DESCRIPTION participant
count is corrected. Network examples are interactive; automated tests use local
fixtures and mocks.

## Test environment

* Local macOS 27.0.1, Apple Silicon, R 4.6.1 (2026-06-24).

## R CMD check results

0 errors | 0 warnings | 0 notes

The built source tarball was checked with --as-cran, all suggested packages,
CRAN incoming checks, and PDF/HTML manual generation enabled. All 76 test
expectations passed without warnings or skips.

## Additional checks

* Documentation regenerated with roxygen2 8.0.0; README regenerated from source.
* Sequential URL checks and Air formatting checks passed. The EURAMET homepage
  returned HTTP 500 during concurrent URL checks; direct HEAD/GET requests and
  the complete sequential URL check succeeded.
* Live sleep-diary downloads succeeded for all nine sites, and a full-commit-SHA
  download succeeded. R assertions verified row preservation and unchanged
  POSIXct instants after flattening in instant mode.
* The current CRAN version (1.0.6) has OK results on all listed check platforms.
* CRAN has no reverse Depends, Imports, LinkingTo, or Suggests dependencies as
  checked on 2026-11-23.
