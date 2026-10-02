# Changelog

All notable changes to this project will be documented in this file.

## [1.0.2] - 2024-01-XX

### Fixed
- **DELETE endpoint**: Now performs case-insensitive lookups to prevent false negatives when deleting URLs with different casing (e.g., `DELETE /I7VGG` works even if the stored code is lowercase `i7vgg`).

## [1.0.1] - 2024-01-XX

### Changed
- **POST /api/v1/shorten**: Stores short codes in lowercase only to ensure consistent lookups.
- **Duplicate detection**: Performs case-insensitive comparisons on `original_url` (e.g., `https://Test.com` and `https://test.com` are treated as duplicates).

## [1.0.0] - Initial Release

### Added
- URL shortening API with PostgreSQL database
- CRUD operations for short URLs:
  - `POST /api/v1/shorten` - Create a shortened URL
  - `GET /api/v1/{short_code}` - Retrieve URL info
  - `DELETE /api/v1/{short_code}` - Delete a shortened URL
- Health check endpoint at `/health`
- OpenAPI documentation at `/docs`
