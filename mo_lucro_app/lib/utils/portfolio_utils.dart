import '../models/operation_model.dart';
import '../models/portfolio_position.dart';

/// Calculates portfolio positions from a list of operations.
/// Handles buy/sell with average price correction.
Map<String, PortfolioPosition> calculatePortfolio(
    List<OperationModel> operations) {
  final Map<String, _MutablePosition> mutable = {};

  // Process oldest first for correct avg price calculation
  final sorted = List<OperationModel>.from(operations)
    ..sort((a, b) => a.date.compareTo(b.date));

  for (final op in sorted) {
    mutable.putIfAbsent(
      op.asset,
      () => _MutablePosition(asset: op.asset, category: op.category),
    );

    final pos = mutable[op.asset]!;

    if (op.type == 'buy') {
      final newQty = pos.quantity + op.quantity;
      final newTotal = pos.totalInvested + op.total;
      pos.quantity = newQty;
      pos.totalInvested = newTotal;
    } else if (op.type == 'sell') {
      if (pos.quantity > 0) {
        final avgPrice = pos.totalInvested / pos.quantity;
        pos.quantity = (pos.quantity - op.quantity).clamp(0, double.infinity);
        pos.totalInvested =
            (pos.totalInvested - (avgPrice * op.quantity)).clamp(0, double.infinity);
      }
    }
  }

  // Build immutable result, filtering out zeroed positions
  final Map<String, PortfolioPosition> result = {};
  for (final entry in mutable.entries) {
    if (entry.value.quantity > 0.0001) {
      final qty = entry.value.quantity;
      final total = entry.value.totalInvested;
      result[entry.key] = PortfolioPosition(
        asset: entry.key,
        category: entry.value.category,
        quantity: qty,
        totalInvested: total,
        avgPrice: qty > 0 ? total / qty : 0,
      );
    }
  }
  return result;
}

/// Calculates total invested across all positions.
double totalInvested(Map<String, PortfolioPosition> portfolio) {
  return portfolio.values.fold(0.0, (sum, p) => sum + p.totalInvested);
}

/// Calculates distribution by category as percentages.
Map<String, double> categoryDistribution(Map<String, PortfolioPosition> portfolio) {
  final Map<String, double> categories = {};
  double total = 0;

  for (final pos in portfolio.values) {
    categories[pos.category] = (categories[pos.category] ?? 0) + pos.totalInvested;
    total += pos.totalInvested;
  }

  if (total == 0) return {};

  return categories.map((key, value) => MapEntry(key, value / total * 100));
}

class _MutablePosition {
  final String asset;
  final String category;
  double quantity;
  double totalInvested;

  _MutablePosition({
    required this.asset,
    required this.category,
  })  : quantity = 0,
        totalInvested = 0;
}
