# Mo Lucro — app React Native (Expo)

Porte do app Flutter para React Native, concluído. O código Flutter original
ficava em `mo_lucro_app/` e continua acessível pelo histórico do git — os
caminhos `lib/...` citados abaixo se referem a ele.

## Stack

- **Expo SDK 57** + React Native 0.86 + TypeScript
- **expo-router** — rotas por arquivo, em `src/app`
- **@supabase/supabase-js** + AsyncStorage para persistir a sessão
- **@expo-google-fonts/inter** — mesma tipografia do `google_fonts` no Flutter
- **date-fns** (locale pt-BR) e `Intl.NumberFormat` no lugar do `intl` do Dart

## Rodar

```bash
cd mobile
npm install
npm start          # depois: 'a' para Android, 'i' para iOS, 'w' para web
```

As credenciais do Supabase têm fallback embutido em `src/lib/supabase.ts` (a
chave é publishable e a proteção real é o RLS). Para apontar para outro projeto,
copie `.env.example` para `.env`.

## Estado da migração

| Fase | Escopo | Status |
| --- | --- | --- |
| 1 | Fundação: Expo, rotas, tema, Supabase, models, formatters | ✅ |
| 2 | Services (goals, operations, transactions, market data, news) | ✅ |
| 3 | As telas alcançáveis de `lib/pages` e seus widgets | ✅ |
| 4 | Gráficos (donut, linha) e polimento visual | ✅ |

## Verificado em emulador

Rodado no Android (Pixel 7, API 36) contra o Supabase real: login, cadastro,
Dashboard, Portfólio, Transações, Metas, Nova Operação (com autocomplete e busca
de preço na BRAPI), Simulador e Notícias. O gráfico de linha e o donut — com
toque na fatia — foram confirmados na tela. Cotação de cripto veio do CoinGecko
e as notícias da NewsAPI.

Ainda sem verificação visual: as telas de Nova Transação, Nova Meta e o quiz de
perfil, além do swipe-to-delete e do seletor de data no iOS.

Os gráficos são desenhados em `react-native-svg`, sem biblioteca de charts: a
linha usa a mesma fórmula de Bézier do `fl_chart` (`curveSmoothness: 0.35`) e o
donut reproduz `centerSpaceRadius: 60`, fatias de 46 (54 ao toque) e
`sectionsSpace: 3` convertido em ângulo.

## Mapa de arquivos

| Flutter | React Native |
| --- | --- |
| `lib/core/theme.dart` | `src/theme/{colors,tokens,typography}.ts` |
| `lib/main.dart` (`_AuthGate`, `_AppShell`) | `src/app/_layout.tsx`, `src/app/(tabs)/_layout.tsx` |
| `lib/main.dart` (`_BottomNav`, `_SplashScreen`) | `src/components/{BottomNav,Splash}.tsx` |
| `lib/services/supabase_config.dart` | `src/lib/supabase.ts` |
| `lib/models/*.dart` | `src/models/*.ts` |
| `lib/utils/formatters.dart` | `src/utils/formatters.ts` |
| `lib/utils/portfolio_utils.dart` | `src/utils/portfolio.ts` |
| `lib/services/goal_service.dart` | `src/services/goalService.ts` |
| `lib/services/operation_service.dart` | `src/services/operationService.ts` |
| `lib/services/transaction_service.dart` | `src/services/transactionService.ts` |
| `lib/services/market_data_service.dart` | `src/services/marketDataService.ts` |
| `lib/services/new_service.dart` | `src/services/newsService.ts` |
| `lib/pages/home_page.dart` | `src/app/(tabs)/index.tsx` |
| `lib/pages/portfolio_page.dart` | `src/app/(tabs)/portfolio.tsx` |
| `lib/pages/transactions_page.dart` | `src/app/(tabs)/transactions.tsx` |
| `lib/pages/goals_page.dart` | `src/app/(tabs)/goals.tsx` |
| `lib/pages/login_page.dart` | `src/app/login.tsx` |
| `lib/pages/add_operation_page.dart` | `src/app/operations/new.tsx` |
| `lib/pages/add_transaction_page.dart` | `src/app/transactions/new.tsx` |
| `lib/pages/add_goal_page.dart` | `src/app/goals/new.tsx` |
| `lib/pages/income_simulator_page.dart` | `src/app/simulator.tsx` |
| `lib/pages/market_news_page.dart` | `src/app/news.tsx` |
| `lib/pages/investor_profile_page.dart` | `src/app/profile.tsx` |
| `lib/widgets/asset_card.dart` | `src/components/AssetCard.tsx` |
| `lib/widgets/goal_card.dart` | `src/components/GoalCard.tsx` |
| `lib/widgets/transaction_tile.dart` | `src/components/TransactionTile.tsx` |
| `lib/widgets/patrimonio_line_chart.dart` | `src/components/PatrimonioLineChart.tsx` |
| `lib/widgets/portfolio_donut_chart.dart` | `src/components/PortfolioDonutChart.tsx` |

## Divergências entre `supabase/schema.sql` e o banco real

Encontradas ao popular dados de teste. Nenhuma quebra o app, porque o porte
herdou o tratamento defensivo do Flutter, mas valem correção:

- **`goals` não tem a coluna `deadline`**, embora o schema a declare. O card de
  meta simplesmente não mostra prazo.
- **O check de `operations.category` não aceita `'fiis'`**, embora o schema o
  inclua. O seletor de categoria nunca oferece FIIs, então não aparece na
  prática — FIIs entram como `'others'`.

## Decisões que valem registro

- **`investment_service.dart` não foi portado.** É uma duplicata antiga de
  `operation_service.dart`, com `print` no lugar de tratamento de erro. O porte
  usa só `operationService`.
- **Sombras via `boxShadow`.** O RN 0.76+ aceita múltiplas camadas na mesma
  string, o que reproduz as duas `BoxShadow` de `AppShadows.card` exatamente.
- **Pesos de fonte viram famílias.** No RN o peso vem do arquivo carregado, por
  isso `src/theme/typography.ts` referencia `Inter_600SemiBold` em vez de
  `fontWeight: '600'`.
- **Separador decimal dos percentuais.** No Flutter os `NumberFormat` de
  percentual não recebiam locale e caíam no padrão en_US (ponto decimal). O
  comportamento foi mantido para a migração não alterar o que a tela mostra.
- **Recarregar ao voltar.** No Flutter as listas recarregavam pelo `bool`
  devolvido por `Navigator.push`. Aqui o equivalente é `useFocusEffect`: a tela
  recarrega sempre que volta ao foco.
- **Diálogos viram `Alert` nativo.** `showDialog` de confirmação e o
  `PopupMenuButton` do card de meta usam `Alert.alert`. Só o diálogo de
  "adicionar valor à meta", que tem campo de texto, virou um `Modal` próprio.
- **Código morto não portado.** Não têm nenhuma referência no app Flutter:
  `new_operation_page.dart`, `quick_actions_row.dart`, `quick_action_sheet.dart`,
  `tip_card.dart`, `balance_card.dart`, `shared/widgets/investment_chart.dart`
  (que ainda consulta uma tabela `investments` fora do schema) e
  `shared/widgets/portfolio_chart.dart`.
- **`investor_profile_page.dart` também não é alcançável no Flutter** — nenhuma
  tela navega até ela. Foi portada mesmo assim para `/profile`, mas continua sem
  ponto de entrada na interface.
- **Animações.** As três do Flutter foram reproduzidas com Reanimated: a entrada
  do login (600ms, fade + deslize), a troca de passo do quiz (350ms) e o texto
  central do donut (200ms). Os `AnimatedContainer` de 150–200ms que só mudavam a
  cor de chips e botões de tipo ficaram como troca direta de estilo — em RN isso
  exigiria animar cor por cor, com pouco ganho visual.

## Dois defeitos do Flutter que não foram replicados

- **Porcentagem dupla no `AssetCard`.** O badge de lucro/prejuízo montava
  `'${AppFormatters.percentSimple(...)}%'`, e `percentSimple` já acrescenta `%`
  — a tela mostra `1.23%%`. No porte saiu um `%` só.
- **"Ver detalhes" sem ação no Dashboard.** O `TextButton` tinha
  `onPressed: () {}`. No porte ele leva para a aba Portfólio.
