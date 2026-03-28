import 'dart:async';

/// Mock offline data source for reports API.
class ReportDataSource {
  Future<Map<String, dynamic>> getRiskAnalysis() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'overallRiskScore': 4.5, // 1 a 10
      'riskLevel': 'BAIXO_MODERADO',
      'volatilityEstimate': '5.2%',
      'recommendations': [
        'Sua carteira está concentrada em renda fixa.',
        'Considere diversificar com fundos imobiliários para gerar renda passiva.'
      ]
    };
  }

  Future<Map<String, dynamic>> getDiversification() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'totalInvested': 7000.00,
      'byType': [
        {'type': 'FIXED_INCOME', 'amount': 5000.00, 'percentage': 71.4},
        {'type': 'REAL_ESTATE', 'amount': 2000.00, 'percentage': 28.6},
      ],
      'byInstitution': [
        {'name': 'Tesouro Direto', 'amount': 5000.00, 'percentage': 71.4},
        {'name': 'BTG Pactual', 'amount': 2000.00, 'percentage': 28.6},
      ]
    };
  }

  Future<List<dynamic>> getMaturities() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'id': 'm1',
        'investmentName': 'CDB Banco Inter',
        'amount': 1000.00,
        'maturityDate': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
      },
      {
        'id': 'm2',
        'investmentName': 'LCI Caixa',
        'amount': 3500.00,
        'maturityDate': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
      }
    ];
  }
}
