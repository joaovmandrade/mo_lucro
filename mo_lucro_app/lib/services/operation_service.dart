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

    return (res as List)
        .map((row) => OperationModel.fromMap(row as Map<String, dynamic>))
        .toList();
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

    await _db.from('operations').insert({
      'user_id': _userId,
      'type': type,
      'asset': asset.toUpperCase().trim(),
      'category': category,
      'quantity': quantity,
      'price': price,
      'total': total,
      'date': date.toIso8601String(),
    });
  }

  Future<void> deleteOperation(String id) async {
    await _db.from('operations').delete().eq('id', id);
  }
}
