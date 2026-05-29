import 'package:supabase_flutter/supabase_flutter.dart';

class InvestmentService {
  final supabase = Supabase.instance.client;

  // =========================
  // OPERATIONS
  // =========================

  // =========================
// 🔥 OPERATIONS (NOVO)
// =========================

  Future<void> addOperation({
    required String type,
    required String asset,
    required double quantity,
    required double price,
    required DateTime date,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não logado');
      }

      final total = quantity * price;

      final response = await supabase.from('operations').insert({
        'user_id': user.id,
        'type': type,
        'asset': asset,
        'quantity': quantity,
        'price': price,
        'total': total,
        'date': date.toIso8601String(),
      });

      print('✅ OPERAÇÃO SALVA');
      print(response);
    } catch (e) {
      print('❌ ERRO AO SALVAR OPERAÇÃO: $e');
      rethrow;
    }
  }

  Future<List> getOperations() async {
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final res = await supabase
        .from('operations')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    return res;
  }

  Future<void> deleteOperation(String id) async {
    try {
      await supabase.from('operations').delete().eq('id', id);
      print('🗑️ Deletado');
    } catch (e) {
      print('Erro ao deletar: $e');
    }
  }
}
