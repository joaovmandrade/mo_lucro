import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Dashboard page — main financial overview.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartAnimController;
  late Animation<double> _chartAnim;
  int _touchedIndex = -1;

  static const _sections = [
    _ChartSlice('CDB', 40, 100000, AppColors.chartColors, 0),
    _ChartSlice('Tesouro', 25, 62500, AppColors.chartColors, 1),
    _ChartSlice('Ações', 20, 50000, AppColors.chartColors, 2),
    _ChartSlice('FIIs', 15, 37500, AppColors.chartColors, 3),
  ];

  @override
  void initState() {
    super.initState();
    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _chartAnim = CurvedAnimation(parent: _chartAnimController, curve: Curves.easeOutCubic);
    _chartAnimController.forward();
  }

  @override
  void dispose() {
    _chartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bom dia, João',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      const Text('R\$ 125.430,00',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
                      const SizedBox(height: 8),
                      Row(children: const [
                        Icon(Icons.trending_up, color: AppColors.success, size: 16),
                        SizedBox(width: 4),
                        Text('+2,3% este mês', style: TextStyle(color: AppColors.success, fontSize: 14, fontWeight: FontWeight.w500)),
                      ]),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.push('/news'),
                    tooltip: 'Notícias Financeiras',
                    icon: const Icon(Icons.newspaper_rounded, size: 26, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Stat cards ───────────────────────────────────────────
              Row(children: [
                Expanded(child: StatCard(title: 'Investido', value: 'R\$ 100.000', icon: Icons.account_balance, color: AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Saldo Livre', value: 'R\$ 25.430', icon: Icons.account_balance_wallet, color: AppColors.info)),
              ]),
              const SizedBox(height: 32),

              // ── Quick actions ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(icon: Icons.add, label: 'Investir', onTap: () => context.push('/investments/add')),
                  _QuickAction(icon: Icons.remove, label: 'Gasto', onTap: () => context.push('/expenses/add')),
                  _QuickAction(icon: Icons.calculate_outlined, label: 'Simular', onTap: () => context.push('/simulators')),
                  _QuickAction(icon: Icons.analytics_outlined, label: 'Risco', onTap: () => context.push('/reports/risk')),
                ],
              ),
              const SizedBox(height: 44),

              // ── Portfolio chart ──────────────────────────────────────
              const Text('Distribuição da Carteira',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 24),

              AnimatedBuilder(
                animation: _chartAnim,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Donut + center label
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                startDegreeOffset: -90,
                                sectionsSpace: 2,
                                centerSpaceRadius: 52,
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          response == null ||
                                          response.touchedSection == null) {
                                        _touchedIndex = -1;
                                      } else {
                                        _touchedIndex = response.touchedSection!.touchedSectionIndex;
                                      }
                                    });
                                  },
                                ),
                                sections: List.generate(_sections.length, (i) {
                                  final s = _sections[i];
                                  final isTouched = i == _touchedIndex;
                                  final radius = (isTouched ? 44.0 : 38.0) * _chartAnim.value;
                                  return PieChartSectionData(
                                    value: s.pct,
                                    title: '',
                                    color: AppColors.chartColors[s.colorIndex],
                                    radius: radius,
                                    badgeWidget: isTouched
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.surface,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Text('${s.pct.toInt()}%',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                          )
                                        : null,
                                    badgePositionPercentageOffset: 1.4,
                                  );
                                }),
                              ),
                            ),
                            // Center label
                            Opacity(
                              opacity: _chartAnim.value,
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                const Text('Portfolio',
                                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.5)),
                                const SizedBox(height: 2),
                                const Text('R\$ 125k',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              ]),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 28),

                      // Legend
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(_sections.length, (i) {
                            final s = _sections[i];
                            final isActive = i == _touchedIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: isActive
                                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                                  : EdgeInsets.zero,
                              decoration: isActive
                                  ? BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.border),
                                    )
                                  : null,
                              child: Row(children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.chartColors[s.colorIndex],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(s.label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                        color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                                      )),
                                ),
                                Text('${s.pct.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? AppColors.chartColors[s.colorIndex] : AppColors.textTertiary,
                                    )),
                              ]),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 44),

              // ── Recent transactions ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Últimos Lançamentos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  TextButton(
                    onPressed: () => context.go('/investments'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(3, (i) {
                const items = [
                  ('CDB Banco Inter', 'R\$ 5.000,00', Icons.account_balance, AppColors.chartColors, 0, '2 dias atrás'),
                  ('Tesouro IPCA+', 'R\$ 2.000,00', Icons.flag_rounded, AppColors.chartColors, 1, '5 dias atrás'),
                  ('Nubank 100% CDI', 'R\$ 10.000,00', Icons.savings, AppColors.chartColors, 2, '1 semana atrás'),
                ];
                final item = items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(item.$3, color: AppColors.chartColors[item.$5 as int], size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(item.$6 as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ])),
                    Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 15)),
                  ]),
                );
              }),

              const SizedBox(height: 20),
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('Dados inseridos manualmente. Informações educativas.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data class for chart slices ─────────────────────────────────────────────
class _ChartSlice {
  final String label;
  final double pct;
  final double value;
  final List<Color> colors;
  final int colorIndex;

  const _ChartSlice(this.label, this.pct, this.value, this.colors, this.colorIndex);
}

// ── Quick Action button ─────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ]),
    );
  }
}
