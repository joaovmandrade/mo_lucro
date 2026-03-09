import '../core/database.dart';
import '../core/exceptions.dart';
import '../models/investment.dart';
import '../models/contribution.dart';

/// Repository for investment data access.
class InvestmentRepository {
  /// Get all investments for a user, with optional type filter.
  Future<List<Investment>> findByUserId(
    String userId, {
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    var sql = 'SELECT * FROM investments WHERE user_id = @userId::uuid AND is_active = TRUE';
    final params = <String, dynamic>{
      'userId': userId,
      'limit': limit,
      'offset': offset,
    };

    if (type != null && type.isNotEmpty) {
      sql += ' AND type = @type::investment_type';
      params['type'] = type;
    }

    sql += ' ORDER BY investment_date DESC LIMIT @limit OFFSET @offset';

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => Investment.fromRow(r.toColumnMap())).toList();
  }

  /// Count total investments for pagination.
  Future<int> countByUserId(String userId, {String? type}) async {
    var sql = 'SELECT COUNT(*) as count FROM investments WHERE user_id = @userId::uuid AND is_active = TRUE';
    final params = <String, dynamic>{'userId': userId};

    if (type != null && type.isNotEmpty) {
      sql += ' AND type = @type::investment_type';
      params['type'] = type;
    }

    final result = await Database.query(sql, parameters: params);
    return result.first.toColumnMap()['count'] as int;
  }

  /// Find investment by ID (with ownership check).
  Future<Investment?> findById(String id, String userId) async {
    final result = await Database.query(
      'SELECT * FROM investments WHERE id = @id::uuid AND user_id = @userId::uuid AND is_active = TRUE',
      parameters: {'id': id, 'userId': userId},
    );
    if (result.isEmpty) return null;
    return Investment.fromRow(result.first.toColumnMap());
  }

  /// Create a new investment.
  Future<Investment> create({
    required String userId,
    required String name,
    required String type,
    required double initialAmount,
    required DateTime investmentDate,
    DateTime? maturityDate,
    double? contractedRate,
    String? indexer,
    String? institution,
    String? liquidity,
    String? notes,
  }) async {
    final result = await Database.query(
      '''
      INSERT INTO investments (
        user_id, name, type, initial_amount, current_amount,
        investment_date, maturity_date, contracted_rate, indexer,
        institution, liquidity, notes
      ) VALUES (
        @userId::uuid, @name, @type::investment_type, @initialAmount, @initialAmount,
        @investmentDate, @maturityDate, @contractedRate, @indexer::indexer_type,
        @institution, @liquidity::liquidity_type, @notes
      ) RETURNING *
      ''',
      parameters: {
        'userId': userId,
        'name': name,
        'type': type,
        'initialAmount': initialAmount,
        'investmentDate': investmentDate.toIso8601String().split('T').first,
        'maturityDate': maturityDate?.toIso8601String().split('T').first,
        'contractedRate': contractedRate,
        'indexer': indexer ?? 'NENHUM',
        'institution': institution,
        'liquidity': liquidity ?? 'DIARIA',
        'notes': notes,
      },
    );
    return Investment.fromRow(result.first.toColumnMap());
  }

  /// Update an investment.
  Future<Investment> update(String id, String userId, Map<String, dynamic> fields) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'id': id, 'userId': userId};

    final fieldMap = {
      'name': 'name = @name',
      'type': 'type = @type::investment_type',
      'initialAmount': 'initial_amount = @initialAmount',
      'currentAmount': 'current_amount = @currentAmount',
      'maturityDate': 'maturity_date = @maturityDate',
      'contractedRate': 'contracted_rate = @contractedRate',
      'indexer': 'indexer = @indexer::indexer_type',
      'institution': 'institution = @institution',
      'liquidity': 'liquidity = @liquidity::liquidity_type',
      'notes': 'notes = @notes',
    };

    for (final entry in fieldMap.entries) {
      if (fields.containsKey(entry.key)) {
        setClauses.add(entry.value);
        params[entry.key] = fields[entry.key];
      }
    }

    if (setClauses.isEmpty) {
      throw const ValidationException('Nenhum campo para atualizar');
    }

    setClauses.add('updated_at = CURRENT_TIMESTAMP');

    final result = await Database.query(
      '''
      UPDATE investments SET ${setClauses.join(', ')}
      WHERE id = @id::uuid AND user_id = @userId::uuid AND is_active = TRUE
      RETURNING *
      ''',
      parameters: params,
    );

    if (result.isEmpty) {
      throw const NotFoundException('Investimento não encontrado');
    }
    return Investment.fromRow(result.first.toColumnMap());
  }

  /// Soft delete an investment.
  Future<void> delete(String id, String userId) async {
    final result = await Database.query(
      '''
      UPDATE investments SET is_active = FALSE, updated_at = CURRENT_TIMESTAMP
      WHERE id = @id::uuid AND user_id = @userId::uuid
      RETURNING id
      ''',
      parameters: {'id': id, 'userId': userId},
    );
    if (result.isEmpty) {
      throw const NotFoundException('Investimento não encontrado');
    }
  }

  /// Add a contribution to an investment.
  Future<Contribution> addContribution({
    required String investmentId,
    required String userId,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    // Update the investment current_amount
    await Database.query(
      '''
      UPDATE investments
      SET current_amount = current_amount + @amount,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = @investmentId::uuid AND user_id = @userId::uuid
      ''',
      parameters: {
        'investmentId': investmentId,
        'userId': userId,
        'amount': amount,
      },
    );

    // Create the contribution record
    final result = await Database.query(
      '''
      INSERT INTO contributions (investment_id, user_id, amount, date, notes)
      VALUES (@investmentId::uuid, @userId::uuid, @amount, @date, @notes)
      RETURNING *
      ''',
      parameters: {
        'investmentId': investmentId,
        'userId': userId,
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        'notes': notes,
      },
    );
    return Contribution.fromRow(result.first.toColumnMap());
  }

  /// Get contributions for an investment.
  Future<List<Contribution>> getContributions(
    String investmentId,
    String userId,
  ) async {
    final result = await Database.query(
      '''
      SELECT * FROM contributions
      WHERE investment_id = @investmentId::uuid AND user_id = @userId::uuid
      ORDER BY date DESC
      ''',
      parameters: {
        'investmentId': investmentId,
        'userId': userId,
      },
    );
    return result.map((r) => Contribution.fromRow(r.toColumnMap())).toList();
  }

  /// Get portfolio distribution by type.
  Future<Map<String, double>> getPortfolioDistribution(String userId) async {
    final result = await Database.query(
      '''
      SELECT type, SUM(current_amount) as total
      FROM investments
      WHERE user_id = @userId::uuid AND is_active = TRUE
      GROUP BY type
      ORDER BY total DESC
      ''',
      parameters: {'userId': userId},
    );

    final distribution = <String, double>{};
    for (final row in result) {
      final map = row.toColumnMap();
      distribution[map['type'] as String] = double.parse(map['total'].toString());
    }
    return distribution;
  }

  /// Get total invested amount.
  Future<double> getTotalInvested(String userId) async {
    final result = await Database.query(
      '''
      SELECT COALESCE(SUM(current_amount), 0) as total
      FROM investments
      WHERE user_id = @userId::uuid AND is_active = TRUE
      ''',
      parameters: {'userId': userId},
    );
    return double.parse(result.first.toColumnMap()['total'].toString());
  }

  /// Get upcoming maturities (next 90 days).
  Future<List<Investment>> getUpcomingMaturities(String userId) async {
    final result = await Database.query(
      '''
      SELECT * FROM investments
      WHERE user_id = @userId::uuid
        AND is_active = TRUE
        AND maturity_date IS NOT NULL
        AND maturity_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days'
      ORDER BY maturity_date ASC
      LIMIT 10
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => Investment.fromRow(r.toColumnMap())).toList();
  }
}
