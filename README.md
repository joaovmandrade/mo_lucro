# Mo Lucro

Aplicação fintech em **React Native** para gerenciamento de carteira de investimentos e operações financeiras, com autenticação segura via **Supabase**.

> Maximize seus lucros com inteligência financeira.

> Migrado de Flutter para React Native. O app Flutter original vivia em
> `mo_lucro_app/` e permanece disponível no histórico do git.

## Funcionalidades

- Autenticação segura com Supabase
- Visualização de gráficos e análises em tempo real
- Gerenciamento de carteira de investimentos
- Rastreamento de operações e transações
- Sincronização de dados na nuvem
- Persistência automática de sessão

## Stack Tecnológico

### Frontend

- **React Native** (0.86) via **Expo SDK 57** - Framework multiplataforma
- **TypeScript** - Linguagem de programação
- **expo-router** - Navegação por arquivos

### Backend & Serviços

- **Supabase** - Autenticação e banco de dados
- **PostgreSQL** - Database (via Supabase)

### Dependências Principais

- `@supabase/supabase-js` - Cliente Supabase
- `react-native-svg` - Base dos gráficos (donut e linha desenhados à mão)
- `@expo-google-fonts/inter` - Tipografia
- `date-fns` - Datas em pt-BR

## Requisitos do Sistema

- Node.js 20 ou superior
- iOS 15.1+ ou Android 7.0+
- Conta Supabase ativa

## Início Rápido

### 1. Clonar o repositório

```bash
git clone https://github.com/usuario/mo_lucro.git
cd mo_lucro
```

### 2. Instalar dependências

```bash
cd mobile
npm install
```

### 3. Configurar Supabase (opcional)

As credenciais têm fallback embutido em `src/lib/supabase.ts`. Para apontar
para outro projeto, copie `.env.example` para `.env`.

### 4. Executar a aplicação

```bash
npm start   # depois: 'a' para Android, 'i' para iOS, 'w' para web
```

## Estrutura do Projeto

```
mobile/
├── src/
│   ├── app/                      # Rotas (expo-router)
│   │   ├── _layout.tsx           # Fontes, auth e stack raiz
│   │   ├── login.tsx
│   │   └── (tabs)/               # Dashboard, Portfólio, Transações, Metas
│   ├── components/               # Cards, gráficos, formulário
│   ├── contexts/                 # AuthContext
│   ├── lib/supabase.ts           # Cliente Supabase
│   ├── models/                   # Tipos e conversores de linha
│   ├── services/                 # Acesso a dados e APIs externas
│   ├── theme/                    # Cores, tokens e tipografia
│   └── utils/                    # Formatters, carteira, catálogos
├── assets/                       # Ícones e splash
└── app.json                      # Configuração do Expo
```

Detalhes da migração e o mapa arquivo a arquivo em
[`mobile/README.md`](mobile/README.md).

## Fluxo da Aplicação

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
- **Persistência**: Sessão guardada em AsyncStorage pelo `supabase-js`

## Configuração Supabase

| Campo        | Valor                                      |
| ------------ | ------------------------------------------ |
| **URL**      | `https://mmtaolgmadsqhlsmmixa.supabase.co` |
| **Anon Key** | `EXPO_PUBLIC_SUPABASE_ANON_KEY` (tem fallback) |

## Modelos de Dados

- **Goal** - Objetivos financeiros
- **Operation** - Operações de investimento
- **Transaction** - Transações financeiras
- **PortfolioPosition** - Posições em carteira

## Desenvolvimento

### Verificar tipos

```bash
cd mobile && npx tsc --noEmit
```

### Gerar o bundle

```bash
cd mobile && npx expo export --platform android
```

## Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.
