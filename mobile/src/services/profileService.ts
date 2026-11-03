import AsyncStorage from '@react-native-async-storage/async-storage';

import { requireUserId, supabase } from '@/lib/supabase';

/**
 * Perfil do investidor (RF-010 / RNE-006): um resultado por usuário.
 *
 * A fonte principal é a tabela `user_profiles` (UNIQUE em user_id, por isso o
 * upsert substitui o perfil anterior em vez de duplicar). Uma cópia fica no
 * AsyncStorage para que o perfil continue disponível se a tabela ainda não
 * existir no banco (veja supabase/migrations) ou se a rede falhar.
 */

export type InvestorProfileType = 'conservative' | 'moderate' | 'aggressive';

export type InvestorProfile = {
  profile: InvestorProfileType;
  answers: number[];
  score: number;
  updatedAt: string;
  /** false quando só foi possível salvar no aparelho. */
  synced: boolean;
};

const PROFILE_TYPES: InvestorProfileType[] = ['conservative', 'moderate', 'aggressive'];

const localKey = (userId: string) => `investor-profile:${userId}`;

/** Cada resposta vale 0, 1 ou 2 — a soma (0 a 12) define o perfil. */
export function classify(answers: number[]): { profile: InvestorProfileType; score: number } {
  const score = answers.reduce((sum, answer) => sum + answer, 0);
  if (score <= 4) return { profile: 'conservative', score };
  if (score <= 8) return { profile: 'moderate', score };
  return { profile: 'aggressive', score };
}

function isProfileType(value: unknown): value is InvestorProfileType {
  return typeof value === 'string' && (PROFILE_TYPES as string[]).includes(value);
}

function parseAnswers(value: unknown): number[] {
  return Array.isArray(value) ? value.filter((n): n is number => typeof n === 'number') : [];
}

async function readLocal(userId: string): Promise<InvestorProfile | null> {
  try {
    const raw = await AsyncStorage.getItem(localKey(userId));
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    return isProfileType(parsed?.profile) ? (parsed as InvestorProfile) : null;
  } catch {
    return null;
  }
}

async function writeLocal(userId: string, profile: InvestorProfile): Promise<void> {
  try {
    await AsyncStorage.setItem(localKey(userId), JSON.stringify(profile));
  } catch (error) {
    console.warn('[profileService] não foi possível salvar no aparelho:', error);
  }
}

export async function getProfile(): Promise<InvestorProfile | null> {
  const userId = await requireUserId();

  const { data, error } = await supabase
    .from('user_profiles')
    .select('investor_profile, quiz_answers, updated_at')
    .eq('user_id', userId)
    .maybeSingle();

  if (!error && data && isProfileType(data.investor_profile)) {
    const answers = parseAnswers(data.quiz_answers);
    const remote: InvestorProfile = {
      profile: data.investor_profile,
      answers,
      score: classify(answers).score,
      updatedAt: data.updated_at,
      synced: true,
    };
    await writeLocal(userId, remote);
    return remote;
  }

  if (error) console.warn('[profileService] leitura remota falhou:', error.message);
  return readLocal(userId);
}

/** Salva (ou substitui) o perfil. Retorna o perfil com `synced` indicando onde ficou. */
export async function saveProfile(answers: number[]): Promise<InvestorProfile> {
  const userId = await requireUserId();
  const { profile, score } = classify(answers);
  const updatedAt = new Date().toISOString();

  const { error } = await supabase.from('user_profiles').upsert(
    {
      user_id: userId,
      investor_profile: profile,
      quiz_answers: answers,
      updated_at: updatedAt,
    },
    { onConflict: 'user_id' },
  );

  if (error) console.warn('[profileService] gravação remota falhou:', error.message);

  const saved: InvestorProfile = { profile, answers, score, updatedAt, synced: !error };
  await writeLocal(userId, saved);
  return saved;
}
