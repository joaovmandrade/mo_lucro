-- Migration 002: Create investments table

CREATE TYPE investment_type AS ENUM (
    'CDB', 'TESOURO_DIRETO', 'POUPANCA', 'ACOES',
    'FUNDOS_IMOBILIARIOS', 'FUNDOS', 'CRIPTO', 'CAIXA', 'OUTROS'
);

CREATE TYPE indexer_type AS ENUM (
    'CDI', 'IPCA', 'PREFIXADO', 'SELIC', 'IGPM', 'DOLAR', 'NENHUM'
);

CREATE TYPE liquidity_type AS ENUM (
    'DIARIA', 'NO_VENCIMENTO', 'D1', 'D2', 'D30', 'VARIAVEL'
);

CREATE TABLE IF NOT EXISTS investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type investment_type NOT NULL,
    initial_amount DECIMAL(15, 2) NOT NULL DEFAULT 0,
    current_amount DECIMAL(15, 2) NOT NULL DEFAULT 0,
    investment_date DATE NOT NULL,
    maturity_date DATE,
    contracted_rate DECIMAL(8, 4),
    indexer indexer_type DEFAULT 'NENHUM',
    institution VARCHAR(255),
    liquidity liquidity_type DEFAULT 'DIARIA',
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_investments_user_id ON investments(user_id);
CREATE INDEX idx_investments_type ON investments(type);
CREATE INDEX idx_investments_maturity ON investments(maturity_date);
CREATE INDEX idx_investments_active ON investments(is_active);
