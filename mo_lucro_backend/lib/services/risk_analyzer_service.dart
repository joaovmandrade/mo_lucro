import '../repositories/investment_repository.dart';

/// Service for portfolio risk analysis.
class RiskAnalyzerService {
  final InvestmentRepository _investmentRepo;

  RiskAnalyzerService(this._investmentRepo);

  // Asset classification
  static const _rendaFixa = {
    'CDB', 'TESOURO_DIRETO', 'POUPANCA', 'CAIXA'
  };
  static const _rendaVariavel = {
    'ACOES', 'FUNDOS_IMOBILIARIOS', 'CRIPTO'
  };

  /// Analyze portfolio risk.
  Future<Map<String, dynamic>> analyzeRisk(String userId) async {
    final distribution = await _investmentRepo.getPortfolioDistribution(userId);
    final totalInvested = await _investmentRepo.getTotalInvested(userId);
    final investments = await _investmentRepo.findByUserId(userId, limit: 100);

    if (totalInvested == 0) {
      return {
        'riskLevel': 'INDEFINIDO',
        'riskScore': 0,
        'observations': ['Você ainda não possui investimentos cadastrados.'],
        'suggestions': ['Comece cadastrando seus investimentos para uma análise completa.'],
        'alerts': [],
        'distribution': {},
      };
    }

    // Calculate fixed vs variable income percentages
    double fixedIncomeTotal = 0;
    double variableIncomeTotal = 0;
    double othersTotal = 0;

    for (final entry in distribution.entries) {
      if (_rendaFixa.contains(entry.key)) {
        fixedIncomeTotal += entry.value;
      } else if (_rendaVariavel.contains(entry.key)) {
        variableIncomeTotal += entry.value;
      } else {
        othersTotal += entry.value;
      }
    }

    final fixedPct = (fixedIncomeTotal / totalInvested) * 100;
    final variablePct = (variableIncomeTotal / totalInvested) * 100;

    // Calculate risk score (0-100)
    var riskScore = variablePct.toInt();

    // Check concentration
    final alerts = <String>[];
    final suggestions = <String>[];
    final observations = <String>[];

    // Check single asset concentration
    for (final entry in distribution.entries) {
      final pct = (entry.value / totalInvested) * 100;
      if (pct > 40) {
        alerts.add(
          'Alta concentração em ${_translateType(entry.key)} '
          '(${pct.toStringAsFixed(1)}%). Considere diversificar.',
        );
        riskScore += 10;
      }
    }

    // Liquidity analysis
    final lowLiquidityCount = investments.where(
      (i) => i.liquidity == 'NO_VENCIMENTO',
    ).length;
    if (lowLiquidityCount > investments.length * 0.6) {
      alerts.add(
        'Mais de 60% dos seus investimentos têm liquidez apenas '
        'no vencimento. Mantenha uma reserva com liquidez diária.',
      );
      riskScore += 5;
    }

    // Determine risk level
    String riskLevel;
    if (riskScore <= 30) {
      riskLevel = 'CONSERVADOR';
      observations.add('Sua carteira tem perfil conservador.');
      observations.add('${fixedPct.toStringAsFixed(1)}% em renda fixa.');
    } else if (riskScore <= 60) {
      riskLevel = 'MODERADO';
      observations.add('Sua carteira tem perfil moderado.');
      observations.add('Mix de ${fixedPct.toStringAsFixed(1)}% renda fixa e '
          '${variablePct.toStringAsFixed(1)}% renda variável.');
    } else {
      riskLevel = 'ARROJADO';
      observations.add('Sua carteira tem perfil arrojado.');
      observations.add('${variablePct.toStringAsFixed(1)}% em renda variável.');
    }

    // Generate suggestions
    if (variablePct > 70) {
      suggestions.add(
        'Considere aumentar a alocação em renda fixa para maior estabilidade.',
      );
    }
    if (fixedPct > 90) {
      suggestions.add(
        'Diversificar com uma pequena parcela em renda variável pode '
        'aumentar a rentabilidade no longo prazo.',
      );
    }
    if (!distribution.containsKey('CAIXA') &&
        !distribution.containsKey('POUPANCA')) {
      suggestions.add(
        'Mantenha uma reserva de emergência em ativos de alta liquidez.',
      );
    }

    return {
      'riskLevel': riskLevel,
      'riskScore': riskScore > 100 ? 100 : riskScore,
      'fixedIncomePercent': double.parse(fixedPct.toStringAsFixed(1)),
      'variableIncomePercent': double.parse(variablePct.toStringAsFixed(1)),
      'observations': observations,
      'suggestions': suggestions,
      'alerts': alerts,
      'distribution': distribution.map(
        (k, v) => MapEntry(k, {
          'amount': v,
          'percent': double.parse(
            ((v / totalInvested) * 100).toStringAsFixed(1),
          ),
        }),
      ),
    };
  }

  /// Get diversification breakdown.
  Future<Map<String, dynamic>> getDiversification(String userId) async {
    final investments = await _investmentRepo.findByUserId(userId, limit: 200);
    final totalInvested = await _investmentRepo.getTotalInvested(userId);

    if (totalInvested == 0) {
      return {
        'byType': {},
        'byInstitution': {},
        'byIndexer': {},
        'byLiquidity': {},
      };
    }

    // By type
    final byType = <String, double>{};
    final byInstitution = <String, double>{};
    final byIndexer = <String, double>{};
    final byLiquidity = <String, double>{};

    for (final inv in investments) {
      byType[inv.type] = (byType[inv.type] ?? 0) + inv.currentAmount;

      final inst = inv.institution ?? 'Não informado';
      byInstitution[inst] = (byInstitution[inst] ?? 0) + inv.currentAmount;

      byIndexer[inv.indexer] =
          (byIndexer[inv.indexer] ?? 0) + inv.currentAmount;

      byLiquidity[inv.liquidity] =
          (byLiquidity[inv.liquidity] ?? 0) + inv.currentAmount;
    }

    // Convert to percentages
    Map<String, dynamic> toPercent(Map<String, double> map) {
      return map.map((k, v) => MapEntry(k, {
            'amount': v,
            'percent': double.parse(
              ((v / totalInvested) * 100).toStringAsFixed(1),
            ),
          }));
    }

    return {
      'totalInvested': totalInvested,
      'byType': toPercent(byType),
      'byInstitution': toPercent(byInstitution),
      'byIndexer': toPercent(byIndexer),
      'byLiquidity': toPercent(byLiquidity),
    };
  }

  /// Get upcoming maturities.
  Future<List<Map<String, dynamic>>> getMaturities(String userId) async {
    final maturities = await _investmentRepo.getUpcomingMaturities(userId);
    return maturities.map((inv) {
      final daysToMaturity = inv.maturityDate != null
          ? inv.maturityDate!.difference(DateTime.now()).inDays
          : null;

      String? suggestion;
      if (daysToMaturity != null && daysToMaturity <= 30) {
        suggestion = 'Vencimento em breve! Planeje o reinvestimento.';
      } else if (daysToMaturity != null && daysToMaturity <= 7) {
        suggestion = '⚠️ Vencendo esta semana!';
      }

      return {
        ...inv.toJson(),
        'daysToMaturity': daysToMaturity,
        'suggestion': suggestion,
      };
    }).toList();
  }

  String _translateType(String type) {
    const translations = {
      'CDB': 'CDB',
      'TESOURO_DIRETO': 'Tesouro Direto',
      'POUPANCA': 'Poupança',
      'ACOES': 'Ações',
      'FUNDOS_IMOBILIARIOS': 'Fundos Imobiliários',
      'FUNDOS': 'Fundos',
      'CRIPTO': 'Criptomoedas',
      'CAIXA': 'Caixa',
      'OUTROS': 'Outros',
    };
    return translations[type] ?? type;
  }
}
