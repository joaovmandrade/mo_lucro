import { MaterialIcons } from '@expo/vector-icons';
import { useFocusEffect, useRouter } from 'expo-router';
import { useCallback, useState } from 'react';
import { ActivityIndicator, Alert, Pressable, ScrollView, Text, View } from 'react-native';

import { ScreenHeader } from '@/components/form';
import { useAuth } from '@/contexts/AuthContext';
import { useTheme, type ThemeMode } from '@/contexts/ThemeContext';
import { profileService, reportService } from '@/services';
import type { InvestorProfile } from '@/services/profileService';
import { alpha, makeStyles, radius, spacing } from '@/theme';

/**
 * Configurações: ponto de entrada do perfil do investidor (RF-010), da
 * escolha de tema (RNF-005) e da exportação do relatório em PDF (RF-012).
 */

const PROFILE_LABELS: Record<InvestorProfile['profile'], string> = {
  conservative: 'Conservador',
  moderate: 'Moderado',
  aggressive: 'Arrojado',
};

const THEME_OPTIONS: { mode: ThemeMode; label: string; icon: keyof typeof MaterialIcons.glyphMap }[] = [
  { mode: 'light', label: 'Claro', icon: 'light-mode' },
  { mode: 'dark', label: 'Escuro', icon: 'dark-mode' },
  { mode: 'system', label: 'Sistema', icon: 'settings-suggest' },
];

export default function SettingsScreen() {
  const styles = useStyles();
  const { colors, mode, setMode } = useTheme();
  const { session, signOut } = useAuth();
  const router = useRouter();

  const [profile, setProfile] = useState<InvestorProfile | null>(null);
  const [exporting, setExporting] = useState(false);

  useFocusEffect(
    useCallback(() => {
      profileService
        .getProfile()
        .then(setProfile)
        .catch(() => setProfile(null));
    }, []),
  );

  async function exportPdf() {
    setExporting(true);
    try {
      await reportService.exportReport(session?.user.email ?? null);
    } catch (error) {
      Alert.alert(
        'Não foi possível gerar o relatório',
        error instanceof Error ? error.message : String(error),
      );
    } finally {
      setExporting(false);
    }
  }

  function confirmSignOut() {
    Alert.alert('Sair da conta', 'Deseja realmente sair?', [
      { text: 'Cancelar', style: 'cancel' },
      { text: 'Sair', style: 'destructive', onPress: () => signOut() },
    ]);
  }

  return (
    <View style={styles.screen}>
      <ScreenHeader title="Configurações" />

      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.sectionLabel}>Investidor</Text>
        <Pressable
          style={({ pressed }) => [styles.row, pressed && styles.rowPressed]}
          onPress={() => router.push('/profile')}
        >
          <View style={[styles.rowIcon, { backgroundColor: colors.bg3 }]}>
            <MaterialIcons name="psychology" size={20} color={colors.textSecondary} />
          </View>
          <View style={styles.rowBody}>
            <Text style={styles.rowTitle}>Perfil do investidor</Text>
            <Text style={styles.rowSubtitle}>
              {profile
                ? `${PROFILE_LABELS[profile.profile]} · refazer questionário`
                : 'Responda 6 perguntas e descubra seu perfil'}
            </Text>
          </View>
          <MaterialIcons name="chevron-right" size={20} color={colors.textMuted} />
        </Pressable>

        <Text style={styles.sectionLabel}>Aparência</Text>
        <View style={styles.segment}>
          {THEME_OPTIONS.map((option) => {
            const selected = option.mode === mode;
            return (
              <Pressable
                key={option.mode}
                onPress={() => setMode(option.mode)}
                style={[styles.segmentItem, selected && styles.segmentItemSelected]}
                accessibilityRole="radio"
                accessibilityState={{ selected }}
              >
                <MaterialIcons
                  name={option.icon}
                  size={18}
                  color={selected ? colors.primary : colors.textSecondary}
                />
                <Text style={[styles.segmentText, selected && styles.segmentTextSelected]}>
                  {option.label}
                </Text>
              </Pressable>
            );
          })}
        </View>

        <Text style={styles.sectionLabel}>Relatórios</Text>
        <Pressable
          style={({ pressed }) => [styles.row, pressed && styles.rowPressed]}
          onPress={exportPdf}
          disabled={exporting}
        >
          <View style={[styles.rowIcon, { backgroundColor: colors.bg3 }]}>
            <MaterialIcons name="picture-as-pdf" size={20} color={colors.textSecondary} />
          </View>
          <View style={styles.rowBody}>
            <Text style={styles.rowTitle}>Exportar relatório em PDF</Text>
            <Text style={styles.rowSubtitle}>Carteira, evolução, receitas e despesas e metas</Text>
          </View>
          {exporting ? (
            <ActivityIndicator color={colors.primary} />
          ) : (
            <MaterialIcons name="file-download" size={20} color={colors.textMuted} />
          )}
        </Pressable>

        <Text style={styles.sectionLabel}>Conta</Text>
        <View style={styles.row}>
          <View style={[styles.rowIcon, { backgroundColor: colors.bg3 }]}>
            <MaterialIcons name="person" size={20} color={colors.textSecondary} />
          </View>
          <View style={styles.rowBody}>
            <Text style={styles.rowTitle}>E-mail</Text>
            <Text style={styles.rowSubtitle}>{session?.user.email ?? '—'}</Text>
          </View>
        </View>
        <Pressable
          style={({ pressed }) => [styles.row, pressed && styles.rowPressed]}
          onPress={confirmSignOut}
        >
          <View style={[styles.rowIcon, { backgroundColor: alpha(colors.loss, 0.12) }]}>
            <MaterialIcons name="logout" size={20} color={colors.loss} />
          </View>
          <View style={styles.rowBody}>
            <Text style={[styles.rowTitle, { color: colors.loss }]}>Sair</Text>
          </View>
        </Pressable>
      </ScrollView>
    </View>
  );
}

const useStyles = makeStyles((colors) => ({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  content: { padding: spacing.lg, paddingBottom: 40 },

  sectionLabel: {
    marginTop: 20,
    marginBottom: 8,
    color: colors.textMuted,
    fontSize: 13,
    fontWeight: '500',
  },

  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 8,
    padding: spacing.base,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  rowPressed: { backgroundColor: colors.surfacePressed },
  rowIcon: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.md,
  },
  rowBody: { flex: 1 },
  rowTitle: { color: colors.textPrimary, fontSize: 15, fontWeight: '600' },
  rowSubtitle: { marginTop: 2, color: colors.textMuted, fontSize: 12 },

  segment: {
    flexDirection: 'row',
    gap: 8,
    padding: 4,
    backgroundColor: colors.bg3,
    borderRadius: radius.lg,
  },
  segmentItem: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    paddingVertical: 12,
    borderRadius: radius.md,
  },
  segmentItemSelected: {
    backgroundColor: colors.bg2,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.4),
  },
  segmentText: { color: colors.textSecondary, fontSize: 13, fontWeight: '500' },
  segmentTextSelected: { color: colors.primary },
}));
