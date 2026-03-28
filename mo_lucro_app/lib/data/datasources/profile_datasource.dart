import 'dart:async';

/// Mock offline data source for investor profile API.
class ProfileDataSource {
  Future<List<dynamic>> getQuizQuestions() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'id': 'q1',
        'question': 'Qual o seu principal objetivo ao investir?',
        'options': [
          {'id': 'o1', 'text': 'Preservar meu patrimônio'},
          {'id': 'o2', 'text': 'Ganhar mais do que a poupança'},
          {'id': 'o3', 'text': 'Maximizar a rentabilidade, mesmo com riscos'},
        ]
      },
      {
        'id': 'q2',
        'question': 'Como você reagiria a uma queda de 20% nos seus investimentos?',
        'options': [
          {'id': 'o1', 'text': 'Tiraria todo o dinheiro imediatamente'},
          {'id': 'o2', 'text': 'Ficaria preocupado, mas esperaria recuperar'},
          {'id': 'o3', 'text': 'Aproveitaria para comprar mais'},
        ]
      }
    ];
  }

  Future<Map<String, dynamic>> submitQuiz(List<Map<String, dynamic>> answers) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'profile': 'MODERADO',
      'score': 50,
    };
  }

  Future<Map<String, dynamic>?> getResult() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'profile': 'MODERADO',
      'description': 'Você busca um equilíbrio entre segurança e rentabilidade.',
      'recommendedAllocation': {
        'fixedIncome': 70.0,
        'variableIncome': 30.0,
      }
    };
  }

  Future<List<dynamic>> getRecommendations() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'title': 'CDB Banco Safra',
        'description': 'CDB rendendo 110% do CDI, baixo risco.',
        'expectedReturn': '110% CDI',
      },
      {
        'title': 'Fundo de Ações',
        'description': 'Fundo focado em empresas pagadoras de dividendos.',
        'expectedReturn': 'IPCA + 5%',
      }
    ];
  }
}
