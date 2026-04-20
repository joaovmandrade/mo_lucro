import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class PortfolioDonutChart extends StatefulWidget {
  /// Map of category → percentage (0–100)
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

    final sections = _buildSections();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 55,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex = (event.isInterestedForInteractions &&
                            response?.touchedSection != null)
                        ? response!.touchedSection!.touchedSectionIndex
                        : -1;
                  });
                },
              ),
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _Legend(distribution: widget.distribution, labels: _labels),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final entries = widget.distribution.entries.toList();
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final color = AppColors.chartColors[i % AppColors.chartColors.length];
      final pct = entries[i].value;

      return PieChartSectionData(
        value: pct,
        color: color,
        radius: isTouched ? 55 : 48,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        badgeWidget: isTouched ? null : null,
      );
    });
  }

  Widget _empty() {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 8),
            const Text(
              'Nenhum ativo ainda',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Map<String, double> distribution;
  final Map<String, String> labels;

  const _Legend({required this.distribution, required this.labels});

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries.toList();

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(entries.length, (i) {
        final color = AppColors.chartColors[i % AppColors.chartColors.length];
        final label = labels[entries[i].key] ?? entries[i].key;
        final pct = entries[i].value;

        return Row(
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
            const SizedBox(width: 6),
            Text(
              '$label  ${pct.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }
}
