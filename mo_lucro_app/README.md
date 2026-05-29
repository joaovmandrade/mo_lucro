# Mo Lucro App

Aplicação fintech para gerenciamento de carteira de investimentos, construída com **Flutter** e **Supabase**.

## 🚀 Início Rápido

### Pré-requisitos

- Flutter 3.10.0+
- Dart 3.0.0+

### Instalação

```bash
# 1. Instalar dependências
flutter pub get

# 2. Executar a aplicação com a chave Supabase
flutter run --dart-define=SUPABASE_ANON_KEY=sua-chave-aqui
```

## 📁 Estrutura

```
lib/
├── main.dart           # Entrada da aplicação
├── core/               # Configurações globais (tema, etc)
├── models/             # Modelos de dados
├── pages/              # Telas da aplicação
├── widgets/            # Componentes reutilizáveis
├── services/           # Serviços de negócio
├── utils/              # Funções utilitárias
└── shared/             # Recursos compartilhados
```

## 🔐 Autenticação

A aplicação utiliza **Supabase** para autenticação:

- Crie uma conta em [supabase.com](https://supabase.com)
- Configure a chave anônima como `SUPABASE_ANON_KEY`
- A sessão persiste automaticamente entre execuções

## 📚 Recursos

- [Documentação Flutter](https://docs.flutter.dev/)
- [Documentação Supabase](https://supabase.com/docs)
- [fl_chart - Gráficos](https://pub.dev/packages/fl_chart)
