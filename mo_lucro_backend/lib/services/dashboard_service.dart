import '../repositories/investment_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/goal_repository.dart';
import '../models/dashboard_data.dart';

/// Service that aggregates dashboard data from multiple sources.
class DashboardService {
  final InvestmentRepository _investmentRepo;
  final ExpenseRepository _expenseRepo;
  final GoalRepository _goalRepo;

  DashboardService(this._investmentRepo, this._expenseRepo, this._goalRepo);

  /// Get complete dashboard data for a user.
  Future<DashboardData> getDashboardData(String userId) async {
    // Parallel data fetching
    final results = await Future.wait([
      _investmentRepo.getTotalInvested(userId),
      _investmentRepo.getPortfolioDistribution(userId),
      _investmentRepo.getUpcomingMaturities(userId),
      _expenseRepo.getMonthlySummary(userId),
      _investmentRepo.findByUserId(userId, limit: 5),
      _goalRepo.findByUserId(userId),
    ]);

    final totalInvested = results[0] as double;
    final distribution = results[1] as Map<String, double>;
    final maturities = results[2] as List;
    final summary = results[3] as Map<String, dynamic>;
    final recentInvestments = results[4] as List;
    final goals = results[5] as List;

    final monthlyIncome = (summary['totalIncome'] as num?)?.toDouble() ?? 0;
    final monthlyExpenses = (summary['totalExpenses'] as num?)?.toDouble() ?? 0;
    final availableBalance = monthlyIncome - monthlyExpenses;

    // Build recent transactions from latest investments
    final recentTransactions = recentInvestments.take(5).map((inv) {
      final i = inv as dynamic;
      return {
        'id': i.id,
        'name': i.name,
        'type': 'INVESTIMENTO',
        'amount': i.currentAmount,
        'date': i.investmentDate.toIso8601String(),
      };
    }).toList();

    // Build upcoming maturities list
    final upcomingMaturities = maturities.take(5).map((inv) {
      final i = inv as dynamic;
      return {
        'id': i.id,
        'name': i.name,
        'type': i.type,
        'amount': i.currentAmount,
        'maturityDate': i.maturityDate?.toIso8601String(),
      };
    }).toList();

    // Build goal summaries
    final goalSummaries = goals.take(3).map((g) {
      final goal = g as dynamic;
      return {
        'id': goal.id,
        'name': goal.name,
        'progress': goal.progressPercent,
        'targetAmount': goal.targetAmount,
        'currentAmount': goal.currentAmount,
      };
    }).toList();

    return DashboardData(
      totalPatrimony: totalInvested + availableBalance,
      totalInvested: totalInvested,
      availableBalance: availableBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      portfolioDistribution: distribution,
      recentTransactions: recentTransactions,
      upcomingMaturities: upcomingMaturities,
      evolutionData: [],
      monthlySummary: {
        ...summary,
        'goals': goalSummaries,
      },
    );
  }
}
