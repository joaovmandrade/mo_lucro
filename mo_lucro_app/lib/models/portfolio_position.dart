/// Represents a consolidated portfolio position for a single asset.
class PortfolioPosition {
  final String asset;
  final String category;
  final double quantity;
  final double totalInvested;
  final double avgPrice;

  const PortfolioPosition({
    required this.asset,
    required this.category,
    required this.quantity,
    required this.totalInvested,
    required this.avgPrice,
  });

  /// Since we don't have live prices, using avgPrice as current (0% P&L baseline)
  /// Replace [currentPrice] with a live API value when available.
  double profitLoss(double currentPrice) =>
      (currentPrice - avgPrice) * quantity;

  double profitLossPercent(double currentPrice) =>
      avgPrice > 0 ? ((currentPrice - avgPrice) / avgPrice) * 100 : 0;

  double currentValue(double currentPrice) => currentPrice * quantity;

  @override
  String toString() =>
      'PortfolioPosition(asset: $asset, qty: $quantity, avg: $avgPrice, invested: $totalInvested)';
}
