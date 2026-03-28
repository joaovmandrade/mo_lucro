-- Migration 011: Create market_cache table

CREATE TABLE IF NOT EXISTS market_cache (
    key VARCHAR(255) PRIMARY KEY,
    value JSONB NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_market_cache_expires_at ON market_cache(expires_at);
