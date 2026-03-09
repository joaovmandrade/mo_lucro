import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/expense_datasource.dart';

class ExpenseState {
  final bool isLoading;
  final List<Map<String, dynamic>> expenses;
  final Map<String, dynamic>? summary;
  final String? error;

  const ExpenseState({this.isLoading = false, this.expenses = const [], this.summary, this.error});

  ExpenseState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? expenses,
    Map<String, dynamic>? summary,
    String? error,
  }) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      summary: summary ?? this.summary,
      error: error,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseDataSource _dataSource;

  ExpenseNotifier(this._dataSource) : super(const ExpenseState());

  Future<void> loadExpenses({String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.getExpenses(type: type);
      final items = (result['expenses'] as List?)
          ?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      state = state.copyWith(isLoading: false, expenses: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar lançamentos');
    }
  }

  Future<void> loadSummary({int? year, int? month}) async {
    try {
      final summary = await _dataSource.getSummary(year: year, month: month);
      state = state.copyWith(summary: summary);
    } catch (_) {}
  }

  Future<bool> createExpense(Map<String, dynamic> data) async {
    try {
      await _dataSource.createExpense(data);
      await loadExpenses();
      await loadSummary();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _dataSource.deleteExpense(id);
      await loadExpenses();
      await loadSummary();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final expenseDataSourceProvider = Provider((_) => ExpenseDataSource());

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  return ExpenseNotifier(ref.read(expenseDataSourceProvider));
});
