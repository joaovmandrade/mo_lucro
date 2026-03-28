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
          final isLast = i == goals.length - 1;
          final progress = (g['current'] as double) / (g['target'] as double);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(g['icon'] as IconData, color: g['color'] as Color, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                              Text('Prioridade: ${g['priority']}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text('${(progress * 100).toInt()}%',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: g['color'] as Color)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.highlightSurface,
                        valueColor: AlwaysStoppedAnimation(g['color'] as Color),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('R\$ ${(g['current'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('R\$ ${(g['target'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1),
            ],
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
