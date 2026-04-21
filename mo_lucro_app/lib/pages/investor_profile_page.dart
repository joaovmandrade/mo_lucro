import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Investor profile quiz — 6 questions, 3 answer options each.
/// Results: conservative / moderate / aggressive.
class InvestorProfilePage extends StatefulWidget {
  const InvestorProfilePage({super.key});

  @override
  State<InvestorProfilePage> createState() => _InvestorProfilePageState();
}

class _InvestorProfilePageState extends State<InvestorProfilePage> {
  int _step = -1; // -1 = intro
  final List<int?> _answers = List.filled(6, null);

  static const _questions = [
    _Question(
      text: 'Qual é seu principal objetivo financeiro?',
      options: [
        'Proteger meu patrimônio sem correr riscos',
        'Crescimento moderado com algum risco controlado',
        'Maximizar retorno aceitando altos riscos',
      ],
    ),
    _Question(
      text: 'Se seu investimento cair 20% em um mês, você:',
      options: [
        'Vendo tudo imediatamente para evitar mais perdas',
        'Aguardo acreditando que vai se recuperar',
        'Compro mais pois representa uma oportunidade',
      ],
    ),
    _Question(
      text: 'Por quanto tempo você planeja manter seus investimentos?',
      options: [
        'Menos de 1 ano',
        'Entre 2 e 5 anos',
        'Mais de 5 anos',
      ],
    ),
    _Question(
      text: 'Qual percentual da sua renda você pode investir mensalmente?',
      options: [
        'Até 10%',
        'Entre 10% e 30%',
        'Mais de 30%',
      ],
    ),
    _Question(
      text: 'Qual parcela do seu dinheiro você toparia colocar em ações?',
      options: [
        'Nenhuma — prefiro renda fixa',
        'Até 30% em ações',
        'Mais de 60% em ações',
      ],
    ),
    _Question(
      text: 'Você já tem uma reserva de emergência formada?',
      options: [
        'Não, ainda estou construindo',
        'Sim, parcialmente',
        'Sim, completa com mais de 6 meses de gastos',
      ],
    ),
  ];

  // Score 0 = conservative, 1 = moderate, 2 = aggressive per answer
  String get _result {
    final total = _answers.fold(0, (s, a) => s + (a ?? 0));
    if (total <= 4) return 'conservative';
    if (total <= 8) return 'moderate';
    return 'aggressive';
  }

  bool get _isComplete => !_answers.contains(null) && _step >= _questions.length;

  void _startQuiz() => setState(() => _step = 0);

  void _selectOption(int optionIndex) {
    setState(() {
      _answers[_step] = optionIndex;
    });
  }

  void _next() {
    if (_step < _questions.length - 1) {
      setState(() => _step++);
    } else {
      setState(() => _step = _questions.length);
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  void _restart() {
    setState(() {
      _step = -1;
      _answers.fillRange(0, _answers.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        title: const Text('Perfil do Investidor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: _step == -1
            ? _IntroView(key: const ValueKey('intro'), onStart: _startQuiz)
            : _isComplete
                ? _ResultView(
                    key: const ValueKey('result'),
                    result: _result,
                    onRestart: _restart,
                  )
                : _QuizView(
                    key: ValueKey('q$_step'),
                    step: _step,
                    total: _questions.length,
                    question: _questions[_step],
                    selected: _answers[_step],
                    onSelect: _selectOption,
                    onNext: _answers[_step] != null ? _next : null,
                    onPrev: _step > 0 ? _prev : null,
                  ),
      ),
    );
  }
}

// ── Intro ─────────────────────────────────────────────────────

class _IntroView extends StatelessWidget {
  final VoidCallback onStart;
  const _IntroView({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Descubra seu\nPerfil de Investidor',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Responda 6 perguntas rápidas e descubra se você é '
            'conservador, moderado ou arrojado.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 36),

          // 3 profile cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _ProfilePreview(
                icon: Icons.shield_outlined,
                label: 'Conservador',
                color: Color(0xFF00D4AA),
              ),
              SizedBox(width: 12),
              _ProfilePreview(
                icon: Icons.balance_outlined,
                label: 'Moderado',
                color: Color(0xFF4B7BF5),
              ),
              SizedBox(width: 12),
              _ProfilePreview(
                icon: Icons.rocket_launch_outlined,
                label: 'Arrojado',
                color: Color(0xFFFFB547),
              ),
            ],
          ),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: onStart,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Iniciar Quiz'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePreview extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ProfilePreview({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Quiz ──────────────────────────────────────────────────────

class _QuizView extends StatelessWidget {
  final int step;
  final int total;
  final _Question question;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  const _QuizView({
    super.key,
    required this.step,
    required this.total,
    required this.question,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / total;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text(
                'Pergunta ${step + 1} de $total',
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${((step + 1) / total * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.bg4,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 28),

          // Question
          Text(
            question.text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Options
          ...question.options.asMap().entries.map((e) {
            final i     = e.key;
            final label = e.value;
            final isSel = selected == i;
            final letters = ['A', 'B', 'C'];
            return GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: isSel
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.bg2,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSel ? AppColors.primary : AppColors.border,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.bg4,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          letters[i],
                          style: TextStyle(
                            color: isSel ? Colors.white : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSel
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight:
                              isSel ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const Spacer(),

          // Navigation
          Row(
            children: [
              if (onPrev != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrev,
                    child: const Text('Anterior'),
                  ),
                ),
              if (onPrev != null) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: Text(step == 5 ? 'Ver Resultado' : 'Próxima'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Result ────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final String result;
  final VoidCallback onRestart;

  const _ResultView({super.key, required this.result, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final info = _resultInfo[result]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: info.color.withOpacity(0.3), width: 2),
            ),
            child: Icon(info.icon, color: info.color, size: 46),
          ),
          const SizedBox(height: 16),
          Text(
            'Você é ${info.title}',
            style: TextStyle(
              color: info.color,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Characteristics
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: info.color.withOpacity(0.2)),
            ),
            child: Column(
              children: info.traits.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Icon(Icons.check_circle_rounded,
                      color: info.color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(t,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13)),
                  ),
                ]),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Recommended allocation
          const Text(
            'Alocação Recomendada',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...info.allocation.map((a) => _AllocationRow(item: a)),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: onRestart,
            style: ElevatedButton.styleFrom(backgroundColor: info.color),
            child: const Text('Refazer o Teste'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AllocationRow extends StatelessWidget {
  final _Allocation item;
  const _AllocationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text('${item.pct}%',
                  style: TextStyle(
                      color: item.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Stack(children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.bg4,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            FractionallySizedBox(
              widthFactor: item.pct / 100,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────

class _Question {
  final String text;
  final List<String> options;
  const _Question({required this.text, required this.options});
}

class _Allocation {
  final String label;
  final int pct;
  final Color color;
  const _Allocation(this.label, this.pct, this.color);
}

class _ProfileInfo {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> traits;
  final List<_Allocation> allocation;

  const _ProfileInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.traits,
    required this.allocation,
  });
}

const _resultInfo = {
  'conservative': _ProfileInfo(
    title: 'Conservador',
    icon: Icons.shield_outlined,
    color: Color(0xFF00D4AA),
    description: 'Você prioriza a segurança do seu patrimônio e prefere '
        'investimentos com baixo risco e volatilidade.',
    traits: [
      'Prefere renda fixa e Tesouro Direto',
      'Valoriza liquidez e previsibilidade',
      'Horizonte de investimento mais curto',
    ],
    allocation: [
      _Allocation('Renda Fixa / Tesouro', 70, Color(0xFF00D4AA)),
      _Allocation('FIIs', 20, Color(0xFF4B7BF5)),
      _Allocation('Ações', 10, Color(0xFFFFB547)),
    ],
  ),
  'moderate': _ProfileInfo(
    title: 'Moderado',
    icon: Icons.balance_outlined,
    color: Color(0xFF4B7BF5),
    description: 'Você busca equilíbrio entre segurança e crescimento, '
        'aceitando riscos controlados em troca de melhores retornos.',
    traits: [
      'Diversifica entre renda fixa e variável',
      'Tolera volatilidade a curto prazo',
      'Horizonte de médio a longo prazo',
    ],
    allocation: [
      _Allocation('Ações', 40, Color(0xFF4B7BF5)),
      _Allocation('Renda Fixa', 35, Color(0xFF00D4AA)),
      _Allocation('FIIs', 25, Color(0xFFB47BF5)),
    ],
  ),
  'aggressive': _ProfileInfo(
    title: 'Arrojado',
    icon: Icons.rocket_launch_outlined,
    color: Color(0xFFFFB547),
    description: 'Você busca maximizar seus retornos e aceita alta volatilidade '
        'como parte da estratégia de crescimento acelerado.',
    traits: [
      'Investe majoritariamente em ações e cripto',
      'Possui reserva de emergência consolidada',
      'Horizonte de longo prazo (5+ anos)',
    ],
    allocation: [
      _Allocation('Ações', 60, Color(0xFFFFB547)),
      _Allocation('Cripto', 20, Color(0xFFFF4D6A)),
      _Allocation('Renda Fixa', 20, Color(0xFF00D4AA)),
    ],
  ),
};
