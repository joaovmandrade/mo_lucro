import 'dart:convert';
import '../core/database.dart';
import '../core/exceptions.dart';

/// Service for investor profile quiz and educational recommendations.
class ProfileQuizService {
  /// Quiz questions definition.
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 1,
      'question': 'Qual é o seu objetivo principal com investimentos?',
      'options': [
        {'value': 'A', 'text': 'Preservar meu capital com segurança', 'score': 1},
        {'value': 'B', 'text': 'Crescimento moderado com segurança', 'score': 2},
        {'value': 'C', 'text': 'Maximizar ganhos, aceitando riscos', 'score': 3},
      ],
    },
    {
      'id': 2,
      'question': 'Como você reagiria se seu investimento caísse 20% em um mês?',
      'options': [
        {'value': 'A', 'text': 'Venderia tudo imediatamente', 'score': 1},
        {'value': 'B', 'text': 'Ficaria preocupado, mas manteria', 'score': 2},
        {'value': 'C', 'text': 'Aproveitaria para comprar mais', 'score': 3},
      ],
    },
    {
      'id': 3,
      'question': 'Qual seu horizonte de investimento?',
      'options': [
        {'value': 'A', 'text': 'Menos de 1 ano', 'score': 1},
        {'value': 'B', 'text': 'De 1 a 5 anos', 'score': 2},
        {'value': 'C', 'text': 'Mais de 5 anos', 'score': 3},
      ],
    },
    {
      'id': 4,
      'question': 'Qual seu nível de conhecimento sobre investimentos?',
      'options': [
        {'value': 'A', 'text': 'Básico — sei pouco sobre o assunto', 'score': 1},
        {'value': 'B', 'text': 'Intermediário — conheço os principais produtos', 'score': 2},
        {'value': 'C', 'text': 'Avançado — acompanho o mercado ativamente', 'score': 3},
      ],
    },
    {
      'id': 5,
      'question': 'Você já investiu em renda variável (ações, FIIs, cripto)?',
      'options': [
        {'value': 'A', 'text': 'Nunca', 'score': 1},
        {'value': 'B', 'text': 'Sim, mas pouco', 'score': 2},
        {'value': 'C', 'text': 'Sim, invisto regularmente', 'score': 3},
      ],
    },
    {
      'id': 6,
      'question': 'Qual percentual da sua renda mensal você investe?',
      'options': [
        {'value': 'A', 'text': 'Até 10%', 'score': 1},
        {'value': 'B', 'text': 'De 10% a 30%', 'score': 2},
        {'value': 'C', 'text': 'Mais de 30%', 'score': 3},
      ],
    },
    {
      'id': 7,
      'question': 'Como você prefere que seus investimentos se comportem?',
      'options': [
        {'value': 'A', 'text': 'Estáveis, mesmo rendendo menos', 'score': 1},
        {'value': 'B', 'text': 'Um equilíbrio entre segurança e rendimento', 'score': 2},
        {'value': 'C', 'text': 'Altos rendimentos, mesmo com oscilações', 'score': 3},
      ],
    },
    {
      'id': 8,
      'question': 'Você tem reserva de emergência?',
      'options': [
        {'value': 'A', 'text': 'Não', 'score': 1},
        {'value': 'B', 'text': 'Sim, cobrindo 3 a 6 meses', 'score': 2},
        {'value': 'C', 'text': 'Sim, cobrindo mais de 6 meses', 'score': 3},
      ],
    },
    {
      'id': 9,
      'question': 'Se você ganhasse R\$ 50.000 hoje, o que faria?',
      'options': [
        {'value': 'A', 'text': 'Colocaria tudo na poupança ou renda fixa', 'score': 1},
        {'value': 'B', 'text': 'Dividiria entre renda fixa e variável', 'score': 2},
        {'value': 'C', 'text': 'Investiria majoritariamente em renda variável', 'score': 3},
      ],
    },
    {
      'id': 10,
      'question': 'O que é mais importante para você?',
      'options': [
        {'value': 'A', 'text': 'Não perder dinheiro', 'score': 1},
        {'value': 'B', 'text': 'Ter retorno acima da inflação', 'score': 2},
        {'value': 'C', 'text': 'Ter os maiores retornos possíveis', 'score': 3},
      ],
    },
  ];

  /// Process quiz answers and determine investor profile.
  Future<Map<String, dynamic>> processQuiz(
    String userId,
    List<Map<String, dynamic>> answers,
  ) async {
    if (answers.length != questions.length) {
      throw const ValidationException(
        'Todas as ${10} perguntas devem ser respondidas',
      );
    }

    // Calculate score
    int totalScore = 0;
    for (final answer in answers) {
      final questionId = answer['questionId'] as int;
      final selectedValue = answer['selectedValue'] as String;

      final question = questions.firstWhere(
        (q) => q['id'] == questionId,
        orElse: () => throw ValidationException(
          'Pergunta $questionId não encontrada',
        ),
      );

      final option = (question['options'] as List).firstWhere(
        (o) => (o as Map)['value'] == selectedValue,
        orElse: () => throw ValidationException(
          'Opção $selectedValue inválida para pergunta $questionId',
        ),
      ) as Map;

      totalScore += option['score'] as int;
    }

    // Determine profile type (max score = 30, min = 10)
    String profileType;
    if (totalScore <= 15) {
      profileType = 'CONSERVADOR';
    } else if (totalScore <= 22) {
      profileType = 'MODERADO';
    } else {
      profileType = 'ARROJADO';
    }

    // Save to database
    await Database.query(
      '''
      INSERT INTO investor_profiles (user_id, answers, profile_type, score)
      VALUES (@userId::uuid, @answers::jsonb, @profileType::investor_profile_type, @score)
      ON CONFLICT (user_id) DO UPDATE SET
        answers = @answers::jsonb,
        profile_type = @profileType::investor_profile_type,
        score = @score,
        completed_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
      RETURNING *
      ''',
      parameters: {
        'userId': userId,
        'answers': jsonEncode(answers),
        'profileType': profileType,
        'score': totalScore,
      },
    );

    // Update user profile type
    await Database.query(
      'UPDATE users SET profile_type = @profileType WHERE id = @userId::uuid',
      parameters: {'userId': userId, 'profileType': profileType},
    );

    return {
      'profileType': profileType,
      'score': totalScore,
      'maxScore': 30,
      'description': _getProfileDescription(profileType),
      'characteristics': _getProfileCharacteristics(profileType),
    };
  }

  /// Get profile result.
  Future<Map<String, dynamic>?> getProfileResult(String userId) async {
    final result = await Database.query(
      'SELECT * FROM investor_profiles WHERE user_id = @userId::uuid',
      parameters: {'userId': userId},
    );

    if (result.isEmpty) return null;

    final row = result.first.toColumnMap();
    return {
      'profileType': row['profile_type'],
      'score': row['score'],
      'completedAt': row['completed_at'].toString(),
      'description': _getProfileDescription(row['profile_type'] as String),
      'characteristics': _getProfileCharacteristics(row['profile_type'] as String),
    };
  }

  /// Get educational recommendations based on profile.
  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    final profile = await getProfileResult(userId);
    final profileType = profile?['profileType'] as String? ?? 'CONSERVADOR';

    return _getRecommendationsByProfile(profileType);
  }

  /// Get quiz questions.
  List<Map<String, dynamic>> getQuestions() => questions;

  String _getProfileDescription(String profileType) {
    switch (profileType) {
      case 'CONSERVADOR':
        return 'Você prioriza a segurança do seu capital e prefere investimentos '
            'com baixo risco e previsibilidade. Ideal para quem está começando '
            'ou tem objetivos de curto prazo.';
      case 'MODERADO':
        return 'Você busca um equilíbrio entre segurança e rentabilidade. '
            'Aceita algum nível de risco em troca de retornos potencialmente maiores. '
            'Indicado para objetivos de médio prazo.';
      case 'ARROJADO':
        return 'Você busca maximizar retornos e está disposto a tolerar oscilações '
            'significativas no curto prazo. Tem visão de longo prazo e '
            'conhecimento do mercado financeiro.';
      default:
        return '';
    }
  }

  List<String> _getProfileCharacteristics(String profileType) {
    switch (profileType) {
      case 'CONSERVADOR':
        return [
          'Prioriza segurança e estabilidade',
          'Prefere investimentos de renda fixa',
          'Tem baixa tolerância a perdas',
          'Foco em preservação de capital',
          'Ideal: Tesouro Selic, CDB, Poupança',
        ];
      case 'MODERADO':
        return [
          'Busca equilíbrio entre risco e retorno',
          'Mescla renda fixa e variável',
          'Tolera oscilações moderadas',
          'Foco em crescimento sustentável',
          'Ideal: Mix de CDB, Tesouro, FIIs e um pouco de ações',
        ];
      case 'ARROJADO':
        return [
          'Alta tolerância a risco',
          'Maior exposição a renda variável',
          'Visão de longo prazo',
          'Busca rentabilidade acima do mercado',
          'Ideal: Ações, FIIs, Cripto com base em renda fixa',
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getRecommendationsByProfile(String profileType) {
    final general = [
      {
        'title': 'Reserva de Emergência',
        'content': 'Antes de investir, construa uma reserva de emergência '
            'equivalente a 6 meses dos seus gastos mensais em ativos de alta '
            'liquidez como Tesouro Selic ou CDB com liquidez diária.',
        'category': 'essencial',
        'icon': 'shield',
      },
      {
        'title': 'Diversificação',
        'content': 'Nunca coloque todos os ovos na mesma cesta. '
            'Distribua seus investimentos entre diferentes classes de ativos, '
            'setores e instituições.',
        'category': 'estratégia',
        'icon': 'pie_chart',
      },
      {
        'title': 'Consistência nos Aportes',
        'content': 'Investir regularmente (todo mês) é mais importante '
            'do que tentar acertar o momento perfeito. Use a estratégia do '
            'preço médio a seu favor.',
        'category': 'estratégia',
        'icon': 'calendar_today',
      },
    ];

    final specific = <Map<String, dynamic>>[];

    switch (profileType) {
      case 'CONSERVADOR':
        specific.addAll([
          {
            'title': 'Tesouro Selic',
            'content': 'O Tesouro Selic é um dos investimentos mais seguros do '
                'Brasil. Rende próximo da taxa Selic e tem liquidez diária.',
            'category': 'produto',
            'icon': 'account_balance',
          },
          {
            'title': 'CDB com Liquidez Diária',
            'content': 'CDBs de bancos grandes com liquidez diária são seguros '
                'e podem render mais que a poupança. Protegidos pelo FGC até '
                'R\$ 250 mil.',
            'category': 'produto',
            'icon': 'savings',
          },
        ]);
        break;
      case 'MODERADO':
        specific.addAll([
          {
            'title': 'Tesouro IPCA+',
            'content': 'O Tesouro IPCA+ protege seu dinheiro da inflação e '
                'ainda paga uma taxa real. Ideal para objetivos de médio/longo prazo.',
            'category': 'produto',
            'icon': 'trending_up',
          },
          {
            'title': 'Fundos Imobiliários (FIIs)',
            'content': 'FIIs permitem investir em imóveis de forma acessível e '
                'receber rendimentos mensais. Uma boa porta de entrada para renda variável.',
            'category': 'produto',
            'icon': 'apartment',
          },
        ]);
        break;
      case 'ARROJADO':
        specific.addAll([
          {
            'title': 'Diversificação em Ações',
            'content': 'Mesmo com perfil arrojado, diversifique entre setores '
                'e empresas. Considere ETFs para exposição ampla ao mercado.',
            'category': 'produto',
            'icon': 'show_chart',
          },
          {
            'title': 'Alocação Estratégica',
            'content': 'Mantenha pelo menos 30% em renda fixa como base de segurança. '
                'Use os demais 70% para buscar rentabilidade em renda variável.',
            'category': 'estratégia',
            'icon': 'balance',
          },
        ]);
        break;
    }

    return [...general, ...specific];
  }
}
