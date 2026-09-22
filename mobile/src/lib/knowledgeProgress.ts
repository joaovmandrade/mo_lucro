import AsyncStorage from '@react-native-async-storage/async-storage';
import { useFocusEffect } from 'expo-router';
import { useCallback, useState } from 'react';

import { useAuth } from '@/contexts/AuthContext';

/**
 * Progresso das aulas da Base de Conhecimento.
 *
 * Fica só no aparelho (AsyncStorage), separado por usuário para que duas
 * contas no mesmo celular não misturem o que já leram. Se um dia for preciso
 * sincronizar entre dispositivos, basta trocar read/write por uma tabela no
 * Supabase; as telas continuam usando o mesmo hook.
 */

const keyFor = (userId: string) => `knowledge:completed:${userId}`;

async function read(userId: string): Promise<string[]> {
  try {
    const raw = await AsyncStorage.getItem(keyFor(userId));
    const parsed: unknown = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed.filter((id): id is string => typeof id === 'string') : [];
  } catch {
    // Dado corrompido ou storage indisponível: recomeça sem quebrar a tela.
    return [];
  }
}

async function write(userId: string, ids: string[]): Promise<void> {
  try {
    await AsyncStorage.setItem(keyFor(userId), JSON.stringify(ids));
  } catch (error) {
    console.warn('[knowledgeProgress] não foi possível salvar:', error);
  }
}

export function useKnowledgeProgress() {
  const { session } = useAuth();
  const userId = session?.user.id ?? 'anon';

  const [completed, setCompleted] = useState<Set<string>>(new Set());

  // Recarrega sempre que a tela volta ao foco: quem conclui uma aula na tela
  // de leitura vê o progresso atualizado ao voltar para a lista.
  useFocusEffect(
    useCallback(() => {
      let active = true;
      read(userId).then((ids) => {
        if (active) setCompleted(new Set(ids));
      });
      return () => {
        active = false;
      };
    }, [userId]),
  );

  const toggle = useCallback(
    async (lessonId: string) => {
      const next = new Set(completed);
      if (next.has(lessonId)) next.delete(lessonId);
      else next.add(lessonId);

      setCompleted(next);
      await write(userId, [...next]);
    },
    [completed, userId],
  );

  return { completed, toggle };
}