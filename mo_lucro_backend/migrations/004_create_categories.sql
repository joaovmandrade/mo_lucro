-- Migration 004: Create categories table

CREATE TYPE category_type AS ENUM ('RECEITA', 'DESPESA');

CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type category_type NOT NULL,
    icon VARCHAR(100),
    color VARCHAR(7),
    is_default BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_type ON categories(type);
CREATE INDEX idx_categories_user_id ON categories(user_id);

-- Insert default categories
INSERT INTO categories (name, type, icon, color, is_default) VALUES
    ('Alimentação', 'DESPESA', 'restaurant', '#FF5722', TRUE),
    ('Transporte', 'DESPESA', 'directions_car', '#2196F3', TRUE),
    ('Moradia', 'DESPESA', 'home', '#4CAF50', TRUE),
    ('Saúde', 'DESPESA', 'local_hospital', '#E91E63', TRUE),
    ('Lazer', 'DESPESA', 'sports_esports', '#9C27B0', TRUE),
    ('Estudos', 'DESPESA', 'school', '#FF9800', TRUE),
    ('Contas Fixas', 'DESPESA', 'receipt_long', '#607D8B', TRUE),
    ('Investimentos', 'DESPESA', 'trending_up', '#00BCD4', TRUE),
    ('Outros', 'DESPESA', 'more_horiz', '#795548', TRUE),
    ('Salário', 'RECEITA', 'payments', '#4CAF50', TRUE),
    ('Freelance', 'RECEITA', 'work', '#2196F3', TRUE),
    ('Rendimentos', 'RECEITA', 'account_balance', '#FF9800', TRUE),
    ('Outros', 'RECEITA', 'more_horiz', '#795548', TRUE);
