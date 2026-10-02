-- Database initialization script for PostgreSQL
DROP TABLE IF EXISTS short_urls CASCADE;

CREATE TABLE short_urls (
    id SERIAL PRIMARY KEY,
    original_url TEXT NOT NULL,
    short_code VARCHAR(7) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE short_urls IS 'Stores shortened URLs with auto-generated 7-character codes';
COMMENT ON COLUMN short_urls.id IS 'Auto-incrementing primary key';
COMMENT ON COLUMN short_urls.original_url IS 'Full original URL to redirect to (max 2048 characters)';
COMMENT ON COLUMN short_urls.short_code IS 'Auto-generated unique code (a-zA-Z0-9, 7 chars)';
COMMENT ON COLUMN short_urls.created_at IS 'Timestamp when the short URL was created';

-- Add index for case-insensitive lookups
CREATE INDEX idx_short_code_lower ON short_urls(lower(short_code));
