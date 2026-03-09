import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Dashboard page — main financial overview.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, João! 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.monthYear(DateTime.now()),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Badge(
                      smallSize: 8,
                      child: const Icon(Icons.notifications_outlined, size: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Patrimony card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patrimônio Total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'R\$ 125.430,00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.profit.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_upward,
                                  color: AppColors.profit, size: 14),
                              SizedBox(width: 2),
                              Text(
                                '+2,3% este mês',
                                style: TextStyle(
                                  color: AppColors.profit,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stat cards row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Investido',
                      value: 'R\$ 100.000',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Saldo Livre',
                      value: 'R\$ 25.430',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick actions
              const Text(
                'Ações Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAction(
                    icon: Icons.add_circle_outline,
                    label: 'Investir',
                    color: AppColors.primary,
                    onTap: () => context.push('/investments/add'),
                  ),
                  _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'Gasto',
                    color: AppColors.error,
                    onTap: () => context.push('/expenses/add'),
                  ),
                  _QuickAction(
                    icon: Icons.calculate_outlined,
                    label: 'Simular',
                    color: AppColors.warning,
                    onTap: () => context.push('/simulators'),
                  ),
                  _QuickAction(
                    icon: Icons.analytics_outlined,
                    label: 'Risco',
                    color: AppColors.invested,
                    onTap: () => context.push('/reports/risk'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Portfolio chart
              const Text(
                'Distribuição da Carteira',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        title: '40%',
                        color: AppColors.chartColors[0],
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 25,
                        title: '25%',
                        color: AppColors.chartColors[1],
                        radius: 55,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 20,
                        title: '20%',
                        color: AppColors.chartColors[2],
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 15,
                        title: '15%',
                        color: AppColors.chartColors[3],
                        radius: 45,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Chart legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _LegendItem(color: AppColors.chartColors[0], label: 'CDB'),
                  _LegendItem(color: AppColors.chartColors[1], label: 'Tesouro'),
                  _LegendItem(color: AppColors.chartColors[2], label: 'Ações'),
                  _LegendItem(color: AppColors.chartColors[3], label: 'FIIs'),
                ],
              ),
              const SizedBox(height: 24),

              // Recent transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimos Lançamentos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/investments'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              ...List.generate(3, (i) {
                final items = [
                  ('CDB Banco Inter', 'R\$ 5.000,00', Icons.account_balance,
                      AppColors.primary, '2 dias atrás'),
                  ('Tesouro IPCA+', 'R\$ 2.000,00', Icons.flag_rounded,
                      AppColors.secondary, '5 dias atrás'),
                  ('Nubank 100% CDI', 'R\$ 10.000,00', Icons.savings,
                      AppColors.profit, '1 semana atrás'),
                ];
                final item = items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.$4.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$3, color: item.$4, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              item.$5,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.profit,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dados inseridos manualmente. Informações educativas.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
