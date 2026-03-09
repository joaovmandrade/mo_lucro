import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + Name
          Center(
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              const Text('João Silva', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('joao@email.com', style: TextStyle(color: AppColors.textTertiary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Moderado', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ]),
          ),
          const SizedBox(height: 32),

          _MenuItem(icon: Icons.quiz_rounded, label: 'Perfil do Investidor', subtitle: 'Refazer questionário',
            onTap: () => context.push('/profile/quiz')),
          _MenuItem(icon: Icons.calculate_rounded, label: 'Simuladores', subtitle: 'Juros compostos e CDB',
            onTap: () => context.push('/simulators')),
          _MenuItem(icon: Icons.analytics_rounded, label: 'Análise de Risco', subtitle: 'Sua carteira',
            onTap: () => context.push('/reports/risk')),
          const Divider(height: 32),
          _MenuItem(icon: Icons.settings_rounded, label: 'Configurações',
            onTap: () {}),
          _MenuItem(icon: Icons.help_outline_rounded, label: 'Ajuda',
            onTap: () {}),
          _MenuItem(icon: Icons.info_outline_rounded, label: 'Sobre o App', subtitle: 'v${AppConstants.appVersion}',
            onTap: () {}),
          const SizedBox(height: 16),
          _MenuItem(icon: Icons.logout_rounded, label: 'Sair', color: AppColors.error,
            onTap: () => context.go('/login')),
          const SizedBox(height: 24),
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              AppConstants.disclaimer,
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, this.subtitle, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(children: [
          Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? AppColors.textPrimary)),
            if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ])),
          Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        ]),
      ),
    );
  }
}
