import 'react-native-url-polyfill/auto';

import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';
import { AppState, Platform } from 'react-native';

/**
 * Porte de lib/services/supabase_config.dart.
 * Os valores continuam embutidos como fallback — a chave é publishable e a
 * proteção real é o RLS definido em supabase/schema.sql — mas podem ser
 * sobrescritos por .env (veja .env.example).
 */
const SUPABASE_URL =
  process.env.EXPO_PUBLIC_SUPABASE_URL ?? 'https://mmtaolgmadsqhlsmmixa.supabase.co';

const SUPABASE_ANON_KEY =
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ??
  'sb_publishable_mAi9DR4lQo5nSJBMjo9iZg_4hmRqU-I';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    // Equivale à persistência automática que o supabase_flutter fazia sozinho.
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    // Só faz sentido em web com magic link; em nativo não há URL de retorno.
    detectSessionInUrl: false,
  },
});

/**
 * Em nativo o refresh automático precisa parar quando o app vai para
 * background, senão o timer dispara sem rede e derruba a sessão.
 */
if (Platform.OS !== 'web') {
  AppState.addEventListener('change', (state) => {
    if (state === 'active') {
      supabase.auth.startAutoRefresh();
    } else {
      supabase.auth.stopAutoRefresh();
    }
  });
}

/** Id do usuário logado. Lança o mesmo erro dos services Dart quando não há sessão. */
export async function requireUserId(): Promise<string> {
  const { data } = await supabase.auth.getUser();
  if (!data.user) throw new Error('Usuário não autenticado');
  return data.user.id;
}
