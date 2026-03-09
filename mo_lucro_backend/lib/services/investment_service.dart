import '../core/exceptions.dart';
import '../repositories/investment_repository.dart';
import '../models/investment.dart';
import '../models/contribution.dart';

/// Service for investment business logic.
class InvestmentService {
  final InvestmentRepository _repository;

  InvestmentService(this._repository);

  /// Get paginated investments with optional type filter.
  Future<Map<String, dynamic>> getInvestments(
    String userId, {
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;
    final investments = await _repository.findByUserId(
      userId,
      type: type,
      limit: limit,
      offset: offset,
    );
    final total = await _repository.countByUserId(userId, type: type);

    return {
      'investments': investments.map((i) => i.toJson()).toList(),
      'pagination': {
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': (total / limit).ceil(),
      },
    };
  }

  /// Get investment details.
  Future<Map<String, dynamic>> getInvestmentDetails(
    String id,
    String userId,
  ) async {
    final investment = await _repository.findById(id, userId);
    if (investment == null) {
      throw const NotFoundException('Investimento não encontrado');
    }

    final contributions = await _repository.getContributions(id, userId);
    final totalContributed = contributions.fold<double>(
      0,
      (sum, c) => sum + c.amount,
    );

    return {
      ...investment.toJson(),
      'contributions': contributions.map((c) => c.toJson()).toList(),
      'totalContributed': totalContributed,
    };
  }

  /// Create a new investment.
  Future<Investment> createInvestment(
    String userId,
    Map<String, dynamic> data,
  ) async {
    // Validate required fields
    final name = data['name'] as String?;
    final type = data['type'] as String?;
    final initialAmount = (data['initialAmount'] as num?)?.toDouble();
    final investmentDate = data['investmentDate'] as String?;

    if (name == null || name.trim().isEmpty) {
      throw const ValidationException('Nome do ativo é obrigatório');
    }
    if (type == null || type.isEmpty) {
      throw const ValidationException('Tipo do ativo é obrigatório');
    }
    if (initialAmount == null || initialAmount < 0) {
      throw const ValidationException('Valor deve ser maior ou igual a zero');
    }
    if (investmentDate == null) {
      throw const ValidationException('Data do aporte é obrigatória');
    }

    return _repository.create(
      userId: userId,
      name: name.trim(),
      type: type,
      initialAmount: initialAmount,
      investmentDate: DateTime.parse(investmentDate),
      maturityDate: data['maturityDate'] != null
          ? DateTime.parse(data['maturityDate'] as String)
          : null,
      contractedRate: (data['contractedRate'] as num?)?.toDouble(),
      indexer: data['indexer'] as String?,
      institution: data['institution'] as String?,
      liquidity: data['liquidity'] as String?,
      notes: data['notes'] as String?,
    );
  }

  /// Update an investment.
  Future<Investment> updateInvestment(
    String id,
    String userId,
    Map<String, dynamic> data,
  ) async {
    return _repository.update(id, userId, data);
  }

  /// Delete an investment (soft delete).
  Future<void> deleteInvestment(String id, String userId) async {
    return _repository.delete(id, userId);
  }

  /// Add a contribution to an investment.
  Future<Contribution> addContribution(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final investmentId = data['investmentId'] as String?;
    final amount = (data['amount'] as num?)?.toDouble();
    final date = data['date'] as String?;

    if (investmentId == null || investmentId.isEmpty) {
      throw const ValidationException('ID do investimento é obrigatório');
    }
    if (amount == null || amount <= 0) {
      throw const ValidationException('Valor deve ser maior que zero');
    }
    if (date == null) {
      throw const ValidationException('Data é obrigatória');
    }

    // Verify investment exists and belongs to user
    final investment = await _repository.findById(investmentId, userId);
    if (investment == null) {
      throw const NotFoundException('Investimento não encontrado');
    }

    return _repository.addContribution(
      investmentId: investmentId,
      userId: userId,
      amount: amount,
      date: DateTime.parse(date),
      notes: data['notes'] as String?,
    );
  }
}
