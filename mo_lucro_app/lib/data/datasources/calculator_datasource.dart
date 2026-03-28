import 'dart:async';

/// Mock offline data source for calculators.
class CalculatorDataSource {
  Future<Map<String, dynamic>> simulateCompoundInterest(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final principal = data['principal'] as num? ?? 1000;
    final rate = data['rate'] as num? ?? 10;
    final periods = data['periods'] as num? ?? 12;

    double amount = principal * (1 + rate / 100);
    for(int i = 1; i < periods; i++) {
        amount *= (1 + rate / 100);
    }
    
    return {
      'finalAmount': amount,
      'totalInvested': principal,
      'totalInterest': amount - principal,
      'chartData': [] // Mock empty chart data
    };
  }

  Future<Map<String, dynamic>> compareCDBs(List<Map<String, dynamic>> options) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'bestOptionIndex': 0,
      'comparisons': options.map((o) => {
        'name': o['name'] ?? 'CDB',
        'finalAmount': 1500.0,
        'netProfit': 500.0
      }).toList(),
    };
  }

  Future<Map<String, dynamic>> estimateIncomeTax(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'estimatedTax': 250.0,
      'effectiveRate': 15.0,
      'netIncome': 5000.0,
    };
  }
}
