import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import '../utils/formatters.dart';
import '../widgets/goal_card.dart';
import 'add_goal_page.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _service = GoalService();
  List<GoalModel> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final goals = await _service.getGoals();
      if (mounted) setState(() => _goals = goals);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await _confirmDelete();
    if (confirm != true) return;
    await _service.deleteGoal(id);
    _load();
  }

  Future<bool?> _confirmDelete() => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bg2,
          title: const Text('Excluir meta',
              style: TextStyle(color: AppColors.textPrimary)),
          content: const Text('Tem certeza que deseja excluir esta meta?',
              style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.loss)),
            ),
          ],
        ),
      );

  Future<void> _addProgress(GoalModel goal) async {
    final controller = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Adicionar valor',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Valor em R\$',
                prefixText: 'R\$ ',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.bg3,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(
                  controller.text.replaceAll(',', '.'));
              Navigator.pop(ctx, v);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final newVal = (goal.currentValue + result).clamp(0.0, goal.targetValue);
      await _service.updateGoalProgress(goal.id, newVal);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _goals.where((g) => g.isCompleted).length;
    final totalTarget = _goals.fold(0.0, (s, g) => s + g.targetValue);
    final totalCurrent = _goals.fold(0.0, (s, g) => s + g.currentValue);

    return Scaffold(
      backgroundColor: AppColors.bg0,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_goals',
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalPage()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg2,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.bg0,
              title: const Text('Metas'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Progress overview
                  if (_goals.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progresso geral',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '$completed de ${_goals.length} concluídas',
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: totalTarget > 0
                                  ? (totalCurrent / totalTarget)
                                      .clamp(0.0, 1.0)
                                  : 0,
                              backgroundColor: AppColors.bg3,
                              valueColor:
                                  const AlwaysStoppedAnimation(AppColors.warning),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppFormatters.currency(totalCurrent),
                                style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                AppFormatters.currency(totalTarget),
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Goal list
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2),
                      ),
                    )
                  else if (_goals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.flag_outlined,
                              color: AppColors.textMuted, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhuma meta ainda.\nCrie sua primeira meta financeira!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.6),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._goals.map(
                      (goal) => GoalCard(
                        goal: goal,
                        onAddProgress: () => _addProgress(goal),
                        onDelete: () => _delete(goal.id),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
