import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});
  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  final _initialController = TextEditingController(text: '1000');
  final _monthlyController = TextEditingController(text: '500');
  final _rateController = TextEditingController(text: '12');
  final _monthsController = TextEditingController(text: '24');
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Juros Compostos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.calculate_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Simule o crescimento do seu investimento com juros compostos',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(label: 'Valor Inicial (R\$)', hint: '1.000', controller: _initialController,
            keyboardType: TextInputType.number, prefixIcon: const Icon(Icons.attach_money)),
          const SizedBox(height: 16),
          AppTextField(label: 'Aporte Mensal (R\$)', hint: '500', controller: _monthlyController,
            keyboardType: TextInputType.number, prefixIcon: const Icon(Icons.repeat)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: AppTextField(label: 'Taxa Anual (%)', hint: '12', controller: _rateController,
              keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: AppTextField(label: 'Meses', hint: '24', controller: _monthsController,
              keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 24),
          AppButton(text: 'Simular', icon: Icons.play_arrow_rounded,
            onPressed: () => setState(() => _showResult = true)),

          if (_showResult) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Text('Resultado da Simulação', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                const SizedBox(height: 12),
                const Text('R\$ 27.243,56', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _ResultItem(label: 'Investido', value: 'R\$ 13.000'),
                  _ResultItem(label: 'Lucro', value: 'R\$ 14.243'),
                  _ResultItem(label: 'IR Est.', value: 'R\$ 2.136'),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(24, (i) => FlSpot(i.toDouble(), 1000 + i * 600.0)),
                    isCurved: true, color: AppColors.primary,
                    barWidth: 3, dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                  ),
                ],
              )),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Simulação educativa. Valores reais podem variar.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label, value;
  const _ResultItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    ]);
  }
}
