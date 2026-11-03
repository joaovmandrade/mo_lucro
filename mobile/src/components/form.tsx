import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { forwardRef, type ReactNode } from 'react';
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
  type StyleProp,
  type TextInputProps,
  type TextStyle,
  type ViewStyle,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { makeStyles, radius } from '@/theme';
import { useTheme } from '@/contexts/ThemeContext';
import { goBack } from '@/lib/navigation';

/**
 * Primitivas de formulário equivalentes ao que o ThemeData do Flutter aplicava
 * automaticamente (inputDecorationTheme, elevatedButtonTheme, appBarTheme).
 * No RN não há cascata de tema, então elas precisam ser componentes.
 */

/** Equivalente ao AppBar com botão de voltar das telas de cadastro. */
export function ScreenHeader({ title, onBack }: { title: string; onBack?: () => void }) {
  const styles = useStyles();
  const { colors } = useTheme();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.header, { paddingTop: insets.top }]}>
      <Pressable
        onPress={onBack ?? (() => goBack(router))}
        style={styles.backButton}
        accessibilityLabel="Voltar"
      >
        <MaterialIcons name="arrow-back-ios-new" size={18} color={colors.textSecondary} />
      </Pressable>
      <Text style={styles.headerTitle}>{title}</Text>
    </View>
  );
}

/** Porte do _Label repetido nas páginas de cadastro. */
export function FieldLabel({ children }: { children: ReactNode }) {
  const styles = useStyles();
  return <Text style={styles.label}>{children}</Text>;
}

// `style` aqui é do contêiner (a View externa), não do TextInput — por isso é
// trocado por ViewStyle em vez de herdar o TextStyle de TextInputProps.
type InputProps = Omit<TextInputProps, 'style'> & {
  style?: StyleProp<ViewStyle>;
  /** Texto fixo antes do valor, como o prefixText do Flutter. */
  prefix?: string;
  prefixStyle?: TextStyle;
  /** Ícone à esquerda, como o prefixIcon. */
  icon?: keyof typeof MaterialIcons.glyphMap;
  error?: string | null;
  inputStyle?: TextStyle;
};

export const Input = forwardRef<TextInput, InputProps>(function Input(
  { prefix, prefixStyle, icon, error, inputStyle, style, ...props },
  ref,
) {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <View>
      <View style={[styles.inputContainer, error ? styles.inputContainerError : null, style]}>
        {icon ? (
          <MaterialIcons name={icon} size={20} color={colors.textMuted} style={styles.inputIcon} />
        ) : null}
        {prefix ? <Text style={[styles.prefix, prefixStyle]}>{prefix}</Text> : null}
        <TextInput
          ref={ref}
          placeholderTextColor={colors.textMuted}
          style={[styles.input, inputStyle]}
          {...props}
        />
      </View>
      {error ? <Text style={styles.errorText}>{error}</Text> : null}
    </View>
  );
});

/** Porte do ElevatedButton com o estilo de elevatedButtonTheme. */
export function PrimaryButton({
  label,
  onPress,
  loading = false,
  disabled = false,
}: {
  label: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
}) {
  const styles = useStyles();
  const inactive = loading || disabled;

  return (
    <Pressable
      onPress={onPress}
      disabled={inactive}
      style={({ pressed }) => [
        styles.primaryButton,
        pressed && !inactive && styles.primaryButtonPressed,
        inactive && styles.primaryButtonDisabled,
      ]}
    >
      {loading ? (
        <ActivityIndicator color="#FFFFFF" />
      ) : (
        <Text style={styles.primaryButtonLabel}>{label}</Text>
      )}
    </Pressable>
  );
}

const useStyles = makeStyles((colors) => ({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingBottom: 8,
    backgroundColor: colors.bg0,
  },
  backButton: { padding: 12 },
  headerTitle: {
    marginLeft: 4,
    color: colors.textPrimary,
    fontSize: 18,
    fontWeight: '600',
  },

  label: {
    color: colors.textSecondary,
    fontSize: 12,
    fontWeight: '500',
  },

  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    backgroundColor: colors.bg3,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  inputContainerError: { borderColor: colors.loss },
  inputIcon: { marginRight: 8 },
  prefix: { color: colors.textSecondary, fontSize: 14 },
  input: {
    flex: 1,
    paddingVertical: 16,
    color: colors.textPrimary,
    fontSize: 14,
  },
  errorText: { marginTop: 8, color: colors.loss, fontSize: 12 },

  primaryButton: {
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.primary,
    borderRadius: radius.lg,
  },
  primaryButtonPressed: { backgroundColor: colors.primaryDim },
  primaryButtonDisabled: { opacity: 0.6 },
  primaryButtonLabel: { color: '#FFFFFF', fontSize: 15, fontWeight: '600' },
}));
