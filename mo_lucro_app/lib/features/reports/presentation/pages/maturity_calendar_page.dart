import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../providers/report_provider.dart';

/// Maturity calendar screen showing upcoming investment maturities.
class MaturityCalendarPage extends ConsumerStatefulWidget {
  const MaturityCalendarPage({super.key});

  @override
  ConsumerState<MaturityCalendarPage> createState() => _MaturityCalendarPageState();
}

class _MaturityCalendarPageState extends ConsumerState<MaturityCalendarPage> {
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    ref.read(reportProvider.notifier).loadMaturities();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário de Vencimentos')),
      body: reportState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportState.maturities.isEmpty
              ? _buildEmpty()
              : _buildContent(reportState.maturities),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 64,
                color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Nenhum vencimento próximo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Seus investimentos com data de vencimento aparecerão aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> maturities) {
    // Group by month
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final m in maturities) {
      final dateStr = m['maturityDate'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(m);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.invested, Color(0xFF5E35B1)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.event_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text('${maturities.length} vencimentos',
                  style: const TextStyle(color: Colors.white, fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('nos próximos 12 meses',
                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Month sections
        for (final key in sortedKeys) ...[
          _MonthHeader(monthKey: key),
          const SizedBox(height: 8),
          ...grouped[key]!.map((m) => _MaturityCard(maturity: m)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String monthKey;
  const _MonthHeader({required this.monthKey});

  @override
  Widget build(BuildContext context) {
    final parts = monthKey.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        Formatters.monthYear(date).toUpperCase(),
        style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold,
          color: AppColors.textTertiary, letterSpacing: 1,
        ),
      ),
    );
  }
}

class _MaturityCard extends StatelessWidget {
  final Map<String, dynamic> maturity;
  const _MaturityCard({required this.maturity});

  @override
  Widget build(BuildContext context) {
    final daysLeft = maturity['daysToMaturity'] as int? ?? 0;
    final suggestion = maturity['suggestion'] as String?;
    final isUrgent = daysLeft <= 7;
    final isSoon = daysLeft <= 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isUrgent
            ? Border.all(color: AppColors.error.withOpacity(0.5), width: 1.5)
            : isSoon
                ? Border.all(color: AppColors.warning.withOpacity(0.3))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isUrgent ? AppColors.error : isSoon ? AppColors.warning : AppColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isUrgent ? Icons.warning_rounded : Icons.event_rounded,
                  color: isUrgent ? AppColors.error : isSoon ? AppColors.warning : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(maturity['name'] as String? ?? 'Investimento',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(maturity['type'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${(maturity['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isUrgent ? AppColors.error : isSoon ? AppColors.warning : AppColors.secondary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$daysLeft dias',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: isUrgent ? AppColors.error : isSoon ? AppColors.warning : AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (suggestion != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(child: Text(suggestion,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
