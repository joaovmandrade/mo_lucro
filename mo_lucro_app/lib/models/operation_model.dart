class OperationModel {
  final String id;
  final String userId;
  final String type; // 'buy' | 'sell'
  final String asset;
  final String category; // 'stocks' | 'crypto' | 'fixed_income' | 'others'
  final double quantity;
  final double price;
  final double total;
  final DateTime date;

  const OperationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.asset,
    required this.category,
    required this.quantity,
    required this.price,
    required this.total,
    required this.date,
  });

  factory OperationModel.fromMap(Map<String, dynamic> map) {
    return OperationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String,
      asset: (map['asset'] as String).toUpperCase(),
      category: (map['category'] as String? ?? 'others'),
      quantity: (map['quantity'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'type': type,
        'asset': asset.toUpperCase(),
        'category': category,
        'quantity': quantity,
        'price': price,
        'total': total,
        'date': date.toIso8601String(),
      };

  @override
  String toString() =>
      'OperationModel(id: $id, asset: $asset, type: $type, quantity: $quantity, price: $price)';
}
