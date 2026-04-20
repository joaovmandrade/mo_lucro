import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_config.dart';

/// Mock offline data source for investments API.
class InvestmentDataSource {
  final List<Map<String, dynamic>> _mockInvestments = [
    {
      'id': 'i1',
      'name': 'Tesouro Selic 2029',
      'type': 'FIXED_INCOME',
      'symbol': null,
      'amountInvested': 5000.00,
      'currentValue': 5210.30,
      'yield': 4.2,
      'startDate': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
    },
    {
      'id': 'i2',
      'name': 'Apple Inc.',
      'type': 'ACOES',
      'symbol': 'AAPL',
      'amountInvested': 150.00,
      'currentValue': 150.00,
      'yield': 0.0,
      'startDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    },
    {
      'id': 'i3',
      'name': 'Bitcoin',
      'type': 'CRIPTO',
      'symbol': 'bitcoin',
      'amountInvested': 60000.00,
      'currentValue': 60000.00,
      'yield': 0.0,
      'startDate': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    }
  ];

  String get _baseUrl => ApiConfig.apiV1BaseUrl;

  Future<void> refreshMarketPrices() async {
    for (var inv in _mockInvestments) {
      if (inv['symbol'] != null && inv['symbol'].toString().isNotEmpty) {
        try {
          if (inv['type'] == 'ACOES') {
            final symbol = Uri.encodeComponent(inv['symbol'].toString());
            final res = await http.get(Uri.parse('$_baseUrl/market/stock/$symbol'));
            if (res.statusCode == 200) {
              final data = jsonDecode(res.body);
              final price = data['price'] as num?;
              if (price != null) {
                inv['currentValue'] = price.toDouble();
              }
            }
          } else if (inv['type'] == 'CRIPTO') {
            final symbol = Uri.encodeComponent(inv['symbol'].toString());
            final res = await http.get(Uri.parse('$_baseUrl/market/crypto/$symbol'));
            if (res.statusCode == 200) {
              final data = jsonDecode(res.body);
              final price = data['brl'] as num? ?? data['usd'] as num?; 
              if (price != null) {
                inv['currentValue'] = price.toDouble();
              }
            }
          }
        } catch (_) {
          // Fallback if backend is unavailable
        }
      }
    }
  }

  Future<Map<String, dynamic>> getInvestments({
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final filteredInvestments = type == null || type.isEmpty
        ? _mockInvestments
        : _mockInvestments.where((investment) => investment['type'] == type).toList();
    final startIndex = (page - 1) * limit;
    final items = filteredInvestments.skip(startIndex).take(limit).toList();

    return {
      'items': items,
      'pagination': {
        'total': filteredInvestments.length,
        'page': page,
        'limit': limit,
        'totalPages': filteredInvestments.isEmpty
            ? 0
            : (filteredInvestments.length / limit).ceil(),
      },
    };
  }

  Future<Map<String, dynamic>> getInvestmentDetails(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockInvestments.firstWhere((i) => i['id'] == id, orElse: () => throw Exception('Investment not found'));
  }

  Future<Map<String, dynamic>> createInvestment(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final newInv = {
      ...data,
      'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
      'currentValue': data['amountInvested'] ?? 0.0,
      'yield': 0.0,
    };
    _mockInvestments.add(newInv);
    return newInv;
  }

  Future<Map<String, dynamic>> updateInvestment(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockInvestments.indexWhere((i) => i['id'] == id);
    if (index != -1) {
      _mockInvestments[index] = { ..._mockInvestments[index], ...data };
      return _mockInvestments[index];
    }
    throw Exception('Investment not found');
  }

  Future<void> deleteInvestment(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockInvestments.removeWhere((i) => i['id'] == id);
  }

  Future<Map<String, dynamic>> addContribution(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final id = data['investmentId'];
    final index = _mockInvestments.indexWhere((i) => i['id'] == id);
    if (index != -1) {
      final amount = data['amount'] as num? ?? 0.0;
      final currentInvAmount = _mockInvestments[index]['amountInvested'] as num? ?? 0.0;
      final currentInvValue = _mockInvestments[index]['currentValue'] as num? ?? 0.0;
      
      _mockInvestments[index]['amountInvested'] = currentInvAmount + amount;
      _mockInvestments[index]['currentValue'] = currentInvValue + amount;
      return _mockInvestments[index];
    }
    throw Exception('Investment not found');
  }
}
