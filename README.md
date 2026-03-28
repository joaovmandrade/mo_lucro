# Mo Lucro

**Mo Lucro** é uma aplicação completa de gestão financeira pessoal e controle de investimentos. O projeto foi desenvolvido com uma arquitetura Full-Stack em **Dart**, utilizando **Flutter** para o frontend mobile/web e **Dart Frog** para a construção de uma API backend robusta e eficiente, integrada a um banco de dados PostgreSQL.

---

## 1. Visão Geral do Projeto

- **Nome do Projeto:** Mo Lucro
- **Propósito:** Oferecer uma plataforma unificada e intuitiva para que os usuários possam registrar suas despesas diárias, acompanhar seus investimentos, definir metas financeiras e projetar o crescimento do seu patrimônio usando simuladores de juros compostos.
- **Problema que resolve:** A dificuldade de consolidar dados financeiros pessoais. Muitas vezes as pessoas utilizam aplicativos separados para fluxo de caixa e carteira de investimentos. O Mo Lucro centraliza o controle de receitas, despesas, ativos financeiros, aportes, metas e perfil de investidor.
- **Público-Alvo:** Pessoas físicas que buscam maior controle sobre o seu dinheiro, investidores iniciantes ou experientes que desejam monitorar a rentabilidade e alocação de seu portfólio, bem como qualquer pessoa interessada em educação financeira.

---

## 2. Tecnologias Utilizadas

O projeto adota um ecossistema inteiramente baseado na linguagem **Dart** para maximizar a sinergia entre o frontend e o backend.

### Frontend (Mobile / Web)
- **Framework:** [Flutter](https://flutter.dev/) (>= 3.10.0)
- **Linguagem:** Dart
- **Gerenciamento de Estado & Injeção de Dependências:** `flutter_riverpod` e `riverpod_annotation`
- **Roteamento:** `go_router`
- **Armazenamento Local:** `hive` e `flutter_secure_storage` (para persistências seguras de tokens)
- **Gráficos:** `fl_chart`
- **Design & UI:** `google_fonts`, Material Design 3

### Backend (API REST)
- **Framework:** [Dart Frog](https://dartfrog.vgv.dev/)
- **Bando de Dados:** PostgreSQL (com o pacote `postgres`)
- **Autenticação:** JWT utilizando `dart_jsonwebtoken` e criptografia via `bcrypt`
- **Utilitários:** `dotenv` para variáveis de ambiente, `uuid` para identificadores únicos

---

## 3. Estrutura do Projeto

A aplicação é dividida em duas pastas principais (monorepo), separando claramente as responsabilidades de interface de usuário e servidor/API.

```text
mo_lucro/
├── mo_lucro_app/                     # Aplicação Frontend em Flutter
│   ├── android/, ios/, web/          # Projetos nativos gerados pelo Flutter
│   ├── lib/
│   │   ├── core/                     # Rotas customizadas, utilitários, temas, serviços nativos
│   │   ├── features/                 # Módulos funcionais (auth, dashboard, expenses, goals, etc.)
│   │   └── main.dart                 # Ponto de entrada do Flutter
│   └── pubspec.yaml                  # Dependências do frontend
│
└── mo_lucro_backend/                 # API Backend em Dart Frog
    ├── lib/
    │   ├── models/                   # Representação e serialização de dados (User, Expense, Investment...)
    │   ├── repositories/             # Conexão direta com o banco de dados PostgreSQL
    │   └── services/                 # Lógica de negócio
    ├── routes/                       # Roteamento de endpoints (dart_frog) correspondendo à API
    │   ├── api/v1/                   # Endpoints de Autenticação, Despesas, Investimentos, Simulações, etc.
    │   └── _middleware.dart          # Interceptadores (validação de JWT, injeção de conexões)
    └── pubspec.yaml                  # Dependências do backend
```

---

## 4. Funcionalidades

- **Dashboard Integrado:** Visão consolidada de patrimônio, total investido, saldo disponível e distribuição do portfólio, resumindo a saúde financeira do usuário.
- **Autenticação e Perfil de Usuário:** Criação de contas seguras, login e validação de sessão por JWT. Inclui ferramentas de definição do *Perfil de Investidor*.
- **Gestão de Despesas e Receitas:** Registro de transações recorrentes ou únicas (entradas/saídas), categorização de gastos e histórico financeiro.
- **Portfólio de Investimentos:** Acompanhamento de ativos (renda fixa, ações, fundos), registro de aportes financeiros em cada investimento, taxas contratadas e liquidez.
- **Metas Financeiras:** Criação de objetivos (ex: Viagem, Fundo de Emergência), registrando quanto falta, estipulando prazos e calculando porcentagens de progresso automaticamente.
- **Calculadoras e Simuladores:** Ferramentas que estimam rendimentos futuros, descontos de imposto e lucros em cima do valor total investido a longo prazo (juros compostos).

---

## 5. Como a Aplicação Funciona

O fluxo da aplicação baseia-se em requisições REST ful do Flutter para o Dart Frog:
1. Ao abrir o App (`mo_lucro_app`), o sistema nativo verifica por credenciais salvas no armazenamento seguro (`hive` / `flutter_secure_storage`).
2. Tais requisições utilizam clientes HTTP injetados por meio do `riverpod` em sua camada de `layer/network` que conversam com a API `mo_lucro_backend` hospedada.
3. Requisições protegidas precisam enviar o Token JWT nos cabeçalhos HTTP.
4. O middleware do Dart Frog (`routes/_middleware.dart`) intercepta a chamada, valida o token, faz injeção de dependências do banco de dados e permite a progressão da solicitação até um handler (ex: `routes/api/v1/dashboard`).
5. A API compila o resultado através da camada `repositories` rodando queries SQL contra o Postgres, devolve a resposta em formato JSON e a UI reage reconstruindo a tela.

---

## 6. Backend / Banco de Dados

O banco de dados PostgreSQL sustenta o aplicativo através de um modelo relacional eficiente:

### Principais Entidades e Tabelas:
- `users`: Armazena dados do proprietário da conta, senha criptografada em hash, tipo de perfil e objetivos macro.
- `categories`: Tipos para catalogar fluxos do caixa (`expenses`). Possuem cores e ícones correspondentes.
- `expenses`: Representa toda transação (receita ou despesa). Tem referências pontuais para `users` e `categories`, data, nota e flags de transações recorrentes.
- `investments`: Ativos de investimento adquiridos pelo usuário. Monitora vencimento e os valores de base de rentabilidade.
- `contributions`: Depósitos secundários associados a um investimento mãe.
- `goals`: Objetivos financeiros estipulados via alvos numéricos. Traz controle de deadline e booleanos de finalização.
- `investor_profiles`: O histórico dos formulários e relatórios que ranqueiam o perfil de risco do investidor.

Todos estes esquemas mapeiam de forma 1:1 com as classes no diretório `mo_lucro_backend/lib/models/`.

---

## 7. Variáveis de Ambiente

O Backend utiliza um arquivo `.env` para gerenciar informações sensíveis e não expô-las no repositório. O template é encontrado em `.env.example`:

- `DATABASE_HOST`: Endereço de acesso ao banco de dados (ex: `localhost`).
- `DATABASE_PORT`: Porta do PostgreSQL (ex: `5432`).
- `DATABASE_NAME`: O nome do banco usado para rodar as tabelas do projeto (ex: `mo_lucro_db`).
- `DATABASE_USER`: Credencial de usuário de acesso banco.
- `DATABASE_PASSWORD`: Senha de segurança vinculada à credencial do banco de dados.
- `JWT_SECRET`: A semente/chave secreta utilizada para criptografar os tokens de acesso e refresh. **Obrigatória a alteração em produção.**
- `JWT_ACCESS_EXPIRY_MINUTES`: Duração da validade dos tokens na sessão dos usuários.
- `JWT_REFRESH_EXPIRY_DAYS`: O prazo de extensão temporal de renovação sem efetuar novo login.
- `PORT`: A porta em que o servidor Dart Frog vai ser alocado (ex: `8080`).
- `ENVIRONMENT`: Sinaliza o estágio de projeto (ex: `development` / `production`).

---

## 8. Instalação e Configuração

Certifique-se de ter o **Flutter SDK** e o **Dart SDK** instalados. Além disso, é necessário um servidor **PostgreSQL** rodando (pode ser via Docker ou nativo).

### Passo 1: Configurando o Backend (Dart Frog)
1. Navegue até o diretório do backend:
   ```bash
   cd mo_lucro_backend
   ```
2. Instale as dependências:
   ```bash
   dart pub get
   ```
3. Na raiz de `mo_lucro_backend`, crie um arquivo `.env` baseado no arquivo de exemplo e configure sua conexão local de banco de dados:
   ```bash
   cp .env.example .env
   ```
4. Verifique as ferramentas do Dart Frog (caso seja a primeira vez):
   ```bash
   dart pub global activate dart_frog_cli
   ```
5. Inicie o servidor:
   ```bash
   dart_frog dev
   ```

### Passo 2: Configurando o Frontend (Flutter)
1. Abra um terminal separado e navegue até a pasta do aplicativo:
   ```bash
   cd mo_lucro_app
   ```
2. Instale todos os pacotes:
   ```bash
   flutter pub get
   ```
3. Para reconstruir códigos gerados (útil caso modifique a API do Riverpod ou Hive):
   ```bash
   dart run build_runner build -d
   ```
4. Inicie o aplicativo em seu dispositivo, emulador ou na web:
   ```bash
   flutter run
   ```

---

## 9. Como Usar

- **Primeiro Acesso:** Crie sua conta preenchendos os dados.
- **Visão Geral:** Você cairá no Dashboard vazio.
- **Alimentando Dados:**
  - Vá em **Despesas/Receitas** e adicione pelo menos um ganho mensal (ex: Salário).
  - Adicione algumas compras e crie ou gerencie as *Categorias*.  
- **Investimentos:** Em aba específica, cadastre um ativo (CDB, Ações) contendo seu aporte inicial. Caso tenha depósitos sucessivos no mesmo ativo, adicione 'Aportes/Contributions'.
- **Simulação:** Utilize o formulário do simulador para visualizar gráficos do total em rendimentos dado um valor, com base no tempo pretendido.

---

## 10. Futuras Melhorias

- **Notificações Locais/Push:** Alertar os usuários de prazos de vencimento de metas criadas ou maturidade de investimentos que necessitam realocação, já que `flutter_local_notifications` está presente mas pode ser expandido.
- **Integração de Contas:** Uma pipeline conectada que transforma metas financeiras no momento de aporte automático usando recursos bancários de Open Finance e APIs relacionadas.
- **Relatórios Avançados:** Capacidade de gerar planilhas CSV e exportações detalhadas de patrimônio em formato PDF.
- **Tema Personalizável e Gamificação:** Sistema de badges no cumprimento de metas financeiras rígidas.

---

## 11. Notas para Desenvolvedores

- **Mesclagem Técnica (Full Dart):** Uma imensa vantagem técnica neste projeto reside não precisar manter um modelo `.dart` nas partes front-end e um de outro serviço/linguagem no backend. Considere a movimentação dos modelos comuns localizados em `mo_lucro_backend/lib/models/*` para um pacote/dependência interno separado caso necessário unificar mais código e mitigar DRY de JSON Models no frontend.
- **Uso do Riverpod:** O aplicativo prefere não usar StatefulWidgets para lidar com lógicas pesadas. Tenha em mente que as injeções de provedores dependem exaustivamente de `riverpod_generator`.
- **Limitações Atuais:** Os registros no banco de dados assumem que funções agregadoras que constroem a interface de exibição do Dashboard têm complexidade O(n). Ao escalar para alto volume real de dados simultâcos, considere escrever views materializadas ou procedures nativas no Postgres.
