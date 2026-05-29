import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class PatrimonioLineChart extends StatelessWidget {
  final bool isLoading;
  final double totalInvested;

  const PatrimonioLineChart({
    super.key,
    this.isLoading = false,
    this.totalInvested = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      );
    }

    final base = totalInvested > 0 ? totalInvested : 10000.0;
    final spots = [
      FlSpot(0, base * 0.92),
      FlSpot(1, base * 0.88),
      FlSpot(2, base * 0.91),
      FlSpot(3, base * 0.95),
      FlSpot(4, base * 0.98),
      FlSpot(5, base),
    ];

    final labels = _last6Labels();

    return SizedBox(
      height: 88,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.primary,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minX: 0,
          maxX: 5,
        ),
      ),
    );
  }

  List<String> _last6Labels() {
    final now = DateTime.now();
    final labels = <String>[];
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day - i);
      labels.add('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}');
    }
    return labels;
  }
}
