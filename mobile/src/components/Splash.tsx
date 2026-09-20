import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';

import { colors, gradients, radius } from '@/theme';

/** Porte de _SplashScreen em main.dart. */
export function Splash() {
  return (
    <View style={styles.container}>
      <LinearGradient
        colors={gradients.primary.colors}
        start={gradients.primary.start}
        end={gradients.primary.end}
        style={styles.logo}
      >
        <Ionicons name="trending-up" size={36} color="#FFFFFF" />
      </LinearGradient>

      <Text style={styles.title}>Mo Lucro</Text>

      <ActivityIndicator size="small" color={colors.primary} style={styles.spinner} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg0,
  },
  logo: {
    padding: 18,
    borderRadius: radius.xl,
  },
  title: {
    marginTop: 20,
    color: colors.textPrimary,
    fontSize: 26,
    fontWeight: '900',
    letterSpacing: -0.5,
  },
  spinner: {
    marginTop: 32,
  },
});
