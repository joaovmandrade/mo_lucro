import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class ProfileQuizPage extends StatefulWidget {
  const ProfileQuizPage({super.key});
  @override
  State<ProfileQuizPage> createState() => _ProfileQuizPageState();
}

class _ProfileQuizPageState extends State<ProfileQuizPage> {
  int _currentQuestion = 0;
  final _answers = <int, String>{};
  bool _showResult = false;

  final _questions = [
    {'q': 'Qual é o seu objetivo principal com investimentos?',
     'options': ['Preservar meu capital com segurança', 'Crescimento moderado com segurança', 'Maximizar ganhos, aceitando riscos']},
    {'q': 'Como reagiria se seu investimento caísse 20%?',
     'options': ['Venderia tudo', 'Ficaria preocupado, mas manteria', 'Compraria mais']},
    {'q': 'Qual seu horizonte de investimento?',
     'options': ['Menos de 1 ano', '1 a 5 anos', 'Mais de 5 anos']},
    {'q': 'Qual seu conhecimento sobre investimentos?',
     'options': ['Básico', 'Intermediário', 'Avançado']},
    {'q': 'Já investiu em renda variável?',
     'options': ['Nunca', 'Sim, mas pouco', 'Sim, regularmente']},
  ];

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResult();

    final q = _questions[_currentQuestion];
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Investidor')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            backgroundColor: AppColors.border,
          ),
          const SizedBox(height: 8),
          Text('${_currentQuestion + 1} de ${_questions.length}',
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          const SizedBox(height: 32),
          Text(q['q'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ...(q['options'] as List<String>).asMap().entries.map((e) {
            final selected = _answers[_currentQuestion] == e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _answers[_currentQuestion] = e.value),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
                  ),
                  child: Row(children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: selected ? AppColors.primary : AppColors.textTertiary, width: 2),
                        color: selected ? AppColors.primary : Colors.transparent,
                      ),
                      child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.value, style: TextStyle(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? AppColors.primary : AppColors.textPrimary))),
                  ]),
                ),
              ),
            );
          }),
          const Spacer(),
          Row(children: [
            if (_currentQuestion > 0) Expanded(child: AppButton(text: 'Anterior', isOutlined: true,
              onPressed: () => setState(() => _currentQuestion--))),
            if (_currentQuestion > 0) const SizedBox(width: 12),
            Expanded(child: AppButton(
              text: _currentQuestion == _questions.length - 1 ? 'Resultado' : 'Próximo',
              onPressed: _answers[_currentQuestion] == null ? null : () {
                if (_currentQuestion < _questions.length - 1) {
                  setState(() => _currentQuestion++);
                } else {
                  setState(() => _showResult = true);
                }
              },
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _buildResult() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('Seu Perfil', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('MODERADO', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            const Text(
              'Você busca equilíbrio entre segurança e rentabilidade. '
              'Aceita algum nível de risco em troca de retornos maiores.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            AppButton(text: 'Ir para o Dashboard', onPressed: () => context.go('/dashboard')),
            const SizedBox(height: 12),
            AppButton(text: 'Refazer Quiz', isOutlined: true,
              onPressed: () => setState(() { _showResult = false; _currentQuestion = 0; _answers.clear(); })),
          ]),
        ),
      ),
    );
  }
}
