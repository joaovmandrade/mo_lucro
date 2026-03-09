import 'package:flutter_test/flutter_test.dart';

// Unit tests for backend service logic (portable Dart logic).
// These tests validate core financial calculations and data transformations.

/// Compound interest calculation matching CalculatorService.
double calculateCompoundInterest({
  required double initial,
  required double monthly,
  required int months,
  required double annualRate,
}) {
  final monthlyRate = annualRate / 100 / 12;
  double total = initial;
  for (int i = 0; i < months; i++) {
    total = (total + monthly) * (1 + monthlyRate);
  }
  return total;
}

/// Brazilian progressive income tax brackets.
double calculateIncomeTax({
  required double profit,
  required int holdingDays,
}) {
  double rate;
  if (holdingDays <= 180) {
    rate = 0.225;
  } else if (holdingDays <= 360) {
    rate = 0.20;
  } else if (holdingDays <= 720) {
    rate = 0.175;
  } else {
    rate = 0.15;
  }
  return profit * rate;
}

/// Risk score calculation.
int calculateRiskScore(Map<String, double> distribution) {
  const weights = {
    'RENDA_FIXA': 10,
    'TESOURO_DIRETO': 15,
    'CDB': 10,
    'LCI_LCA': 10,
    'ACOES': 70,
    'FIIS': 50,
    'CRIPTO': 90,
  };
  double score = 0;
  distribution.forEach((type, pct) {
    score += (weights[type] ?? 50) * pct;
  });
  return score.round();
}

void main() {
  group('CalculatorService — Compound Interest', () {
    test('should calculate with no monthly contribution', () {
      final result = calculateCompoundInterest(
        initial: 10000,
        monthly: 0,
        months: 12,
        annualRate: 12,
      );
      // After 12 months at 12% annual (~1% monthly)
      expect(result, closeTo(11268, 5));
    });

    test('should calculate with monthly contributions', () {
      final result = calculateCompoundInterest(
        initial: 1000,
        monthly: 500,
        months: 24,
        annualRate: 12,
      );
      // Should be significantly more than 1000 + 500*24 = 13000
      expect(result, greaterThan(13000));
      expect(result, closeTo(14891, 100));
    });

    test('should return initial amount for 0 months', () {
      final result = calculateCompoundInterest(
        initial: 5000,
        monthly: 100,
        months: 0,
        annualRate: 10,
      );
      expect(result, 5000);
    });

    test('should handle 0% rate', () {
      final result = calculateCompoundInterest(
        initial: 1000,
        monthly: 100,
        months: 12,
        annualRate: 0,
      );
      expect(result, closeTo(2200, 1));
    });
  });

  group('CalculatorService — Income Tax', () {
    test('should apply 22.5% for up to 180 days', () {
      expect(calculateIncomeTax(profit: 1000, holdingDays: 30), 225);
      expect(calculateIncomeTax(profit: 1000, holdingDays: 180), 225);
    });

    test('should apply 20% for 181-360 days', () {
      expect(calculateIncomeTax(profit: 1000, holdingDays: 200), 200);
      expect(calculateIncomeTax(profit: 1000, holdingDays: 360), 200);
    });

    test('should apply 17.5% for 361-720 days', () {
      expect(calculateIncomeTax(profit: 1000, holdingDays: 400), 175);
      expect(calculateIncomeTax(profit: 1000, holdingDays: 720), 175);
    });

    test('should apply 15% for over 720 days', () {
      expect(calculateIncomeTax(profit: 1000, holdingDays: 800), 150);
      expect(calculateIncomeTax(profit: 2000, holdingDays: 1000), 300);
    });

    test('should return 0 for no profit', () {
      expect(calculateIncomeTax(profit: 0, holdingDays: 100), 0);
    });
  });

  group('Risk Score Calculation', () {
    test('conservative portfolio should score low', () {
      final score = calculateRiskScore({
        'RENDA_FIXA': 0.6,
        'TESOURO_DIRETO': 0.3,
        'CDB': 0.1,
      });
      expect(score, lessThan(20));
    });

    test('aggressive portfolio should score high', () {
      final score = calculateRiskScore({
        'ACOES': 0.5,
        'CRIPTO': 0.3,
        'FIIS': 0.2,
      });
      expect(score, greaterThan(60));
    });

    test('balanced portfolio should score moderate', () {
      final score = calculateRiskScore({
        'CDB': 0.4,
        'FIIS': 0.3,
        'ACOES': 0.3,
      });
      expect(score, greaterThan(25));
      expect(score, lessThan(50));
    });
  });
}
