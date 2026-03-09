import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RiskAnalysisPage extends StatelessWidget {
  const RiskAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análise de Risco')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Risk level card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF00897B)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Icon(Icons.shield_rounded, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              const Text('Perfil da Carteira', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('MODERADO', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Text('Score: 45/100', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Distribution
          _Section(title: 'Distribuição', children: [
            _DistBar(label: 'Renda Fixa', pct: 65, color: AppColors.primary),
            _DistBar(label: 'Renda Variável', pct: 30, color: AppColors.warning),
            _DistBar(label: 'Outros', pct: 5, color: AppColors.textTertiary),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Observações', children: [
            _InfoItem(icon: Icons.info_outline, text: 'Sua carteira tem perfil moderado.', color: AppColors.info),
            _InfoItem(icon: Icons.info_outline, text: '65% em renda fixa e 30% em renda variável.', color: AppColors.info),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Alertas', children: [
            _InfoItem(icon: Icons.warning_rounded, text: 'Alta concentração em CDB (42%). Considere diversificar.', color: AppColors.warning),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Sugestões', children: [
            _InfoItem(icon: Icons.lightbulb_outline, text: 'Mantenha uma reserva de emergência em ativos de alta liquidez.', color: AppColors.secondary),
            _InfoItem(icon: Icons.lightbulb_outline, text: 'Diversificar com FIIs pode aumentar a rentabilidade.', color: AppColors.secondary),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}

class _DistBar extends StatelessWidget {
  final String label;
  final int pct;
  final Color color;
  const _DistBar({required this.label, required this.pct, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text('$pct%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: pct / 100, minHeight: 6,
            backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color)),
        ),
      ]),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoItem({required this.icon, required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4))),
      ]),
    );
  }
}
