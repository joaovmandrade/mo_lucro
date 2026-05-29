import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/operation_model.dart';

class OperationService {
  final _db = Supabase.instance.client;

  String get _userId {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return user.id;
  }

  Future<List<OperationModel>> getOperations() async {
    final res = await _db
        .from('operations')
        .select()
        .eq('user_id', _userId)
        .order('date', ascending: false);

    return (res as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      // If the DB row doesn't have 'category', default to 'stocks'
      map.putIfAbsent('category', () => 'stocks');
      return OperationModel.fromMap(map);
    }).toList();
  }

  Future<void> addOperation({
    required String type,
    required String asset,
    required String category,
    required double quantity,
    required double price,
    required DateTime date,
  }) async {
    final total = quantity * price;

    final payload = <String, dynamic>{
      'user_id': _userId,
      'type': type,
      'asset': asset.toUpperCase().trim(),
      'quantity': quantity,
      'price': price,
      'total': total,
      'date': date.toIso8601String(),
    };

    // Try with category; if column doesn't exist the insert still works
    try {
      payload['category'] = category;
      await _db.from('operations').insert(payload);
    } catch (_) {
      payload.remove('category');
      await _db.from('operations').insert(payload);
    }
  }

  Future<void> deleteOperation(String id) async {
    await _db.from('operations').delete().eq('id', id);
  }
}