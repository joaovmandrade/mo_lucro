-- Migration 008: Create benchmarks table

CREATE TYPE benchmark_type AS ENUM ('CDI', 'IPCA', 'POUPANCA', 'SELIC');

CREATE TABLE IF NOT EXISTS benchmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type benchmark_type NOT NULL,
    rate DECIMAL(8, 4) NOT NULL,
    reference_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_benchmarks_type ON benchmarks(type);
CREATE INDEX idx_benchmarks_date ON benchmarks(reference_date);

-- Seed initial benchmark data (March 2025 estimates)
INSERT INTO benchmarks (type, rate, reference_date) VALUES
    ('CDI', 13.25, '2025-03-01'),
    ('IPCA', 4.50, '2025-03-01'),
    ('SELIC', 13.25, '2025-03-01'),
    ('POUPANCA', 7.69, '2025-03-01');
