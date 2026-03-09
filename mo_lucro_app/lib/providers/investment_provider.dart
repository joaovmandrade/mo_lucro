import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/investment_datasource.dart';

class InvestmentState {
  final bool isLoading;
  final List<Map<String, dynamic>> investments;
  final Map<String, dynamic>? pagination;
  final String? error;
  final String? selectedType;

  const InvestmentState({
    this.isLoading = false,
    this.investments = const [],
    this.pagination,
    this.error,
    this.selectedType,
  });

  InvestmentState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? investments,
    Map<String, dynamic>? pagination,
    String? error,
    String? selectedType,
  }) {
    return InvestmentState(
      isLoading: isLoading ?? this.isLoading,
      investments: investments ?? this.investments,
      pagination: pagination ?? this.pagination,
      error: error,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class InvestmentNotifier extends StateNotifier<InvestmentState> {
  final InvestmentDataSource _dataSource;

  InvestmentNotifier(this._dataSource) : super(const InvestmentState());

  Future<void> loadInvestments({String? type, int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null, selectedType: type);
    try {
      final result = await _dataSource.getInvestments(type: type, page: page);
      final items = (result['investments'] as List?)
          ?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      state = state.copyWith(
        isLoading: false,
        investments: items,
        pagination: result['pagination'] as Map<String, dynamic>?,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar investimentos');
    }
  }

  Future<bool> createInvestment(Map<String, dynamic> data) async {
    try {
      await _dataSource.createInvestment(data);
      await loadInvestments(type: state.selectedType);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erro ao criar investimento');
      return false;
    }
  }

  Future<bool> deleteInvestment(String id) async {
    try {
      await _dataSource.deleteInvestment(id);
      await loadInvestments(type: state.selectedType);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addContribution(Map<String, dynamic> data) async {
    try {
      await _dataSource.addContribution(data);
      await loadInvestments(type: state.selectedType);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final investmentDataSourceProvider = Provider((_) => InvestmentDataSource());

final investmentProvider = StateNotifierProvider<InvestmentNotifier, InvestmentState>((ref) {
  return InvestmentNotifier(ref.read(investmentDataSourceProvider));
});
