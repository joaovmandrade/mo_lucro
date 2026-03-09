-- Migration 006: Create goals table

CREATE TYPE goal_type AS ENUM (
    'RESERVA_EMERGENCIA', 'VIAGEM', 'CARRO', 'CASA_PROPRIA',
    'APOSENTADORIA', 'ESTUDOS', 'PERSONALIZADA'
);

CREATE TYPE goal_priority AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');

CREATE TABLE IF NOT EXISTS goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type goal_type NOT NULL DEFAULT 'PERSONALIZADA',
    target_amount DECIMAL(15, 2) NOT NULL,
    current_amount DECIMAL(15, 2) NOT NULL DEFAULT 0,
    deadline DATE,
    priority goal_priority DEFAULT 'MEDIA',
    strategy TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_type ON goals(type);
CREATE INDEX idx_goals_completed ON goals(is_completed);
