import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/dashboard_datasource.dart';

/// Dashboard state.
class DashboardState {
  final bool isLoading;
  final Map<String, dynamic>? data;
  final String? error;

  const DashboardState({this.isLoading = false, this.data, this.error});

  DashboardState copyWith({bool? isLoading, Map<String, dynamic>? data, String? error}) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardDataSource _dataSource;

  DashboardNotifier(this._dataSource) : super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _dataSource.getDashboard();
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar dashboard');
    }
  }

  Future<void> refresh() => loadDashboard();
}

final dashboardDataSourceProvider = Provider((_) => DashboardDataSource());

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.read(dashboardDataSourceProvider));
});
