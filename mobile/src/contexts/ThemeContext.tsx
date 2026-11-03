import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { Appearance, useColorScheme } from 'react-native';

import {
  darkColors,
  darkGradients,
  lightColors,
  lightGradients,
  type Gradients,
  type Palette,
} from '@/theme/colors';

/**
 * Tema claro/escuro (RNF-005). A escolha do usuário fica no AsyncStorage e é
 * aplicada sem reiniciar o app: as telas leem a paleta por useTheme() e os
 * estilos são recriados por makeStyles quando a paleta muda.
 */

export type ThemeMode = 'light' | 'dark' | 'system';

type ThemeContextValue = {
  mode: ThemeMode;
  setMode: (mode: ThemeMode) => void;
  isDark: boolean;
  colors: Palette;
  gradients: Gradients;
};

const STORAGE_KEY = 'theme:mode';
const MODES: ThemeMode[] = ['light', 'dark', 'system'];

const ThemeContext = createContext<ThemeContextValue | null>(null);

export function ThemeProvider({ children }: { children: ReactNode }) {
  // Padrão claro: é o visual original do app.
  const [mode, setModeState] = useState<ThemeMode>('light');
  const [systemScheme, setSystemScheme] = useState(() => Appearance.getColorScheme());
  const scheme = useColorScheme();

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY)
      .then((saved) => {
        if (saved && (MODES as string[]).includes(saved)) setModeState(saved as ThemeMode);
      })
      .catch(() => {});
  }, []);

  // Enquanto o modo é "system", acompanha o tema do aparelho.
  useEffect(() => {
    if (mode === 'system') setSystemScheme(scheme);
  }, [mode, scheme]);

  // Componentes nativos (seletor de data, alertas, teclado) seguem o tema do app.
  useEffect(() => {
    Appearance.setColorScheme(mode === 'system' ? 'unspecified' : mode);
  }, [mode]);

  const isDark = mode === 'dark' || (mode === 'system' && systemScheme === 'dark');

  const value = useMemo<ThemeContextValue>(
    () => ({
      mode,
      setMode: (next) => {
        setModeState(next);
        AsyncStorage.setItem(STORAGE_KEY, next).catch(() => {});
      },
      isDark,
      colors: isDark ? darkColors : lightColors,
      gradients: isDark ? darkGradients : lightGradients,
    }),
    [mode, isDark],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): ThemeContextValue {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme precisa estar dentro de <ThemeProvider>');
  return context;
}
