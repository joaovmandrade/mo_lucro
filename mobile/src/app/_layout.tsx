import {
  Inter_400Regular,
  Inter_500Medium,
  Inter_600SemiBold,
  Inter_700Bold,
  useFonts,
} from '@expo-google-fonts/inter';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { Splash } from '@/components/Splash';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';
import { colors } from '@/theme';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Inter_700Bold,
  });

  useEffect(() => {
    if (fontsLoaded) SplashScreen.hideAsync();
  }, [fontsLoaded]);

  if (!fontsLoaded) return null;

  return (
    // Necessário para o swipe-to-delete da lista de transações.
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        {/* O app é light-only, como o AppTheme do Flutter: ícones escuros na status bar. */}
        <StatusBar style="dark" />
        <AuthProvider>
          <RootNavigator />
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

/**
 * Equivalente ao _AuthGate de main.dart: enquanto a sessão persistida não foi
 * lida mostra o splash; depois libera só as rotas permitidas pela sessão.
 */
function RootNavigator() {
  const { session, loading } = useAuth();

  if (loading) return <Splash />;

  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.bg0 },
      }}
    >
      <Stack.Protected guard={!!session}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="operations/new" />
        <Stack.Screen name="transactions/new" />
        <Stack.Screen name="goals/new" />
        <Stack.Screen name="knowledge/[id]" />
        <Stack.Screen name="simulator" />
        <Stack.Screen name="news" />
        <Stack.Screen name="profile" />
      </Stack.Protected>

      <Stack.Protected guard={!session}>
        <Stack.Screen name="login" />
      </Stack.Protected>
    </Stack>
  );
}
