import 'package:supabase_flutter/supabase_flutter.dart';

class InvestmentService {
  final supabase = Supabase.instance.client;

  // ===============================
  // INVESTMENTS (modo simples)
  // ===============================

  Future<List<Map<String, dynamic>>> getInvestments() async {
    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('investments')
        .select()
        .eq('user_id', user!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addInvestment({
    required String name,
    required double value,
  }) async {
    final user = supabase.auth.currentUser;

    await supabase.from('investments').insert({
      'user_id': user!.id,
      'name': name,
      'value': value,
    });
  }

  Future<void> deleteInvestment(String id) async {
    await supabase.from('investments').delete().eq('id', id);
  }

  // ===============================
  // OPERATIONS (nível profissional)
  // ===============================

  Future<void> addOperation({
    required String type, // 'buy' ou 'sell'
    required String asset,
    required double quantity,
    required double price,
    required DateTime date,
  }) async {
    final user = supabase.auth.currentUser;

    final total = quantity * price;

    await supabase.from('operations').insert({
      'user_id': user!.id,
      'type': type,
      'asset': asset,
      'quantity': quantity,
      'price': price,
      'total': total,
      'date': date.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getOperations() async {
    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('operations')
        .select()
        .eq('user_id', user!.id)
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteOperation(String id) async {
    await supabase.from('operations').delete().eq('id', id);
  }
}
