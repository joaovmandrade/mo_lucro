import 'dart:math';
import '../models/dashboard_data.dart';

/// Financial calculator service.
/// Handles compound interest simulation, CDB comparison, and income tax estimation.
class CalculatorService {
  /// Simulate compound interest with recurring contributions.
  SimulationResult simulateCompoundInterest({
    required double initialAmount,
    required double monthlyContribution,
    required int months,
    required double annualRate,
    double? inflationRate,
  }) {
    final monthlyRate = pow(1 + annualRate / 100, 1 / 12) - 1;
    final monthlyInflation = inflationRate != null
        ? pow(1 + inflationRate / 100, 1 / 12) - 1
        : 0.0;

    double balance = initialAmount;
    double totalInvested = initialAmount;
    final monthlyEvolution = <Map<String, dynamic>>[];

    for (int i = 1; i <= months; i++) {
      balance = balance * (1 + monthlyRate) + monthlyContribution;
      totalInvested += monthlyContribution;

      final grossProfit = balance - totalInvested;
      final taxRate = _getIncomeTaxRate(i * 30); // approximate days
      final estimatedTax = grossProfit > 0 ? grossProfit * taxRate : 0.0;
      final netAmount = balance - estimatedTax;

      // Adjust for inflation if provided
      final realValue = inflationRate != null
          ? balance / pow(1 + monthlyInflation, i)
          : balance;

      monthlyEvolution.add({
        'month': i,
        'grossAmount': double.parse(balance.toStringAsFixed(2)),
        'totalInvested': double.parse(totalInvested.toStringAsFixed(2)),
        'grossProfit': double.parse(grossProfit.toStringAsFixed(2)),
        'netAmount': double.parse(netAmount.toStringAsFixed(2)),
        'realValue': double.parse(realValue.toStringAsFixed(2)),
      });
    }

    final grossProfit = balance - totalInvested;
    final taxRate = _getIncomeTaxRate(months * 30);
    final estimatedTax = grossProfit > 0 ? grossProfit * taxRate : 0.0;

    return SimulationResult(
      totalInvested: double.parse(totalInvested.toStringAsFixed(2)),
      grossAmount: double.parse(balance.toStringAsFixed(2)),
      estimatedProfit: double.parse(grossProfit.toStringAsFixed(2)),
      estimatedTax: double.parse(estimatedTax.toStringAsFixed(2)),
      netAmount: double.parse((balance - estimatedTax).toStringAsFixed(2)),
      monthlyEvolution: monthlyEvolution,
    );
  }

  /// Compare CDB options.
  List<Map<String, dynamic>> compareCDBs(List<Map<String, dynamic>> options) {
    final results = <Map<String, dynamic>>[];

    for (final option in options) {
      final bank = option['bank'] as String? ?? 'Banco';
      final cdiPercent = (option['cdiPercent'] as num).toDouble();
      final months = option['months'] as int? ?? 12;
      final initialAmount = (option['initialAmount'] as num?)?.toDouble() ?? 1000;
      final cdiRate = option['cdiRate'] as num? ?? 13.25; // current CDI

      // Calculate annual rate from CDI percentage
      final annualRate = (cdiPercent / 100) * cdiRate.toDouble();
      final monthlyRate = pow(1 + annualRate / 100, 1 / 12) - 1;

      // Calculate gross amount
      final grossAmount = initialAmount * pow(1 + monthlyRate, months);
      final grossProfit = grossAmount - initialAmount;

      // Calculate income tax
      final days = months * 30;
      final taxRate = _getIncomeTaxRate(days);
      final tax = grossProfit * taxRate;
      final netProfit = grossProfit - tax;
      final netAmount = initialAmount + netProfit;

      results.add({
        'bank': bank,
        'cdiPercent': cdiPercent,
        'months': months,
        'initialAmount': initialAmount,
        'grossAmount': double.parse(grossAmount.toStringAsFixed(2)),
        'grossProfit': double.parse(grossProfit.toStringAsFixed(2)),
        'taxRate': double.parse((taxRate * 100).toStringAsFixed(1)),
        'estimatedTax': double.parse(tax.toStringAsFixed(2)),
        'netProfit': double.parse(netProfit.toStringAsFixed(2)),
        'netAmount': double.parse(netAmount.toStringAsFixed(2)),
        'effectiveRate': double.parse(
          ((netProfit / initialAmount) * 100).toStringAsFixed(2),
        ),
      });
    }

    // Sort by net profit descending
    results.sort((a, b) =>
        (b['netProfit'] as double).compareTo(a['netProfit'] as double));

    // Add ranking
    for (int i = 0; i < results.length; i++) {
      results[i]['ranking'] = i + 1;
      results[i]['isBest'] = i == 0;
    }

    return results;
  }

  /// Estimate income tax for a fixed income investment.
  Map<String, dynamic> estimateIncomeTax({
    required double investedAmount,
    required double currentAmount,
    required int holdingDays,
  }) {
    final profit = currentAmount - investedAmount;
    if (profit <= 0) {
      return {
        'investedAmount': investedAmount,
        'currentAmount': currentAmount,
        'profit': 0.0,
        'taxRate': 0.0,
        'estimatedTax': 0.0,
        'netAmount': currentAmount,
        'netProfit': 0.0,
        'holdingDays': holdingDays,
        'bracket': _getTaxBracketName(holdingDays),
        'disclaimer':
            '⚠️ Este cálculo é uma simulação educativa. Consulte um contador para valores oficiais.',
      };
    }

    final taxRate = _getIncomeTaxRate(holdingDays);
    final tax = profit * taxRate;
    final netProfit = profit - tax;

    return {
      'investedAmount': investedAmount,
      'currentAmount': currentAmount,
      'profit': double.parse(profit.toStringAsFixed(2)),
      'taxRate': double.parse((taxRate * 100).toStringAsFixed(1)),
      'estimatedTax': double.parse(tax.toStringAsFixed(2)),
      'netAmount': double.parse((currentAmount - tax).toStringAsFixed(2)),
      'netProfit': double.parse(netProfit.toStringAsFixed(2)),
      'holdingDays': holdingDays,
      'bracket': _getTaxBracketName(holdingDays),
      'disclaimer':
          '⚠️ Este cálculo é uma simulação educativa. Consulte um contador para valores oficiais.',
    };
  }

  /// Calculate yield for different rates.
  Map<String, dynamic> calculateYield({
    required double amount,
    required int months,
    required String yieldType,
    required double rate,
    double? cdiRate,
    double? ipcaRate,
  }) {
    double annualRate;

    switch (yieldType) {
      case 'CDI':
        annualRate = (rate / 100) * (cdiRate ?? 13.25);
        break;
      case 'IPCA':
        annualRate = (ipcaRate ?? 4.5) + rate;
        break;
      case 'PREFIXADO':
        annualRate = rate;
        break;
      default:
        annualRate = rate;
    }

    final monthlyRate = pow(1 + annualRate / 100, 1 / 12) - 1;
    final grossAmount = amount * pow(1 + monthlyRate, months);
    final profit = grossAmount - amount;
    final days = months * 30;
    final taxRate = _getIncomeTaxRate(days);
    final tax = profit * taxRate;

    return {
      'invested': amount,
      'months': months,
      'yieldType': yieldType,
      'rate': rate,
      'effectiveAnnualRate': double.parse(annualRate.toStringAsFixed(2)),
      'grossAmount': double.parse(grossAmount.toStringAsFixed(2)),
      'grossProfit': double.parse(profit.toStringAsFixed(2)),
      'taxRate': double.parse((taxRate * 100).toStringAsFixed(1)),
      'estimatedTax': double.parse(tax.toStringAsFixed(2)),
      'netAmount': double.parse((grossAmount - tax).toStringAsFixed(2)),
      'netProfit': double.parse((profit - tax).toStringAsFixed(2)),
    };
  }

  /// Brazilian income tax regressive rates for fixed income.
  double _getIncomeTaxRate(int holdingDays) {
    if (holdingDays <= 180) return 0.225;  // 22.5%
    if (holdingDays <= 360) return 0.20;   // 20%
    if (holdingDays <= 720) return 0.175;  // 17.5%
    return 0.15;                            // 15%
  }

  String _getTaxBracketName(int holdingDays) {
    if (holdingDays <= 180) return 'Até 180 dias (22,5%)';
    if (holdingDays <= 360) return 'De 181 a 360 dias (20%)';
    if (holdingDays <= 720) return 'De 361 a 720 dias (17,5%)';
    return 'Acima de 720 dias (15%)';
  }
}
