import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class PortfolioDonutChart extends StatefulWidget {
  final Map<String, double> distribution;

  const PortfolioDonutChart({
    super.key,
    required this.distribution,
  });

  @override
  State<PortfolioDonutChart> createState() => _PortfolioDonutChartState();
}

class _PortfolioDonutChartState extends State<PortfolioDonutChart> {
  int _touchedIndex = -1;

  static const _labels = {
    'stocks': 'Ações',
    'crypto': 'Cripto',
    'fixed_income': 'Renda Fixa',
    'others': 'Outros',
  };

  @override
  Widget build(BuildContext context) {
    if (widget.distribution.isEmpty) {
      return _empty();
    }

    final entries = widget.distribution.entries.toList();
    final touched = _touchedIndex >= 0 && _touchedIndex < entries.length
        ? entries[_touchedIndex]
        : null;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Donut ────────────────────────────────────────
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 60,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedIndex =
                            (event.isInterestedForInteractions &&
                                    response?.touchedSection != null)
                                ? response!
                                    .touchedSection!.touchedSectionIndex
                                : -1;
                      });
                    },
                  ),
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == _touchedIndex;
                    final color = AppColors
                        .chartColors[i % AppColors.chartColors.length];
                    final pct = entries[i].value;

                    return PieChartSectionData(
                      value: pct,
                      color: color,
                      radius: isTouched ? 54 : 46,
                      // Mostrar % dentro da fatia se > 8%
                      title: pct >= 8
                          ? '${pct.toStringAsFixed(0)}%'
                          : '',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
                ),
              ),

              // ── Texto central ─────────────────────────────────
              IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: touched != null
                      ? _CenterLabel(
                          key: ValueKey(touched.key),
                          label: _labels[touched.key] ?? touched.key,
                          percent: touched.value,
                        )
                      : _CenterTotal(
                          key: const ValueKey('total'),
                          totalSections: entries.length,
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Legend ────────────────────────────────────────────
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            final color =
                AppColors.chartColors[i % AppColors.chartColors.length];
            final label =
                _labels[entries[i].key] ?? entries[i].key;
            final pct = entries[i].value;

            return GestureDetector(
              onTap: () =>
                  setState(() => _touchedIndex = i == _touchedIndex ? -1 : i),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$label ${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _empty() {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pie_chart_outline_rounded,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 8),
            const Text(
              'Nenhum ativo ainda',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Centro: label da fatia tocada ─────────────────────────────
class _CenterLabel extends StatelessWidget {
  final String label;
  final double percent;

  const _CenterLabel({super.key, required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Centro: estado padrão (sem toque) ─────────────────────────
class _CenterTotal extends StatelessWidget {
  final int totalSections;

  const _CenterTotal({super.key, required this.totalSections});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Carteira',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$totalSections ${totalSections == 1 ? 'ativo' : 'ativos'}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}