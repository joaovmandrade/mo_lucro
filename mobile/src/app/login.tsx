import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
  type KeyboardTypeOptions,
} from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Snackbar, useSnackbar } from '@/components/Snackbar';
import { useAuth } from '@/contexts/AuthContext';
import { alpha, makeStyles, radius } from '@/theme';
import { motion } from '@/theme/motion';
import { useTheme } from '@/contexts/ThemeContext';

/** Porte de lib/pages/login_page.dart. */

// Azuis escuros exclusivos da tela de login.
const LOGIN_BG = '#1B2A4A';
const LOGIN_CARD = '#243158';
const LOGIN_INPUT = '#1E2D50';
const LOGIN_BORDER = '#344370';
const LOGIN_BLUE = '#2563EB';
const LOGIN_TEXT = '#FFFFFF';
const LOGIN_DIM = 'rgba(255, 255, 255, 0.5)';
const LOGIN_MUTED = 'rgba(255, 255, 255, 0.25)';

const EMAIL_PATTERN = /^[^@]+@[^@]+\.[^@]+/;

export default function LoginScreen() {
  const styles = useStyles();
  const { colors } = useTheme();
  const { signIn, signUp } = useAuth();
  const insets = useSafeAreaInsets();
  const { message, show } = useSnackbar();

  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [obscurePassword, setObscurePassword] = useState(true);
  const [obscureConfirm, setObscureConfirm] = useState(true);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string | null>>({});
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // Mesma entrada do Flutter: fade + deslize de 3% para cima em 600ms,
  // refeita a cada troca entre login e cadastro.
  const entrance = useSharedValue(0);

  useEffect(() => {
    entrance.value = 0;
    entrance.value = withTiming(1, { duration: motion.enter, easing: motion.ease });
  }, [isSignUp, entrance]);

  const entranceStyle = useAnimatedStyle(() => ({
    opacity: entrance.value,
    transform: [{ translateY: (1 - entrance.value) * motion.rise }],
  }));

  function validate(): boolean {
    const next: Record<string, string | null> = {};

    if (email.length === 0) next.email = 'Informe o email';
    else if (!EMAIL_PATTERN.test(email)) next.email = 'Email inválido';

    if (password.length === 0) next.password = 'Informe a senha';
    else if (isSignUp && password.length < 6) next.password = 'Mínimo 6 caracteres';

    if (isSignUp) {
      if (confirm.length === 0) next.confirm = 'Confirme a senha';
      else if (confirm !== password) next.confirm = 'As senhas não coincidem';
    }

    setFieldErrors(next);
    return Object.values(next).every((value) => !value);
  }

  async function submit() {
    if (!validate()) return;

    setLoading(true);
    setError(null);
    try {
      if (isSignUp) {
        await signUp(email, password);
        show('Conta criada');
      } else {
        await signIn(email, password);
      }
    } catch (err) {
      setError(friendlyError(err instanceof Error ? err.message : ''));
    } finally {
      setLoading(false);
    }
  }

  function toggleMode() {
    setIsSignUp((current) => !current);
    setError(null);
    setFieldErrors({});
    setPassword('');
    setConfirm('');
  }

  return (
    <View style={styles.screen}>
      <StatusBar style="light" />

      {/* Círculos decorativos */}

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={[styles.content, { paddingTop: insets.top + 40 }]}
          keyboardShouldPersistTaps="handled"
        >
          <Animated.View style={entranceStyle}>
            <Logo />

            <Text style={styles.title}>{isSignUp ? 'Crie sua conta' : 'Bem-vindo de volta'}</Text>
            <Text style={styles.subtitle}>
              {isSignUp ? 'Comece a investir agora' : 'Acesse sua conta para continuar'}
            </Text>

            <View style={styles.card}>
              <LoginField
                label="E-mail"
                value={email}
                onChangeText={setEmail}
                placeholder="seu@email.com"
                icon="alternate-email"
                keyboardType="email-address"
                error={fieldErrors.email}
              />

              <LoginField
                label="Senha"
                value={password}
                onChangeText={setPassword}
                placeholder="••••••••"
                icon="lock-outline"
                secureTextEntry={obscurePassword}
                onToggleSecure={() => setObscurePassword((current) => !current)}
                secureVisible={!obscurePassword}
                error={fieldErrors.password}
              />

              {isSignUp ? (
                <LoginField
                  label="Confirmar senha"
                  value={confirm}
                  onChangeText={setConfirm}
                  placeholder="••••••••"
                  icon="lock-outline"
                  secureTextEntry={obscureConfirm}
                  onToggleSecure={() => setObscureConfirm((current) => !current)}
                  secureVisible={!obscureConfirm}
                  error={fieldErrors.confirm}
                />
              ) : (
                <Text style={styles.forgotPassword}>Esqueceu a senha?</Text>
              )}

              {error ? (
                <View style={styles.errorBanner}>
                  <MaterialIcons name="warning-amber" size={16} color={colors.loss} />
                  <Text style={styles.errorText}>{error}</Text>
                </View>
              ) : null}

              <Pressable
                onPress={submit}
                disabled={loading}
                style={({ pressed }) => [
                  styles.submitButton,
                  (pressed || loading) && styles.submitButtonDimmed,
                ]}
              >
                {loading ? (
                  <ActivityIndicator color="#FFFFFF" />
                ) : (
                  <>
                    <Text style={styles.submitLabel}>{isSignUp ? 'Cadastrar' : 'Entrar'}</Text>
                    <MaterialIcons name="arrow-forward" size={18} color="#FFFFFF" />
                  </>
                )}
              </Pressable>
            </View>

            <View style={styles.dividerRow}>
              <View style={styles.divider} />
              <Text style={styles.dividerText}>ou</Text>
              <View style={styles.divider} />
            </View>

            {/* Em breve — desabilitado, como no Flutter. */}
            <View style={styles.googleButton}>
              <View style={styles.googleIcon}>
                <Text style={styles.googleIconText}>G</Text>
              </View>
              <Text style={styles.googleLabel}>Continuar com Google</Text>
            </View>

            <Pressable onPress={toggleMode} style={styles.toggle}>
              <Text style={styles.toggleText}>
                {isSignUp ? 'Já tem uma conta? ' : 'Não tem uma conta? '}
                <Text style={styles.toggleAction}>{isSignUp ? 'Entrar' : 'Cadastre-se'}</Text>
              </Text>
            </Pressable>
          </Animated.View>
        </ScrollView>
      </KeyboardAvoidingView>

      <Snackbar message={message} />
    </View>
  );
}

function Logo() {
  const styles = useStyles();
  const { gradients } = useTheme();
  return (
    <View style={styles.logoBlock}>
      <LinearGradient
        colors={gradients.primary.colors}
        start={gradients.primary.start}
        end={gradients.primary.end}
        style={styles.logoBox}
      >
        <MaterialIcons name="bar-chart" size={32} color="#FFFFFF" />
      </LinearGradient>

      <Text style={styles.logoText}>
        Mo<Text style={styles.logoTextAccent}>Lucro</Text>
      </Text>
      <Text style={styles.logoTagline}>Invista. Cresça. Ganhe.</Text>
    </View>
  );
}

function LoginField({
  label,
  value,
  onChangeText,
  placeholder,
  icon,
  keyboardType,
  secureTextEntry,
  onToggleSecure,
  secureVisible,
  error,
}: {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder: string;
  icon: keyof typeof MaterialIcons.glyphMap;
  keyboardType?: KeyboardTypeOptions;
  secureTextEntry?: boolean;
  onToggleSecure?: () => void;
  secureVisible?: boolean;
  error?: string | null;
}) {
  const styles = useStyles();
  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label}</Text>

      <View style={[styles.fieldBox, error ? styles.fieldBoxError : null]}>
        <MaterialIcons name={icon} size={18} color={LOGIN_DIM} />
        <TextInput
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={LOGIN_MUTED}
          keyboardType={keyboardType}
          secureTextEntry={secureTextEntry}
          autoCapitalize="none"
          autoCorrect={false}
          style={styles.fieldInput}
        />
        {onToggleSecure ? (
          <Pressable onPress={onToggleSecure} accessibilityLabel="Mostrar senha">
            <MaterialIcons
              name={secureVisible ? 'visibility-off' : 'visibility'}
              size={20}
              color={LOGIN_DIM}
            />
          </Pressable>
        ) : null}
      </View>

      {error ? <Text style={styles.fieldError}>{error}</Text> : null}
    </View>
  );
}

/** Porte de _friendlyError — traduz as mensagens do Supabase. */
function friendlyError(raw: string): string {
  if (raw.includes('Invalid login credentials') || raw.includes('invalid_credentials')) {
    return 'Email ou senha incorretos';
  }
  if (raw.includes('already registered') || raw.includes('already been registered')) {
    return 'Este email já está cadastrado';
  }
  if (raw.includes('weak_password') || raw.includes('weak password')) {
    return 'Senha muito fraca, use ao menos 6 caracteres';
  }
  if (raw.includes('network') || raw.includes('Failed to fetch')) {
    return 'Sem conexão. Verifique sua internet.';
  }
  return raw.length > 0 ? raw : 'Erro inesperado. Tente novamente.';
}

const useStyles = makeStyles((colors) => ({
  screen: { flex: 1, backgroundColor: LOGIN_BG },
  flex: { flex: 1 },

  content: { paddingHorizontal: 28, paddingBottom: 40 },

  logoBlock: { alignItems: 'center' },
  logoBox: {
    width: 64,
    height: 64,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 18,
  },
  logoText: {
    marginTop: 12,
    color: '#FFFFFF',
    fontSize: 28,
    fontWeight: '600',
  },
  logoTextAccent: { color: LOGIN_BLUE },
  logoTagline: { marginTop: 4, color: LOGIN_DIM, fontSize: 12 },

  title: {
    marginTop: 36,
    color: LOGIN_TEXT,
    fontSize: 24,
    fontWeight: '600',
    textAlign: 'center',
  },
  subtitle: { marginTop: 8, color: LOGIN_DIM, fontSize: 13, textAlign: 'center' },

  card: {
    marginTop: 36,
    padding: 24,
    backgroundColor: LOGIN_CARD,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: LOGIN_BORDER,
  },

  field: { marginBottom: 20 },
  fieldLabel: {
    color: LOGIN_DIM,
    fontSize: 13,
    fontWeight: '500',
  },
  fieldBox: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginTop: 8,
    paddingHorizontal: 20,
    backgroundColor: LOGIN_INPUT,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: LOGIN_BORDER,
  },
  fieldBoxError: { borderColor: colors.loss },
  fieldInput: { flex: 1, paddingVertical: 16, color: LOGIN_TEXT, fontSize: 15 },
  fieldError: { marginTop: 8, color: colors.loss, fontSize: 12 },

  forgotPassword: {
    alignSelf: 'flex-end',
    marginTop: -8,
    marginBottom: 8,
    color: LOGIN_BLUE,
    fontSize: 12,
    fontWeight: '500',
  },

  errorBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 20,
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: alpha(colors.loss, 0.1),
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: alpha(colors.loss, 0.3),
  },
  errorText: { flex: 1, color: colors.loss, fontSize: 13 },

  submitButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    height: 52,
    backgroundColor: LOGIN_BLUE,
    borderRadius: radius.lg,
  },
  submitButtonDimmed: { opacity: 0.8 },
  submitLabel: { color: '#FFFFFF', fontSize: 15, fontWeight: '600' },

  dividerRow: { flexDirection: 'row', alignItems: 'center', marginTop: 20 },
  divider: { flex: 1, height: 1, backgroundColor: LOGIN_BORDER },
  dividerText: { marginHorizontal: 12, color: LOGIN_MUTED, fontSize: 12 },

  googleButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    height: 52,
    marginTop: 16,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: LOGIN_BORDER,
    opacity: 0.6,
  },
  googleIcon: {
    width: 20,
    height: 20,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: LOGIN_BORDER,
    borderRadius: 10,
  },
  googleIconText: { color: LOGIN_DIM, fontSize: 11, fontWeight: '500' },
  googleLabel: { color: LOGIN_DIM, fontSize: 14 },

  toggle: { marginTop: 28, alignItems: 'center' },
  toggleText: { color: LOGIN_MUTED, fontSize: 13, textAlign: 'center' },
  toggleAction: { color: LOGIN_BLUE, fontWeight: '600' },
}));
