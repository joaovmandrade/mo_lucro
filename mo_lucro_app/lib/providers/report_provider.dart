import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/report_datasource.dart';

class ReportState {
  final bool isLoading;
  final Map<String, dynamic>? riskAnalysis;
  final Map<String, dynamic>? diversification;
  final List<Map<String, dynamic>> maturities;
  final String? error;

  const ReportState({
    this.isLoading = false,
    this.riskAnalysis,
    this.diversification,
    this.maturities = const [],
    this.error,
  });

  ReportState copyWith({
    bool? isLoading,
    Map<String, dynamic>? riskAnalysis,
    Map<String, dynamic>? diversification,
    List<Map<String, dynamic>>? maturities,
    String? error,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      riskAnalysis: riskAnalysis ?? this.riskAnalysis,
      diversification: diversification ?? this.diversification,
      maturities: maturities ?? this.maturities,
      error: error,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportDataSource _dataSource;

  ReportNotifier(this._dataSource) : super(const ReportState());

  Future<void> loadRiskAnalysis() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _dataSource.getRiskAnalysis();
      state = state.copyWith(isLoading: false, riskAnalysis: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar análise de risco');
    }
  }

  Future<void> loadDiversification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _dataSource.getDiversification();
      state = state.copyWith(isLoading: false, diversification: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro na diversificação');
    }
  }

  Future<void> loadMaturities() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _dataSource.getMaturities();
      final items = data.map((m) => m as Map<String, dynamic>).toList();
      state = state.copyWith(isLoading: false, maturities: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar vencimentos');
    }
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _dataSource.getRiskAnalysis(),
        _dataSource.getDiversification(),
        _dataSource.getMaturities(),
      ]);
      state = state.copyWith(
        isLoading: false,
        riskAnalysis: results[0] as Map<String, dynamic>,
        diversification: results[1] as Map<String, dynamic>,
        maturities: (results[2] as List).map((m) => m as Map<String, dynamic>).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar relatórios');
    }
  }
}

final reportDataSourceProvider = Provider((_) => ReportDataSource());

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.read(reportDataSourceProvider));
});
