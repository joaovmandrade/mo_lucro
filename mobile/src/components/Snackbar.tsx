import { useCallback, useRef, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { colors, radius } from '@/theme';

/**
 * Equivalente ao ScaffoldMessenger.showSnackBar do Flutter, com o visual do
 * snackBarTheme: fundo #1F2937, texto branco 14, flutuante e arredondado.
 */

type Message = { text: string; isError: boolean };

export function useSnackbar() {
  const [message, setMessage] = useState<Message | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const show = useCallback((text: string, options?: { isError?: boolean }) => {
    if (timer.current) clearTimeout(timer.current);
    setMessage({ text, isError: options?.isError ?? false });
    timer.current = setTimeout(() => setMessage(null), 3000);
  }, []);

  return { message, show };
}

export function Snackbar({ message }: { message: { text: string; isError: boolean } | null }) {
  if (!message) return null;

  return (
    <View style={styles.wrapper} pointerEvents="none">
      <View style={[styles.snackbar, message.isError && styles.snackbarError]}>
        <Text style={styles.text}>{message.text}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  snackbar: {
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: '#1F2937',
    borderRadius: radius.md,
  },
  snackbarError: { backgroundColor: colors.loss },
  text: { color: '#FFFFFF', fontSize: 14 },
});
