import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../utils/formatters.dart';

/// Income simulator — compares fixed-income returns across banks.
class IncomeSimulatorPage extends StatefulWidget {
  const IncomeSimulatorPage({super.key});

  @override
  State<IncomeSimulatorPage> createState() => _IncomeSimulatorPageState();
}

class _IncomeSimulatorPageState extends State<IncomeSimulatorPage> {
  final _initialCtrl = TextEditingController(text: '1000');
  final _monthlyCtrl = TextEditingController(text: '500');
  final _periodCtrl  = TextEditingController(text: '12');

  // Annual rates (approximate)
  static const _banks = [
    _BankRate('Nubank',  0.1375), // ~13.75% a.a.
    _BankRate('Inter',   0.1300),
    _BankRate('C6 Bank', 0.1125),
    _BankRate('Selic',   0.1350),
    _BankRate('Poupança',0.0770),
  ];

  double get _initial =>
      double.tryParse(_initialCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _monthly =>
      double.tryParse(_monthlyCtrl.text.replaceAll(',', '.')) ?? 0;
  int get _period =>
      int.tryParse(_periodCtrl.text) ?? 0;

  /// Compound interest with monthly contributions.
  double _calcFinal(double rate) {
    if (_period <= 0) return _initial + _monthly * _period;
    final monthlyRate = rate / 12;
    // FV of initial
    final fvInitial = _initial * (1 + monthlyRate);
    // FV of monthly contributions (annuity)
    final fvContribs = monthlyRate > 0
        ? _monthly * ((1 + monthlyRate) - 1) / monthlyRate * _period *
            ((1 + monthlyRate))
        : _monthly * _period;
    // Simplified compound
    final invested = _initial + _monthly * _period;
    final total = invested + invested * rate * (_period / 12);
    return total;
  }

  double _calcReturn(double rate) =>
      _calcFinal(rate) - (_initial + _monthly * _period);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        title: const Text('Simulador de Rendimento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Input card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1D3B), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dados da Simulação',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _InputRow(
                  label: 'Investimento Inicial',
                  ctrl: _initialCtrl,
                  prefix: 'R\$ ',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _InputRow(
                  label: 'Aporte Mensal',
                  ctrl: _monthlyCtrl,
                  prefix: 'R\$ ',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _InputRow(
                  label: 'Período (meses)',
                  ctrl: _periodCtrl,
                  suffix: 'meses',
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Summary
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatBox(
                  label: 'Total Investido',
                  value: AppFormatters.currency(_initial + _monthly * _period),
                  color: AppColors.textSecondary,
                ),
                Container(width: 1, height: 32, color: AppColors.border),
                _StatBox(
                  label: 'Período',
                  value: '$_period meses',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Comparison table header
          const Text(
            'Comparação entre Bancos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Bank rows
          ..._banks.map((bank) {
            final finalVal = _calcFinal(bank.annualRate);
            final ret = _calcReturn(bank.annualRate);
            return _BankRow(
              bank: bank,
              finalValue: finalVal,
              returnValue: ret,
            );
          }),

          const SizedBox(height: 24),
          const Text(
            '* Simulação simplificada baseada em taxa anual fixa. Rendimentos reais '
            'variam conforme a taxa Selic e condições de cada banco.',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String? prefix;
  final String? suffix;
  final ValueChanged<String> onChanged;

  const _InputRow({
    required this.label,
    required this.ctrl,
    this.prefix,
    this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixText: prefix,
              suffixText: suffix,
              prefixStyle: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
              suffixStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
              filled: true,
              fillColor: AppColors.bg4,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BankRow extends StatelessWidget {
  final _BankRate bank;
  final double finalValue;
  final double returnValue;

  const _BankRow({
    required this.bank,
    required this.finalValue,
    required this.returnValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(
                  '${(bank.annualRate * 100).toStringAsFixed(2)}% a.a.',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(finalValue),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  '+${AppFormatters.currency(returnValue)}',
                  style: const TextStyle(
                      color: AppColors.profit,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _BankRate {
  final String name;
  final double annualRate;
  const _BankRate(this.name, this.annualRate);
}
