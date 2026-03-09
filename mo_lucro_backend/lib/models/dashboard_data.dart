/// Dashboard aggregated data model.
class DashboardData {
  final double totalPatrimony;
  final double totalInvested;
  final double availableBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final Map<String, double> portfolioDistribution;
  final List<Map<String, dynamic>> recentTransactions;
  final List<Map<String, dynamic>> upcomingMaturities;
  final List<Map<String, dynamic>> evolutionData;
  final Map<String, dynamic> monthlySummary;

  const DashboardData({
    required this.totalPatrimony,
    required this.totalInvested,
    required this.availableBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.portfolioDistribution,
    required this.recentTransactions,
    required this.upcomingMaturities,
    required this.evolutionData,
    required this.monthlySummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPatrimony': totalPatrimony,
      'totalInvested': totalInvested,
      'availableBalance': availableBalance,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'portfolioDistribution': portfolioDistribution,
      'recentTransactions': recentTransactions,
      'upcomingMaturities': upcomingMaturities,
      'evolutionData': evolutionData,
      'monthlySummary': monthlySummary,
    };
  }
}

/// Simulation result for compound interest calculator.
class SimulationResult {
  final double totalInvested;
  final double grossAmount;
  final double estimatedProfit;
  final double estimatedTax;
  final double netAmount;
  final List<Map<String, dynamic>> monthlyEvolution;

  const SimulationResult({
    required this.totalInvested,
    required this.grossAmount,
    required this.estimatedProfit,
    required this.estimatedTax,
    required this.netAmount,
    required this.monthlyEvolution,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalInvested': totalInvested,
      'grossAmount': grossAmount,
      'estimatedProfit': estimatedProfit,
      'estimatedTax': estimatedTax,
      'netAmount': netAmount,
      'monthlyEvolution': monthlyEvolution,
    };
  }
}
