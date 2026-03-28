/// Investment model representing a financial asset.
class Investment {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String? symbol;
  final double initialAmount;
  final double currentAmount;
  final DateTime investmentDate;
  final DateTime? maturityDate;
  final double? contractedRate;
  final String indexer;
  final String? institution;
  final String liquidity;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Investment({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.symbol,
    required this.initialAmount,
    required this.currentAmount,
    required this.investmentDate,
    this.maturityDate,
    this.contractedRate,
    this.indexer = 'NENHUM',
    this.institution,
    this.liquidity = 'DIARIA',
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investment.fromRow(Map<String, dynamic> row) {
    return Investment(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      name: row['name'] as String,
      type: row['type'] as String,
      symbol: row['symbol'] as String?,
      initialAmount: _toDouble(row['initial_amount']),
      currentAmount: _toDouble(row['current_amount']),
      investmentDate: DateTime.parse(row['investment_date'].toString()),
      maturityDate: row['maturity_date'] != null
          ? DateTime.parse(row['maturity_date'].toString())
          : null,
      contractedRate: row['contracted_rate'] != null
          ? _toDouble(row['contracted_rate'])
          : null,
      indexer: row['indexer'] as String? ?? 'NENHUM',
      institution: row['institution'] as String?,
      liquidity: row['liquidity'] as String? ?? 'DIARIA',
      notes: row['notes'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(row['created_at'].toString()),
      updatedAt: DateTime.parse(row['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'symbol': symbol,
      'initialAmount': initialAmount,
      'currentAmount': currentAmount,
      'investmentDate': investmentDate.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'contractedRate': contractedRate,
      'indexer': indexer,
      'institution': institution,
      'liquidity': liquidity,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }
}
