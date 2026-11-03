import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';

import { makeStyles, radius } from '@/theme';
import { useTheme } from '@/contexts/ThemeContext';

/** Porte de _SplashScreen em main.dart. */
export function Splash() {
  const styles = useStyles();
  const { colors, gradients } = useTheme();
  return (
    <View style={styles.container}>
      <LinearGradient
        colors={gradients.primary.colors}
        start={gradients.primary.start}
        end={gradients.primary.end}
        style={styles.logo}
      >
        <MaterialIcons name="trending-up" size={36} color="#FFFFFF" />
      </LinearGradient>

      <Text style={styles.title}>Mo Lucro</Text>

      <ActivityIndicator size="small" color={colors.primary} style={styles.spinner} />
    </View>
  );
}

const useStyles = makeStyles((colors) => ({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg0,
  },
  logo: {
    padding: 20,
    borderRadius: radius.xl,
  },
  title: {
    marginTop: 20,
    color: colors.textPrimary,
    fontSize: 26,
    fontWeight: '600',
  },
  spinner: {
    marginTop: 32,
  },
}));
