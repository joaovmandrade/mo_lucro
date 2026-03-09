import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/calculator_datasource.dart';

class CalculatorState {
  final bool isLoading;
  final Map<String, dynamic>? simulationResult;
  final Map<String, dynamic>? cdbComparison;
  final Map<String, dynamic>? taxEstimate;
  final String? error;

  const CalculatorState({this.isLoading = false, this.simulationResult, this.cdbComparison, this.taxEstimate, this.error});

  CalculatorState copyWith({
    bool? isLoading,
    Map<String, dynamic>? simulationResult,
    Map<String, dynamic>? cdbComparison,
    Map<String, dynamic>? taxEstimate,
    String? error,
  }) {
    return CalculatorState(
      isLoading: isLoading ?? this.isLoading,
      simulationResult: simulationResult ?? this.simulationResult,
      cdbComparison: cdbComparison ?? this.cdbComparison,
      taxEstimate: taxEstimate ?? this.taxEstimate,
      error: error,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final CalculatorDataSource _dataSource;

  CalculatorNotifier(this._dataSource) : super(const CalculatorState());

  Future<void> simulate({
    required double initialAmount,
    required double monthlyContribution,
    required int months,
    required double annualRate,
    double? inflationRate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.simulateCompoundInterest({
        'initialAmount': initialAmount,
        'monthlyContribution': monthlyContribution,
        'months': months,
        'annualRate': annualRate,
        if (inflationRate != null) 'inflationRate': inflationRate,
      });
      state = state.copyWith(isLoading: false, simulationResult: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro na simulação');
    }
  }

  Future<void> compareCDBs(List<Map<String, dynamic>> options) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.compareCDBs(options);
      state = state.copyWith(isLoading: false, cdbComparison: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro na comparação');
    }
  }

  Future<void> estimateTax({
    required double investedAmount,
    required double currentAmount,
    required int holdingDays,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.estimateIncomeTax({
        'investedAmount': investedAmount,
        'currentAmount': currentAmount,
        'holdingDays': holdingDays,
      });
      state = state.copyWith(isLoading: false, taxEstimate: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro na estimativa');
    }
  }

  void clearResults() {
    state = const CalculatorState();
  }
}

final calculatorDataSourceProvider = Provider((_) => CalculatorDataSource());

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier(ref.read(calculatorDataSourceProvider));
});
