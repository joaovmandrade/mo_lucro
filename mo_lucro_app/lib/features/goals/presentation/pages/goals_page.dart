import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = [
      {'name': 'Reserva de Emergência', 'target': 30000.0, 'current': 18000.0,
       'icon': Icons.shield_rounded, 'color': AppColors.primary, 'priority': 'Alta'},
      {'name': 'Viagem Europa', 'target': 20000.0, 'current': 5000.0,
       'icon': Icons.flight_rounded, 'color': AppColors.secondary, 'priority': 'Média'},
      {'name': 'Carro Novo', 'target': 80000.0, 'current': 32000.0,
       'icon': Icons.directions_car_rounded, 'color': AppColors.warning, 'priority': 'Baixa'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Metas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, i) {
          final g = goals[i];
          final progress = (g['current'] as double) / (g['target'] as double);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (g['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(g['icon'] as IconData, color: g['color'] as Color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Prioridade: ${g['priority']}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    Text('${(progress * 100).toInt()}%',
                        style: TextStyle(fontWeight: FontWeight.bold, color: g['color'] as Color)),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: (g['color'] as Color).withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(g['color'] as Color),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('R\$ ${(g['current'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('R\$ ${(g['target'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/add'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Meta'),
      ),
    );
  }
}
