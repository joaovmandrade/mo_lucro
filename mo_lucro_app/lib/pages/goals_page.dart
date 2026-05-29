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
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
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
    final ctrl = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Adicionar valor à "${goal.title}"',
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso atual: ${goal.progressPercent.toStringAsFixed(1)}%',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
              decoration: InputDecoration(
                hintText: '0,00',
                prefixText: 'R\$ ',
                prefixStyle: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.bg3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Faltam ${AppFormatters.currency(goal.remaining)} para a meta',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final v =
                  double.tryParse(ctrl.text.replaceAll(',', '.'));
              Navigator.pop(ctx, v);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final newVal =
          (goal.currentValue + result).clamp(0.0, goal.targetValue);
      await _service.updateGoalProgress(goal.id, newVal);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _goals.where((g) => g.isCompleted).length;
    final totalTarget = _goals.fold(0.0, (s, g) => s + g.targetValue);
    final totalCurrent = _goals.fold(0.0, (s, g) => s + g.currentValue);
    final overallProgress =
        totalTarget > 0 ? totalCurrent / totalTarget : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_goals',
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalPage()),
          );
          if (ok == true) _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg1,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // ── Blue gradient header ──────────────────────
            SliverToBoxAdapter(
              child: _GoalsHeader(
                totalGoals: _goals.length,
                completed: completed,
                totalCurrent: totalCurrent,
                totalTarget: totalTarget,
                overallProgress: overallProgress,
                isLoading: _loading,
              ),
            ),

            // ── Goal list ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: _loading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2),
                        ),
                      ),
                    )
                  : _goals.isEmpty
                      ? SliverToBoxAdapter(child: _EmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => GoalCard(
                              goal: _goals[i],
                              onAddProgress: () =>
                                  _addProgress(_goals[i]),
                              onDelete: () => _delete(_goals[i].id),
                            ),
                            childCount: _goals.length,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Blue Header
// ─────────────────────────────────────────────────────────────
class _GoalsHeader extends StatelessWidget {
  final int totalGoals;
  final int completed;
  final double totalCurrent;
  final double totalTarget;
  final double overallProgress;
  final bool isLoading;

  const _GoalsHeader({
    required this.totalGoals,
    required this.completed,
    required this.totalCurrent,
    required this.totalTarget,
    required this.overallProgress,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  const Text(
                    'Minhas Metas',
                    style: TextStyle(
                      color: AppColors.textOnBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (totalGoals > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.20)),
                      ),
                      child: Text(
                        '$completed de $totalGoals concluídas',
                        style: const TextStyle(
                          color: AppColors.textOnBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress card (only if there are goals)
              if (!isLoading && totalGoals > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progresso Geral',
                            style: TextStyle(
                              color: AppColors.textOnBlueDim,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${(overallProgress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.textOnBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Stack(
                          children: [
                            Container(
                              height: 8,
                              color: Colors.white.withOpacity(0.18),
                            ),
                            FractionallySizedBox(
                              widthFactor: overallProgress.clamp(0.0, 1.0),
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.warning,
                                      const Color(0xFFFBBF24),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.pill),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Acumulado',
                                style: TextStyle(
                                  color: AppColors.textOnBlueDim,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppFormatters.currency(totalCurrent),
                                style: const TextStyle(
                                  color: AppColors.textOnBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Objetivo total',
                                style: TextStyle(
                                  color: AppColors.textOnBlueDim,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppFormatters.currency(totalTarget),
                                style: const TextStyle(
                                  color: AppColors.textOnBlueDim,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (isLoading) ...[
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ] else ...[
                // Empty state hint in header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.textOnBlueDim, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Defina metas financeiras e acompanhe seu progresso.',
                          style: TextStyle(
                            color: AppColors.textOnBlueDim,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.warning.withOpacity(0.18)),
            ),
            child: const Icon(Icons.flag_outlined,
                color: AppColors.warning, size: 36),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nenhuma meta ainda',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crie sua primeira meta financeira\ne acompanhe seu progresso!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
