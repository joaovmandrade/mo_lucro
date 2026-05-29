import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PortfolioChart extends StatelessWidget {
  final List data;

  const PortfolioChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: true,
              dotData: FlDotData(show: false),
            )
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    double total = 0;
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      final type = data[i]['type'];
      final value = (data[i]['total'] ?? 0).toDouble();

      if (type == 'buy') total += value;
      if (type == 'sell') total -= value;

      spots.add(FlSpot(i.toDouble(), total));
    }

    return spots;
  }
}