-- Migration 007: Create investor profiles table

CREATE TYPE investor_profile_type AS ENUM ('CONSERVADOR', 'MODERADO', 'ARROJADO');

CREATE TABLE IF NOT EXISTS investor_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    answers JSONB NOT NULL DEFAULT '[]',
    profile_type investor_profile_type NOT NULL,
    score INTEGER NOT NULL DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

CREATE INDEX idx_investor_profiles_user_id ON investor_profiles(user_id);
