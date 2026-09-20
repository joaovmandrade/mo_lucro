import { MaterialIcons } from '@expo/vector-icons';
import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import Animated, { withTiming, type EntryExitAnimationFunction } from 'react-native-reanimated';

import { PrimaryButton, ScreenHeader } from '@/components/form';
import { alpha, colors, radius, spacing } from '@/theme';

/** Porte de lib/pages/investor_profile_page.dart — quiz de perfil do investidor. */

type Question = { text: string; options: string[] };

const QUESTIONS: Question[] = [
  {
    text: 'Qual é seu principal objetivo financeiro?',
    options: [
      'Proteger meu patrimônio sem correr riscos',
      'Crescimento moderado com algum risco controlado',
      'Maximizar retorno aceitando altos riscos',
    ],
  },
  {
    text: 'Se seu investimento cair 20% em um mês, você:',
    options: [
      'Vendo tudo imediatamente para evitar mais perdas',
      'Aguardo acreditando que vai se recuperar',
      'Compro mais pois representa uma oportunidade',
    ],
  },
  {
    text: 'Por quanto tempo você planeja manter seus investimentos?',
    options: ['Menos de 1 ano', 'Entre 2 e 5 anos', 'Mais de 5 anos'],
  },
  {
    text: 'Qual percentual da sua renda você pode investir mensalmente?',
    options: ['Até 10%', 'Entre 10% e 30%', 'Mais de 30%'],
  },
  {
    text: 'Qual parcela do seu dinheiro você toparia colocar em ações?',
    options: ['Nenhuma — prefiro renda fixa', 'Até 30% em ações', 'Mais de 60% em ações'],
  },
  {
    text: 'Você já tem uma reserva de emergência formada?',
    options: [
      'Não, ainda estou construindo',
      'Sim, parcialmente',
      'Sim, completa com mais de 6 meses de gastos',
    ],
  },
];

type Allocation = { label: string; pct: number; color: string };

type ProfileInfo = {
  title: string;
  icon: keyof typeof MaterialIcons.glyphMap;
  color: string;
  description: string;
  traits: string[];
  allocation: Allocation[];
};

const RESULT_INFO: Record<string, ProfileInfo> = {
  conservative: {
    title: 'Conservador',
    icon: 'shield',
    color: '#00D4AA',
    description:
      'Você prioriza a segurança do seu patrimônio e prefere investimentos com baixo risco e volatilidade.',
    traits: [
      'Prefere renda fixa e Tesouro Direto',
      'Valoriza liquidez e previsibilidade',
      'Horizonte de investimento mais curto',
    ],
    allocation: [
      { label: 'Renda Fixa / Tesouro', pct: 70, color: '#00D4AA' },
      { label: 'FIIs', pct: 20, color: '#4B7BF5' },
      { label: 'Ações', pct: 10, color: '#FFB547' },
    ],
  },
  moderate: {
    title: 'Moderado',
    icon: 'balance',
    color: '#4B7BF5',
    description:
      'Você busca equilíbrio entre segurança e crescimento, aceitando riscos controlados em troca de melhores retornos.',
    traits: [
      'Diversifica entre renda fixa e variável',
      'Tolera volatilidade a curto prazo',
      'Horizonte de médio a longo prazo',
    ],
    allocation: [
      { label: 'Ações', pct: 40, color: '#4B7BF5' },
      { label: 'Renda Fixa', pct: 35, color: '#00D4AA' },
      { label: 'FIIs', pct: 25, color: '#B47BF5' },
    ],
  },
  aggressive: {
    title: 'Arrojado',
    icon: 'rocket-launch',
    color: '#FFB547',
    description:
      'Você busca maximizar seus retornos e aceita alta volatilidade como parte da estratégia de crescimento acelerado.',
    traits: [
      'Investe majoritariamente em ações e cripto',
      'Possui reserva de emergência consolidada',
      'Horizonte de longo prazo (5+ anos)',
    ],
    allocation: [
      { label: 'Ações', pct: 60, color: '#FFB547' },
      { label: 'Cripto', pct: 20, color: '#FF4D6A' },
      { label: 'Renda Fixa', pct: 20, color: '#00D4AA' },
    ],
  },
};

const LETTERS = ['A', 'B', 'C'];

/**
 * Mesma transição do AnimatedSwitcher do Flutter: 350ms de fade somados a um
 * deslize horizontal curto (lá era Offset(0.04, 0) — cerca de 14px).
 */
const enterStep: EntryExitAnimationFunction = () => {
  'worklet';
  return {
    initialValues: { opacity: 0, transform: [{ translateX: 14 }] },
    animations: {
      opacity: withTiming(1, { duration: 350 }),
      transform: [{ translateX: withTiming(0, { duration: 350 }) }],
    },
  };
};

export default function InvestorProfileScreen() {
  // -1 = intro; QUESTIONS.length = resultado
  const [step, setStep] = useState(-1);
  const [answers, setAnswers] = useState<(number | null)[]>(Array(QUESTIONS.length).fill(null));

  const isComplete = !answers.includes(null) && step >= QUESTIONS.length;

  /** Cada resposta vale 0, 1 ou 2 — a soma define o perfil. */
  function result(): string {
    const total = answers.reduce<number>((sum, answer) => sum + (answer ?? 0), 0);
    if (total <= 4) return 'conservative';
    if (total <= 8) return 'moderate';
    return 'aggressive';
  }

  function selectOption(optionIndex: number) {
    setAnswers((current) => {
      const next = [...current];
      next[step] = optionIndex;
      return next;
    });
  }

  function restart() {
    setStep(-1);
    setAnswers(Array(QUESTIONS.length).fill(null));
  }

  return (
    <View style={styles.screen}>
      <ScreenHeader title="Perfil do Investidor" />

      {/* A `key` remonta a view a cada passo, que é o que dispara a transição. */}
      <Animated.View key={step} style={styles.flex} entering={enterStep}>
        {step === -1 ? (
          <IntroView onStart={() => setStep(0)} />
        ) : isComplete ? (
          <ResultView result={result()} onRestart={restart} />
        ) : (
          <QuizView
            step={step}
            total={QUESTIONS.length}
            question={QUESTIONS[step]}
            selected={answers[step]}
            onSelect={selectOption}
            onNext={answers[step] !== null ? () => setStep(step + 1) : undefined}
            onPrev={step > 0 ? () => setStep(step - 1) : undefined}
          />
        )}
      </Animated.View>
    </View>
  );
}

// ── Intro ────────────────────────────────────────────────────
function IntroView({ onStart }: { onStart: () => void }) {
  return (
    <View style={styles.intro}>
      <Text style={styles.introTitle}>Descubra seu{'\n'}Perfil de Investidor</Text>
      <Text style={styles.introSubtitle}>
        Responda 6 perguntas rápidas e descubra se você é conservador, moderado ou arrojado.
      </Text>

      <View style={styles.previewRow}>
        <ProfilePreview icon="shield" label="Conservador" color="#00D4AA" />
        <ProfilePreview icon="balance" label="Moderado" color="#4B7BF5" />
        <ProfilePreview icon="rocket-launch" label="Arrojado" color="#FFB547" />
      </View>

      <View style={styles.introButton}>
        <PrimaryButton label="Iniciar Quiz" onPress={onStart} />
      </View>
    </View>
  );
}

function ProfilePreview({
  icon,
  label,
  color,
}: {
  icon: keyof typeof MaterialIcons.glyphMap;
  label: string;
  color: string;
}) {
  return (
    <View style={styles.preview}>
      <View
        style={[
          styles.previewIcon,
          { backgroundColor: alpha(color, 0.1), borderColor: alpha(color, 0.3) },
        ]}
      >
        <MaterialIcons name={icon} size={28} color={color} />
      </View>
      <Text style={[styles.previewLabel, { color: alpha(color, 0.9) }]}>{label}</Text>
    </View>
  );
}

// ── Quiz ─────────────────────────────────────────────────────
function QuizView({
  step,
  total,
  question,
  selected,
  onSelect,
  onNext,
  onPrev,
}: {
  step: number;
  total: number;
  question: Question;
  selected: number | null;
  onSelect: (index: number) => void;
  onNext?: () => void;
  onPrev?: () => void;
}) {
  const progress = (step + 1) / total;

  return (
    <View style={styles.quiz}>
      <View style={styles.quizProgressRow}>
        <Text style={styles.quizStep}>
          Pergunta {step + 1} de {total}
        </Text>
        <Text style={styles.quizPercent}>{(progress * 100).toFixed(0)}%</Text>
      </View>

      <View style={styles.progressTrack}>
        <View style={[styles.progressFill, { width: `${progress * 100}%` }]} />
      </View>

      <Text style={styles.question}>{question.text}</Text>

      {question.options.map((label, index) => {
        const isSelected = selected === index;
        return (
          <Pressable
            key={label}
            onPress={() => onSelect(index)}
            style={[styles.option, isSelected && styles.optionSelected]}
          >
            <View style={[styles.optionLetter, isSelected && styles.optionLetterSelected]}>
              <Text style={[styles.optionLetterText, isSelected && styles.optionLetterTextSelected]}>
                {LETTERS[index]}
              </Text>
            </View>
            <Text style={[styles.optionText, isSelected && styles.optionTextSelected]}>{label}</Text>
          </Pressable>
        );
      })}

      <View style={styles.spacer} />

      <View style={styles.quizNav}>
        {onPrev ? (
          <Pressable style={styles.outlinedButton} onPress={onPrev}>
            <Text style={styles.outlinedButtonText}>Anterior</Text>
          </Pressable>
        ) : null}

        <View style={styles.quizNextButton}>
          <PrimaryButton
            label={step === total - 1 ? 'Ver Resultado' : 'Próxima'}
            onPress={() => onNext?.()}
            disabled={!onNext}
          />
        </View>
      </View>
    </View>
  );
}

// ── Resultado ────────────────────────────────────────────────
function ResultView({ result, onRestart }: { result: string; onRestart: () => void }) {
  const info = RESULT_INFO[result];

  return (
    <ScrollView contentContainerStyle={styles.resultContent}>
      <View
        style={[
          styles.resultIcon,
          { backgroundColor: alpha(info.color, 0.1), borderColor: alpha(info.color, 0.3) },
        ]}
      >
        <MaterialIcons name={info.icon} size={46} color={info.color} />
      </View>

      <Text style={[styles.resultTitle, { color: info.color }]}>Você é {info.title}</Text>
      <Text style={styles.resultDescription}>{info.description}</Text>

      <View
        style={[
          styles.traits,
          { backgroundColor: alpha(info.color, 0.06), borderColor: alpha(info.color, 0.2) },
        ]}
      >
        {info.traits.map((trait) => (
          <View key={trait} style={styles.traitRow}>
            <MaterialIcons name="check-circle" size={16} color={info.color} />
            <Text style={styles.traitText}>{trait}</Text>
          </View>
        ))}
      </View>

      <Text style={styles.allocationTitle}>Alocação Recomendada</Text>

      {info.allocation.map((item) => (
        <View key={item.label} style={styles.allocationRow}>
          <View style={styles.allocationLabels}>
            <Text style={styles.allocationLabel}>{item.label}</Text>
            <Text style={[styles.allocationPercent, { color: item.color }]}>{item.pct}%</Text>
          </View>
          <View style={styles.allocationTrack}>
            <View
              style={[
                styles.allocationFill,
                { width: `${item.pct}%`, backgroundColor: item.color },
              ]}
            />
          </View>
        </View>
      ))}

      <Pressable
        style={[styles.restartButton, { backgroundColor: info.color }]}
        onPress={onRestart}
      >
        <Text style={styles.restartText}>Refazer o Teste</Text>
      </Pressable>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  flex: { flex: 1 },
  spacer: { flex: 1 },

  intro: { flex: 1, alignItems: 'center', padding: spacing.xl },
  introTitle: {
    marginTop: 24,
    color: colors.textPrimary,
    fontSize: 28,
    fontWeight: '800',
    letterSpacing: -0.8,
    lineHeight: 28 * 1.2,
    textAlign: 'center',
  },
  introSubtitle: {
    marginTop: 12,
    color: colors.textSecondary,
    fontSize: 14,
    lineHeight: 14 * 1.5,
    textAlign: 'center',
  },
  previewRow: { flexDirection: 'row', justifyContent: 'center', gap: 12, marginTop: 36 },
  preview: { alignItems: 'center' },
  previewIcon: {
    width: 70,
    height: 70,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.lg,
    borderWidth: 1,
  },
  previewLabel: { marginTop: 6, fontSize: 11, fontWeight: '600' },
  introButton: { alignSelf: 'stretch', marginTop: 40 },

  quiz: { flex: 1, padding: spacing.xl },
  quizProgressRow: { flexDirection: 'row', justifyContent: 'space-between' },
  quizStep: { color: colors.textMuted, fontSize: 12, fontWeight: '600' },
  quizPercent: { color: colors.primary, fontSize: 12, fontWeight: '700' },
  progressTrack: {
    height: 6,
    marginTop: 8,
    backgroundColor: colors.bg4,
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
  progressFill: { height: 6, backgroundColor: colors.primary, borderRadius: radius.pill },

  question: {
    marginTop: 28,
    marginBottom: 24,
    color: colors.textPrimary,
    fontSize: 20,
    fontWeight: '700',
    lineHeight: 20 * 1.4,
  },
  option: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 12,
    padding: spacing.base,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  optionSelected: {
    backgroundColor: alpha(colors.primary, 0.12),
    borderColor: colors.primary,
    borderWidth: 1.5,
  },
  optionLetter: {
    width: 32,
    height: 32,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg4,
    borderRadius: 16,
  },
  optionLetterSelected: { backgroundColor: colors.primary },
  optionLetterText: { color: colors.textMuted, fontSize: 13, fontWeight: '700' },
  optionLetterTextSelected: { color: '#FFFFFF' },
  optionText: { flex: 1, color: colors.textSecondary, fontSize: 14 },
  optionTextSelected: { color: colors.textPrimary, fontWeight: '600' },

  quizNav: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 16 },
  quizNextButton: { flex: 2 },
  outlinedButton: {
    flex: 1,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  outlinedButtonText: { color: colors.primary, fontSize: 15, fontWeight: '600' },

  resultContent: { alignItems: 'center', padding: spacing.xl, paddingBottom: 40 },
  resultIcon: {
    width: 100,
    height: 100,
    marginTop: 16,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 50,
    borderWidth: 2,
  },
  resultTitle: { marginTop: 16, fontSize: 26, fontWeight: '800' },
  resultDescription: {
    marginTop: 8,
    color: colors.textSecondary,
    fontSize: 14,
    lineHeight: 14 * 1.5,
    textAlign: 'center',
  },
  traits: {
    alignSelf: 'stretch',
    marginTop: 24,
    padding: spacing.base,
    borderRadius: radius.lg,
    borderWidth: 1,
  },
  traitRow: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingVertical: 4 },
  traitText: { flex: 1, color: colors.textPrimary, fontSize: 13 },

  allocationTitle: {
    alignSelf: 'flex-start',
    marginTop: 20,
    marginBottom: 12,
    color: colors.textPrimary,
    fontSize: 16,
    fontWeight: '700',
  },
  allocationRow: { alignSelf: 'stretch', marginBottom: 10 },
  allocationLabels: { flexDirection: 'row', justifyContent: 'space-between' },
  allocationLabel: { color: colors.textSecondary, fontSize: 13, fontWeight: '600' },
  allocationPercent: { fontSize: 13, fontWeight: '700' },
  allocationTrack: {
    height: 6,
    marginTop: 4,
    backgroundColor: colors.bg4,
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
  allocationFill: { height: 6, borderRadius: radius.pill },

  restartButton: {
    alignSelf: 'stretch',
    height: 52,
    marginTop: 24,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.lg,
  },
  restartText: { color: '#FFFFFF', fontSize: 15, fontWeight: '600' },
});
