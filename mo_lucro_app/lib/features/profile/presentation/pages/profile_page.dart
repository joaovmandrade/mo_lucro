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
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text('João Silva', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              const Text('joao@email.com', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Investidor Moderado', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
              ),
            ]),
          ),
          const SizedBox(height: 48),

          _MenuItem(icon: Icons.quiz_rounded, label: 'Perfil do Investidor', subtitle: 'Refazer questionário',
            onTap: () => context.push('/profile/quiz')),
          const Divider(height: 1),
          _MenuItem(icon: Icons.calculate_rounded, label: 'Simuladores', subtitle: 'Juros compostos e CDB',
            onTap: () => context.push('/simulators')),
          const Divider(height: 1),
          _MenuItem(icon: Icons.analytics_rounded, label: 'Análise de Risco', subtitle: 'Sua carteira',
            onTap: () => context.push('/reports/risk')),
          const SizedBox(height: 32),
          const Divider(height: 1),
          _MenuItem(icon: Icons.settings_rounded, label: 'Configurações',
            onTap: () {}),
          const Divider(height: 1),
          _MenuItem(icon: Icons.help_outline_rounded, label: 'Ajuda',
            onTap: () {}),
          const Divider(height: 1),
          _MenuItem(icon: Icons.info_outline_rounded, label: 'Sobre o App', subtitle: 'v${AppConstants.appVersion}',
            onTap: () {}),
          const SizedBox(height: 16),
          _MenuItem(icon: Icons.logout_rounded, label: 'Sair', color: AppColors.error,
            onTap: () => context.go('/login')),
          const SizedBox(height: 24),
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              AppConstants.disclaimer,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Row(children: [
          Icon(icon, color: color ?? AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: color ?? AppColors.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ])),
          Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        ]),
      ),
    );
  }
}
