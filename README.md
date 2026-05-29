# 📱 Mo Lucro

Aplicação fintech desenvolvida em **Flutter** para gerenciamento de carteira de investimentos e operações financeiras, com autenticação segura via **Supabase**.

> Maximize seus lucros com inteligência financeira.

## ✨ Funcionalidades

- 🔐 Autenticação segura com Supabase
- 📊 Visualização de gráficos e análises em tempo real
- 💼 Gerenciamento de carteira de investimentos
- 📈 Rastreamento de operações e transações
- 💾 Sincronização de dados na nuvem
- 🔄 Persistência automática de sessão

## 🛠️ Stack Tecnológico

### Frontend

- **Flutter** (v3.10.0+) - Framework multiplataforma
- **Dart** (3.0.0+) - Linguagem de programação

### Backend & Serviços

- **Supabase** - Autenticação e banco de dados
- **PostgreSQL** - Database (via Supabase)

### Dependências Principais

- `supabase_flutter: ^2.12.4` - Cliente Supabase para Flutter
- `fl_chart: ^1.2.0` - Gráficos interativos
- `google_fonts: ^6.2.1` - Tipografia
- `intl: ^0.19.0` - Internacionalização

## 📋 Requisitos do Sistema

- Flutter 3.10.0 ou superior
- Dart 3.0.0 ou superior
- iOS 11.0+ ou Android 5.0+
- Conta Supabase ativa

## 🚀 Início Rápido

### 1. Clonar o repositório

```bash
git clone https://github.com/usuario/mo_lucro.git
cd mo_lucro
```

### 2. Instalar dependências

```bash
cd mo_lucro_app
flutter pub get
```

### 3. Configurar Supabase

Crie um arquivo `.env` ou use variáveis de ambiente:

```bash
export SUPABASE_ANON_KEY="sua-chave-anonima-aqui"
```

### 4. Executar a aplicação

```bash
flutter run --dart-define=SUPABASE_ANON_KEY=sua-chave-anonima-aqui
```

## 🏗️ Estrutura do Projeto

```
mo_lucro_app/
├── lib/
│   ├── main.dart                 # Ponto de entrada
│   ├── core/
│   │   └── theme.dart            # Tema da aplicação
│   ├── models/                   # Modelos de dados
│   ├── pages/                    # Telas principais
│   ├── widgets/                  # Componentes reutilizáveis
│   ├── services/                 # Serviços e lógica
│   ├── utils/                    # Utilitários
│   └── shared/                   # Recursos compartilhados
├── test/                         # Testes
├── android/                      # Configuração Android
├── ios/                          # Configuração iOS
└── pubspec.yaml                  # Dependências do projeto
```

## 🔄 Fluxo da Aplicação

```
[Inicialização]
    ↓
[Supabase inicializa]
    ↓
[Sessão existente?]
    ├─ SIM → [HomePage]
    └─ NÃO → [LoginPage]
        ↓
    [signInWithPassword]
        ↓
    [HomePage]
```

### Autenticação

- **Login**: Usa `signInWithPassword` com credenciais do Supabase
- **Logout**: Usa `signOut`
- **Persistência**: Gerenciada automaticamente por `supabase_flutter`

## 📊 Configuração Supabase

| Campo        | Valor                                      |
| ------------ | ------------------------------------------ |
| **URL**      | `https://mmtaolgmadsqhlsmmixa.supabase.co` |
| **Anon Key** | Configurada via `SUPABASE_ANON_KEY`        |

## 📝 Modelos de Dados

- **GoalModel** - Objetivos financeiros
- **OperationModel** - Operações de investimento
- **TransactionModel** - Transações financeiras
- **PortfolioPosition** - Posições em carteira

## 🐛 Desenvolvimento

### Gerar código

```bash
flutter pub run build_runner build
```

### Executar testes

```bash
flutter test
```

### Analisar código

```bash
flutter analyze
```

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.

## 👤 Autor

Desenvolvido com ❤️
