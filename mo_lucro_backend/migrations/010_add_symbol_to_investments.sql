-- Migration 010: Add symbol to investments

ALTER TABLE investments
ADD COLUMN symbol VARCHAR(50);

CREATE INDEX idx_investments_symbol ON investments(symbol);
