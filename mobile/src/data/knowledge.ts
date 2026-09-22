import type { MaterialIcons } from '@expo/vector-icons';
import type { ComponentProps } from 'react';

/**
 * Conteúdo da Base de Conhecimento.
 *
 * Tudo é estático e mora no app: não depende de rede, então a aba funciona
 * offline. Para adicionar uma aula, crie um item em LESSONS apontando para uma
 * trilha existente; a tela de lista e a de leitura se montam sozinhas.
 *
 * Regras tributárias e limites do FGC foram conferidos em set/2026. Quando algo
 * mudar, edite só o texto correspondente aqui.
 */

export type IconName = ComponentProps<typeof MaterialIcons>['name'];

export type Block =
  | { type: 'p'; text: string }
  | { type: 'h'; text: string }
  | { type: 'list'; items: string[] }
  | { type: 'callout'; tone: 'tip' | 'warning' | 'example'; text: string; title?: string }
  | { type: 'table'; head: string[]; rows: string[][] }
  | { type: 'terms'; items: { term: string; definition: string }[] }
  | { type: 'calculator' };

export type Track = {
  id: string;
  title: string;
  description: string;
  icon: IconName;
};

export type Lesson = {
  id: string;
  trackId: string;
  title: string;
  summary: string;
  /** Tempo estimado de leitura, em minutos. */
  minutes: number;
  blocks: Block[];
  /** Atalho opcional para uma tela do app ao final da aula. */
  cta?: { label: string; route: '/operations/new' | '/simulator' };
};

export const TRACKS: Track[] = [
  {
    id: 'basics',
    title: 'Primeiros passos',
    description: 'O que é aportar e o que resolver antes de começar.',
    icon: 'school',
  },
  {
    id: 'fixed',
    title: 'Renda fixa',
    description: 'Onde o dinheiro rende com regras conhecidas.',
    icon: 'account-balance',
  },
  {
    id: 'variable',
    title: 'Renda variável',
    description: 'Ações, FIIs, dividendos e criptomoedas.',
    icon: 'show-chart',
  },
  {
    id: 'strategy',
    title: 'Estratégia de aportes',
    description: 'Constância, diversificação e como acompanhar a carteira.',
    icon: 'autorenew',
  },
  {
    id: 'taxes',
    title: 'Impostos e custos',
    description: 'O que é descontado do seu resultado.',
    icon: 'receipt',
  },
  {
    id: 'glossary',
    title: 'Glossário',
    description: 'Termos que aparecem em toda conversa sobre investimento.',
    icon: 'menu-book',
  },
];

export const LESSONS: Lesson[] = [
  // ───────────────────────── Primeiros passos ─────────────────────────
  {
    id: 'o-que-e-aporte',
    trackId: 'basics',
    title: 'O que é um aporte',
    summary: 'A diferença entre o que você coloca e o que o dinheiro rende.',
    minutes: 3,
    blocks: [
      {
        type: 'p',
        text: 'Aporte é todo valor que você coloca em um investimento: o primeiro depósito, o de todo mês ou aquele extra do 13º salário. Rendimento é outra coisa: é o que o dinheiro gera depois de investido.',
      },
      {
        type: 'callout',
        tone: 'example',
        title: 'Na prática',
        text: 'Você investe R$ 300 em janeiro e R$ 300 em fevereiro. Foram dois aportes, somando R$ 600. Se o saldo em março for R$ 612, os R$ 12 de diferença são rendimento.',
      },
      { type: 'h', text: 'Três tipos de aporte' },
      {
        type: 'list',
        items: [
          'Inicial: o primeiro valor, que abre a posição.',
          'Recorrente: um valor fixo em data marcada, como todo dia 5.',
          'Extraordinário: dinheiro fora do orçamento, como 13º salário, bônus ou restituição do Imposto de Renda.',
        ],
      },
      { type: 'h', text: 'Por que o aporte pesa mais no começo' },
      {
        type: 'p',
        text: 'Com R$ 5.000 investidos, um rendimento de 1% ao mês gera R$ 50. Um único aporte de R$ 500 já é dez vezes maior que isso. Nos primeiros anos, o que faz o patrimônio crescer é quanto e com que frequência você aporta. O rendimento só passa a ser o protagonista depois de muito tempo, e a aula sobre juros compostos mostra por quê.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Trate o aporte como uma conta fixa. Separe o valor assim que o salário cair, antes de gastar com o resto.',
      },
    ],
  },
  {
    id: 'reserva-de-emergencia',
    trackId: 'basics',
    title: 'Reserva de emergência',
    summary: 'O que fazer antes de aportar em ativos que oscilam.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'Investimentos que oscilam podem estar em queda justo quando você precisa do dinheiro. A reserva de emergência evita que uma despesa inesperada, como um conserto, uma consulta ou uma demissão, force você a vender na hora errada.',
      },
      { type: 'h', text: 'Quanto guardar' },
      {
        type: 'p',
        text: 'Uma regra prática é guardar de 3 a 12 vezes o seu custo de vida mensal. Quanto mais instável a sua renda, maior a reserva.',
      },
      {
        type: 'list',
        items: [
          '3 meses: renda estável, como a de servidores públicos.',
          '6 meses: caso comum de quem trabalha com carteira assinada.',
          '12 meses: autônomos e quem tem renda variável.',
        ],
      },
      {
        type: 'callout',
        tone: 'example',
        text: 'Se você gasta R$ 3.000 por mês e quer 6 meses de reserva, a meta é R$ 18.000.',
      },
      { type: 'h', text: 'Onde deixar' },
      {
        type: 'p',
        text: 'O critério é liquidez e segurança, não rentabilidade. Boas opções costumam ser o Tesouro Selic, CDBs com liquidez diária e contas remuneradas de bancos cobertos pelo FGC.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'A reserva não existe para render mais. Se você a colocar em algo que oscila ou que trava o resgate, ela deixa de cumprir a função.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Você pode aportar na reserva e em outros objetivos ao mesmo tempo. Muita gente divide o aporte mensal até a reserva chegar à meta.',
      },
    ],
  },
  {
    id: 'perfil-investidor',
    trackId: 'basics',
    title: 'Perfil de investidor',
    summary: 'Quanto risco cabe no seu bolso e na sua cabeça.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'O perfil de investidor combina duas coisas: quanto risco você aguenta emocionalmente e quanto risco a sua situação financeira permite. Uma queda de 20% no valor de um ativo pesa muito mais em quem vai precisar do dinheiro no ano que vem.',
      },
      {
        type: 'table',
        head: ['Perfil', 'Como reage às oscilações', 'Onde costuma aportar'],
        rows: [
          ['Conservador', 'Prefere não ver o saldo cair', 'Renda fixa e reserva'],
          ['Moderado', 'Aceita quedas temporárias por mais retorno', 'Renda fixa, com parte em ações e FIIs'],
          ['Arrojado', 'Aceita grandes oscilações no longo prazo', 'Maior parte em renda variável'],
        ],
      },
      {
        type: 'p',
        text: 'O prazo também conta. A mesma pessoa pode ser arrojada com o dinheiro da aposentadoria, que só será usado daqui a 30 anos, e conservadora com o da entrada de um imóvel, que será usado em 2.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Corretoras e bancos aplicam um questionário de perfil, chamado suitability. Use o resultado como ponto de partida e revise quando a sua vida mudar.',
      },
    ],
  },

  // ───────────────────────── Renda fixa ─────────────────────────
  {
    id: 'como-funciona-renda-fixa',
    trackId: 'fixed',
    title: 'Como funciona a renda fixa',
    summary: 'Você empresta dinheiro e recebe juros de volta.',
    minutes: 5,
    blocks: [
      {
        type: 'p',
        text: 'Na renda fixa você empresta dinheiro a um banco, a uma empresa ou ao governo. Em troca, recebe juros. A regra de cálculo desses juros é conhecida na hora da aplicação, mesmo quando o valor final não é.',
      },
      { type: 'h', text: 'Três formas de remuneração' },
      {
        type: 'table',
        head: ['Tipo', 'Como rende', 'Exemplo'],
        rows: [
          ['Prefixado', 'Taxa fixa combinada na compra', '10% ao ano'],
          ['Pós-fixado', 'Acompanha um indicador, como CDI ou Selic', '100% do CDI'],
          ['Híbrido', 'Inflação mais uma taxa fixa', 'IPCA + 6% ao ano'],
        ],
      },
      { type: 'h', text: 'Os riscos que existem' },
      {
        type: 'list',
        items: [
          'Crédito: quem emitiu o título não conseguir pagar. O FGC protege parte dos casos.',
          'Mercado: nos prefixados e híbridos, vender antes do vencimento pode render menos que o esperado, porque o preço acompanha as taxas de juros.',
          'Liquidez: alguns títulos só podem ser resgatados no vencimento.',
        ],
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Renda fixa não significa retorno garantido em qualquer situação. Significa que a regra de remuneração é conhecida de antemão.',
      },
    ],
  },
  {
    id: 'tesouro-direto',
    trackId: 'fixed',
    title: 'Tesouro Direto',
    summary: 'Títulos do governo federal, acessíveis com valores pequenos.',
    minutes: 5,
    blocks: [
      {
        type: 'p',
        text: 'No Tesouro Direto você empresta dinheiro ao governo federal. Por isso o risco de crédito é considerado o menor do país, e o FGC não se aplica, já que não há banco no meio. É possível aportar valores baixos, o que ajuda quem está começando.',
      },
      { type: 'h', text: 'Os três títulos mais usados' },
      {
        type: 'table',
        head: ['Título', 'Rende como', 'Para que serve'],
        rows: [
          ['Tesouro Selic', 'Acompanha a taxa Selic', 'Reserva de emergência e prazos curtos'],
          ['Tesouro Prefixado', 'Taxa fixa definida na compra', 'Quando você quer saber quanto vai receber no vencimento'],
          ['Tesouro IPCA+', 'Inflação mais taxa fixa', 'Objetivos de longo prazo, como aposentadoria'],
        ],
      },
      {
        type: 'p',
        text: 'Nos prefixados e no IPCA+, o preço do título muda todos os dias. Se você vender antes do vencimento, pode receber menos do que aplicou. Se segurar até o vencimento, recebe o que foi combinado.',
      },
      { type: 'h', text: 'O que é descontado' },
      {
        type: 'list',
        items: [
          'Imposto de Renda, pela tabela regressiva (veja a trilha de impostos).',
          'IOF, apenas em resgates com menos de 30 dias.',
          'Taxa de custódia da B3 e, em alguns casos, taxa da corretora. Confira os valores e as isenções vigentes.',
        ],
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Aportes mensais no Tesouro Selic são uma forma simples de montar a reserva de emergência, porque o preço quase não oscila.',
      },
    ],
  },
  {
    id: 'cdb-lci-lca',
    trackId: 'fixed',
    title: 'CDB, LCI e LCA',
    summary: 'Títulos de bancos, protegidos pelo FGC dentro de um limite.',
    minutes: 5,
    blocks: [
      {
        type: 'p',
        text: 'CDB, LCI e LCA são títulos emitidos por bancos. Você empresta ao banco e recebe juros. A LCI tem o crédito ligado a imóveis e a LCA, ao agronegócio.',
      },
      { type: 'h', text: 'O que olhar antes de aportar' },
      {
        type: 'list',
        items: [
          'Indexador e taxa: por exemplo, 100% do CDI ou IPCA + 6%.',
          'Liquidez: alguns permitem resgate a qualquer dia, outros só no vencimento ou após uma carência.',
          'Emissor: bancos menores costumam pagar taxas maiores, e isso vem com mais risco de crédito.',
          'Imposto: o CDB paga Imposto de Renda; LCI e LCA são isentas para pessoa física.',
        ],
      },
      { type: 'h', text: 'O FGC' },
      {
        type: 'p',
        text: 'O Fundo Garantidor de Créditos devolve o dinheiro se o banco quebrar, até R$ 250 mil por CPF em cada instituição (conglomerado financeiro), com um teto de R$ 1 milhão a cada 4 anos. Acima disso o risco é seu, então vale distribuir aportes grandes entre emissores diferentes.',
      },
      { type: 'h', text: 'Comparando CDB com LCI e LCA' },
      {
        type: 'p',
        text: 'Para comparar de forma justa, converta a taxa da LCI para o CDB equivalente: taxa da LCI dividida por (1 menos a alíquota do Imposto de Renda).',
      },
      {
        type: 'callout',
        tone: 'example',
        text: 'Uma LCI de 92% do CDI equivale a um CDB de 108,2% do CDI se o prazo for maior que 720 dias (IR de 15%), e a 115% do CDI se o prazo ficar entre 181 e 360 dias (IR de 20%). Se o CDB que você encontrou paga menos que isso, a LCI rende mais.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'O FGC cobre depósitos e títulos de bancos associados. Debêntures, CRI e CRA não têm essa proteção.',
      },
    ],
  },

  // ───────────────────────── Renda variável ─────────────────────────
  {
    id: 'acoes',
    trackId: 'variable',
    title: 'Ações',
    summary: 'Como virar sócio de uma empresa listada na bolsa.',
    minutes: 5,
    blocks: [
      {
        type: 'p',
        text: 'Uma ação é uma fração do capital de uma empresa. Ao comprar, você vira sócio e participa dos resultados de duas formas: pela valorização do preço e pelos proventos que a empresa distribui.',
      },
      { type: 'h', text: 'O que faz o preço mudar' },
      {
        type: 'p',
        text: 'Resultados da empresa, taxa de juros, cenário econômico e humor do mercado. No curto prazo o preço oscila muito, e por isso ações costumam ser usadas em prazos longos, de 5 anos ou mais.',
      },
      { type: 'h', text: 'Dá para aportar pouco?' },
      {
        type: 'p',
        text: 'Dá. Além do lote padrão de 100 ações, a B3 tem o mercado fracionário, em que você compra de 1 a 99 ações. No código do ativo, a versão fracionária termina com F, como em PETR4F. A maioria das corretoras faz isso automaticamente.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'No Mo Lucro, registre sempre o código normal, como PETR4. Assim todas as compras ficam na mesma posição e o preço médio sai correto.',
      },
      { type: 'h', text: 'Riscos' },
      {
        type: 'list',
        items: [
          'Queda de preço: você pode vender por menos do que pagou.',
          'Concentração: poucas empresas deixam a carteira dependente de poucos resultados.',
          'Não há garantia de retorno nem cobertura do FGC.',
        ],
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'Rentabilidade passada não garante rentabilidade futura. O conteúdo desta base é educacional e não é recomendação de compra.',
      },
    ],
  },
  {
    id: 'fiis',
    trackId: 'variable',
    title: 'Fundos imobiliários (FIIs)',
    summary: 'Receba parte do resultado de imóveis sem comprar um imóvel.',
    minutes: 5,
    blocks: [
      {
        type: 'p',
        text: 'Um fundo imobiliário reúne dinheiro de muitos investidores para comprar imóveis ou títulos ligados a imóveis. Você compra cotas na bolsa e o fundo distribui o resultado, normalmente todo mês.',
      },
      { type: 'h', text: 'Principais tipos' },
      {
        type: 'table',
        head: ['Tipo', 'Onde investe', 'Risco principal'],
        rows: [
          ['Tijolo', 'Imóveis, como galpões e lajes corporativas', 'Vacância e queda do aluguel'],
          ['Papel', 'Títulos de crédito imobiliário, os CRIs', 'Calote e variação dos juros'],
          ['Fundo de fundos', 'Cotas de outros FIIs', 'Escolhas do gestor'],
        ],
      },
      {
        type: 'p',
        text: 'Por lei, os FIIs distribuem ao menos 95% do resultado de caixa a cada semestre. É por isso que os rendimentos costumam ser mensais e visíveis.',
      },
      { type: 'h', text: 'Dois números para conhecer' },
      {
        type: 'list',
        items: [
          'Dividend yield: rendimentos dos últimos 12 meses divididos pelo preço da cota.',
          'P/VP: preço da cota dividido pelo valor patrimonial por cota. Abaixo de 1, a cota custa menos que o patrimônio que ela representa; isso pode ser oportunidade ou sinal de problema.',
        ],
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Reinvestir os rendimentos mensais em novos aportes acelera o efeito dos juros compostos.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'A cota oscila como uma ação e o rendimento mensal pode cair. FII não é renda fixa.',
      },
    ],
  },
  {
    id: 'dividendos-jcp',
    trackId: 'variable',
    title: 'Dividendos e JCP',
    summary: 'Como as empresas repassam lucro e o que muda nos seus aportes.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'Dividendos são a parte do lucro que a empresa distribui aos acionistas. Os juros sobre capital próprio, os JCP, são outra forma de distribuir, com tratamento tributário diferente: o imposto é retido na fonte.',
      },
      { type: 'h', text: 'Imposto desde 2026' },
      {
        type: 'p',
        text: 'Até 2025, os dividendos eram isentos para pessoa física. Desde 1º de janeiro de 2026, a Lei 15.270/2025 prevê retenção de 10% de Imposto de Renda quando uma mesma empresa paga mais de R$ 50 mil por mês ao mesmo investidor. Para a maioria dos investidores de varejo, o valor recebido fica abaixo desse limite.',
      },
      { type: 'h', text: 'O preço cai depois do dividendo' },
      {
        type: 'p',
        text: 'No dia em que a ação passa a ser negociada sem direito ao dividendo, chamado de data ex, o preço tende a cair um valor parecido com o que foi pago. Você recebe em caixa o que o papel perdeu em preço.',
      },
      {
        type: 'callout',
        tone: 'example',
        text: 'Uma ação a R$ 20,00 que paga R$ 1,00 de dividendo tende a abrir a R$ 19,00 na data ex. Você fica com R$ 19,00 em ação e R$ 1,00 em caixa.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'Um dividend yield muito alto pode indicar que o preço caiu por causa de um problema na empresa e que o pagamento não vai se repetir. Olhe o histórico e a geração de caixa, não só o número.',
      },
    ],
  },
  {
    id: 'criptomoedas',
    trackId: 'variable',
    title: 'Criptomoedas',
    summary: 'Alta volatilidade pede aportes pequenos e conscientes.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'Criptomoedas são ativos digitais negociados 24 horas por dia. Os preços podem subir ou cair dezenas de pontos percentuais em poucos dias, e não há cobertura do FGC nem renda periódica.',
      },
      { type: 'h', text: 'Como pensar nos aportes' },
      {
        type: 'list',
        items: [
          'Aporte só um valor que você aceita ver cair muito.',
          'Defina antes de comprar qual parcela da carteira ela pode ocupar, e mantenha essa parcela pequena.',
          'Prefira aportes recorrentes em vez de tentar acertar o melhor dia.',
          'Saiba onde as moedas ficam guardadas: na corretora, ou em carteira própria, em que você responde pelas chaves de acesso.',
        ],
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'Promessas de retorno garantido são o sinal mais comum de golpe nesse mercado. Nenhum ativo legítimo garante retorno.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Criptomoedas têm regras próprias de declaração e de imposto. Consulte o site da Receita Federal antes de vender.',
      },
    ],
  },

  // ───────────────────────── Estratégia de aportes ─────────────────────────
  {
    id: 'juros-compostos',
    trackId: 'strategy',
    title: 'Juros compostos e o tempo',
    summary: 'Por que o mesmo aporte rende muito mais em 20 anos do que em 10.',
    minutes: 5,
    blocks: [
      {
        type: 'p',
        text: 'Nos juros compostos, os juros de cada mês entram no saldo e passam a render também. É rendimento sobre rendimento, e o efeito cresce com o tempo.',
      },
      {
        type: 'p',
        text: 'Para aportes mensais iguais, o valor acumulado é: aporte × ((1 + taxa)^meses − 1) ÷ taxa, com a taxa expressa ao mês.',
      },
      {
        type: 'callout',
        tone: 'example',
        title: 'R$ 500 por mês a 10% ao ano',
        text: 'Em 10 anos você aporta R$ 60 mil e chega a cerca de R$ 100 mil. Em 20 anos, aporta R$ 120 mil e chega a cerca de R$ 359 mil. Em 30 anos, aporta R$ 180 mil e passa de R$ 1 milhão.',
      },
      {
        type: 'p',
        text: 'Repare que passar de 10 para 20 anos multiplicou o resultado por 3,6, enquanto o total aportado apenas dobrou. É o tempo, mais do que o valor, que faz a diferença.',
      },
      { type: 'h', text: 'Teste com os seus números' },
      { type: 'calculator' },
      {
        type: 'callout',
        tone: 'warning',
        text: 'A taxa do exemplo é ilustrativa. Nenhum investimento garante retorno fixo, e a inflação reduz o poder de compra do resultado.',
      },
    ],
  },
  {
    id: 'aporte-recorrente',
    trackId: 'strategy',
    title: 'Aporte recorrente',
    summary: 'Por que investir todo mês reduz o peso de escolher o momento certo.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'Aporte recorrente é investir um valor fixo em intervalos regulares, seja qual for o preço do dia. Quando o preço está alto você compra menos cotas, e quando está baixo compra mais.',
      },
      {
        type: 'callout',
        tone: 'example',
        title: 'Três meses, R$ 500 por mês',
        text: 'Mês 1: preço R$ 10, você compra 50 cotas. Mês 2: preço R$ 8, compra 62,5 cotas. Mês 3: preço R$ 12, compra cerca de 41,7 cotas. Total: R$ 1.500 investidos e cerca de 154,2 cotas, com preço médio de R$ 9,73. A média simples dos preços é R$ 10,00.',
      },
      { type: 'h', text: 'Vantagens' },
      {
        type: 'list',
        items: [
          'Tira de cena a pergunta “qual é o melhor dia para comprar?”.',
          'Encaixa no ritmo de quem recebe salário mensal.',
          'Cria o hábito de aportar.',
        ],
      },
      {
        type: 'p',
        text: 'Aportar tudo de uma vez tende a render mais em períodos em que o mercado sobe. O aporte recorrente troca um pouco desse potencial por menos risco de entrar no pior momento e por ser mais fácil de cumprir.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'Aportar todo mês não protege contra perdas. Se o ativo cair e não se recuperar, você perde do mesmo jeito.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Programe uma transferência automática para o dia seguinte ao recebimento do salário.',
      },
    ],
  },
  {
    id: 'preco-medio',
    trackId: 'strategy',
    title: 'Preço médio no Mo Lucro',
    summary: 'Como o app calcula o preço médio das suas compras e vendas.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'O preço médio é quanto, em média, você pagou por cada ação ou cota que tem hoje. Ele é a base para saber se a posição está no lucro ou no prejuízo.',
      },
      { type: 'h', text: 'Como o cálculo funciona' },
      {
        type: 'list',
        items: [
          'Compra: soma a quantidade e o valor pago. O preço médio é o total investido dividido pela quantidade.',
          'Venda: reduz a quantidade e retira do total investido o valor calculado ao preço médio da hora. Por isso vender não muda o preço médio do que sobra.',
          'Antes de calcular, o app ordena as operações da mais antiga para a mais nova.',
        ],
      },
      {
        type: 'callout',
        tone: 'example',
        title: 'Exemplo',
        text: 'Compra de 10 a R$ 20 e compra de 10 a R$ 30: 20 unidades, R$ 500 investidos, preço médio de R$ 25. Venda de 5 a R$ 40: sobram 15 unidades, o preço médio continua R$ 25 e o lucro realizado é 5 × (40 − 25) = R$ 75.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Registre cada operação com o preço e a data reais. Um valor digitado errado distorce o preço médio de tudo o que vem depois.',
      },
    ],
    cta: { label: 'Registrar um aporte', route: '/operations/new' },
  },
  {
    id: 'diversificacao',
    trackId: 'strategy',
    title: 'Diversificação',
    summary: 'Distribuir os aportes para que um erro não derrube tudo.',
    minutes: 5,
    blocks: [
      {
        type: 'p',
        text: 'Diversificar é dividir o dinheiro entre ativos que não reagem da mesma forma aos mesmos eventos. Se um cai, os outros podem segurar o resultado.',
      },
      { type: 'h', text: 'Em quais camadas diversificar' },
      {
        type: 'list',
        items: [
          'Classes de ativos: renda fixa, ações, FIIs, criptomoedas.',
          'Dentro de cada classe: várias empresas e fundos, de setores diferentes.',
          'Emissores: no crédito bancário, mais de um banco quando o valor passa do limite do FGC.',
          'Tempo: aportes ao longo dos meses, em vez de tudo de uma vez.',
        ],
      },
      {
        type: 'callout',
        tone: 'example',
        title: 'Exemplo didático de alocação',
        text: 'Renda fixa 50%, ações 25%, FIIs 20% e outros 5%. Serve só para ilustrar a ideia: a divisão certa depende do seu perfil, do prazo e dos seus objetivos.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Na aba Portfólio do Mo Lucro você vê a distribuição da carteira por categoria, para comparar com a alocação que definiu.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'Ter muitos ativos não é o mesmo que estar diversificado. Cinco ações do mesmo setor tendem a cair juntas.',
      },
    ],
  },
  {
    id: 'rebalanceamento',
    trackId: 'strategy',
    title: 'Rebalanceamento com aportes',
    summary: 'Use o dinheiro novo para voltar à alocação que você definiu.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'Com o tempo, o que sobe passa a pesar mais na carteira e a alocação se afasta da que você planejou. Rebalancear é trazer as proporções de volta.',
      },
      {
        type: 'p',
        text: 'A forma mais simples é usar o próprio aporte: em vez de vender o que cresceu, você direciona o dinheiro novo para a classe que ficou abaixo da meta. Assim evita custos e um possível imposto sobre a venda.',
      },
      {
        type: 'callout',
        tone: 'example',
        text: 'Meta de 50% em renda fixa e 50% em ações. Hoje você tem R$ 10.000: R$ 4.000 em renda fixa (40%) e R$ 6.000 em ações (60%). Você aporta os R$ 2.000 inteiros em renda fixa. O total vira R$ 12.000, com R$ 6.000 em cada classe, sem vender nada.',
      },
      { type: 'h', text: 'Quando revisar' },
      {
        type: 'list',
        items: [
          'Em datas fixas, como a cada 6 meses ou uma vez por ano.',
          'Ou quando uma classe se afastar da meta por uma margem que você definiu, por exemplo 5 pontos percentuais.',
        ],
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Rebalancear com mais frequência não garante melhor resultado. Revisões constantes geram custo e ansiedade.',
      },
    ],
  },

  // ───────────────────────── Impostos e custos ─────────────────────────
  {
    id: 'imposto-renda-fixa',
    trackId: 'taxes',
    title: 'Imposto na renda fixa',
    summary: 'A tabela regressiva: quanto mais tempo, menos imposto.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'O Imposto de Renda da renda fixa incide só sobre o rendimento, não sobre o valor aportado, e é descontado automaticamente no resgate ou no vencimento. Quanto mais tempo o dinheiro fica aplicado, menor a alíquota.',
      },
      {
        type: 'table',
        head: ['Prazo da aplicação', 'Alíquota'],
        rows: [
          ['Até 180 dias', '22,5%'],
          ['De 181 a 360 dias', '20%'],
          ['De 361 a 720 dias', '17,5%'],
          ['Acima de 720 dias', '15%'],
        ],
      },
      {
        type: 'callout',
        tone: 'example',
        text: 'Uma aplicação resgatada com 200 dias e R$ 1.000 de rendimento paga 20% de IR, ou R$ 200. Sobram R$ 800 de rendimento líquido.',
      },
      { type: 'h', text: 'Isentos para pessoa física' },
      {
        type: 'list',
        items: [
          'LCI e LCA.',
          'Caderneta de poupança.',
          'CRI, CRA e debêntures incentivadas.',
        ],
      },
      {
        type: 'p',
        text: 'O IOF incide só em resgates com menos de 30 dias e diminui a cada dia. Depois desse prazo, não é cobrado.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Cada aporte tem o próprio prazo, contado a partir da sua data. Os aportes mais recentes pagam mais imposto se forem resgatados cedo.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'As regras tributárias mudam. Confirme as alíquotas vigentes na Receita Federal ou com um contador antes de decidir.',
      },
    ],
  },
  {
    id: 'imposto-renda-variavel',
    trackId: 'taxes',
    title: 'Imposto em ações e FIIs',
    summary: 'Quando há imposto, quanto é e até quando pagar.',
    minutes: 5,
    blocks: [
      { type: 'h', text: 'Ações em operações comuns' },
      {
        type: 'list',
        items: [
          'Vendas de até R$ 20 mil no mês, somando todas as ações: o lucro é isento.',
          'Vendas acima de R$ 20 mil no mês: 15% sobre o lucro do mês, e todo o ganho perde a isenção, inclusive o das vendas menores.',
          'O limite considera o valor vendido, não o lucro.',
        ],
      },
      { type: 'h', text: 'Day trade' },
      {
        type: 'p',
        text: 'Compra e venda no mesmo dia pagam 20% sobre o lucro, sem isenção.',
      },
      { type: 'h', text: 'Fundos imobiliários' },
      {
        type: 'list',
        items: [
          'Rendimentos mensais: isentos para pessoa física, se o fundo cumprir as condições da lei.',
          'Lucro na venda das cotas: 20%, sem isenção para vendas pequenas.',
        ],
      },
      {
        type: 'callout',
        tone: 'example',
        text: 'Você vendeu R$ 15.000 em ações no mês e lucrou R$ 2.000: nada a pagar. Se tivesse vendido R$ 25.000 com o mesmo lucro, pagaria 15% de R$ 2.000, ou seja, R$ 300.',
      },
      { type: 'h', text: 'Como pagar' },
      {
        type: 'p',
        text: 'O imposto é pago por DARF até o último dia útil do mês seguinte à venda. Tudo precisa ser informado na declaração anual do Imposto de Renda, inclusive os ganhos isentos. Prejuízos podem ser compensados com lucros futuros da mesma modalidade.',
      },
      {
        type: 'callout',
        tone: 'warning',
        text: 'As regras tributárias mudam. Confirme os valores vigentes na Receita Federal ou com um contador. Para dividendos e JCP, veja a aula própria.',
      },
    ],
  },
  {
    id: 'custos',
    trackId: 'taxes',
    title: 'Custos que corroem os aportes',
    summary: 'Taxas pequenas, somadas ao longo dos anos, pesam muito.',
    minutes: 4,
    blocks: [
      {
        type: 'p',
        text: 'Todo investimento tem algum custo, e ele é cobrado mesmo quando o resultado é ruim. Como os juros compostos também valem para o que você paga, taxas pequenas viram grandes diferenças com o tempo.',
      },
      { type: 'h', text: 'Custos mais comuns' },
      {
        type: 'list',
        items: [
          'Corretagem: taxa por ordem. Muitas corretoras zeraram para ações e FIIs.',
          'Emolumentos e liquidação da B3: valores pequenos cobrados sobre o volume negociado.',
          'Taxa de administração: cobrada por fundos e ETFs, ao ano, direto no valor da cota.',
          'Taxa de performance: parte do que o fundo rende acima de uma meta.',
          'Custódia: no Tesouro Direto, existe a taxa da B3 e, em alguns casos, a da corretora.',
        ],
      },
      {
        type: 'callout',
        tone: 'example',
        text: 'Uma taxa de administração de 2% ao ano sobre R$ 100.000 custa R$ 2.000 por ano, mesmo em um ano de prejuízo. Uma taxa de 0,5% custaria R$ 500.',
      },
      {
        type: 'callout',
        tone: 'tip',
        text: 'Antes de aportar em um fundo, compare a taxa com a de opções parecidas. Se o rendimento bruto é o mesmo, a menor taxa deixa mais dinheiro com você.',
      },
    ],
  },

  // ───────────────────────── Glossário ─────────────────────────
  {
    id: 'glossario',
    trackId: 'glossary',
    title: 'Glossário do investidor',
    summary: 'Os termos mais comuns, em ordem alfabética.',
    minutes: 6,
    blocks: [
      {
        type: 'terms',
        items: [
          { term: 'Aporte', definition: 'Valor que você coloca em um investimento.' },
          {
            term: 'Ativo',
            definition: 'Qualquer investimento que você possui, como uma ação, uma cota de fundo ou um título.',
          },
          {
            term: 'Benchmark',
            definition: 'Referência para comparar o desempenho de um investimento, como o CDI ou o Ibovespa.',
          },
          {
            term: 'CDI',
            definition:
              'Taxa de juros dos empréstimos entre bancos, muito próxima da Selic. É o indicador mais usado na renda fixa pós-fixada.',
          },
          { term: 'Custódia', definition: 'Guarda e registro dos ativos em seu nome.' },
          {
            term: 'Diversificação',
            definition: 'Dividir o dinheiro em ativos diferentes para não depender de um só.',
          },
          {
            term: 'Dividend yield',
            definition: 'Proventos pagos em 12 meses divididos pelo preço atual do ativo.',
          },
          {
            term: 'FGC',
            definition:
              'Fundo que devolve depósitos e certos títulos bancários se a instituição quebrar, dentro de um limite.',
          },
          {
            term: 'IPCA',
            definition: 'Índice oficial de inflação do Brasil.',
          },
          {
            term: 'Liquidez',
            definition: 'Rapidez com que você transforma o investimento em dinheiro sem perder valor.',
          },
          {
            term: 'Marcação a mercado',
            definition:
              'Atualização diária do preço de um título de acordo com as taxas de juros do mercado.',
          },
          {
            term: 'P/VP',
            definition: 'Preço da ação ou cota dividido pelo valor patrimonial por ação ou cota.',
          },
          {
            term: 'Preço médio',
            definition: 'Média ponderada do que você pagou pelas unidades que possui.',
          },
          {
            term: 'Proventos',
            definition:
              'Valores que a empresa ou o fundo paga ao investidor, como dividendos, JCP e rendimentos.',
          },
          {
            term: 'Rebalanceamento',
            definition: 'Ajuste da carteira para voltar às proporções planejadas.',
          },
          {
            term: 'Rentabilidade bruta e líquida',
            definition:
              'Bruta é o rendimento antes de impostos e taxas. Líquida é o que sobra depois deles.',
          },
          {
            term: 'Selic',
            definition: 'Taxa básica de juros da economia, definida pelo Banco Central.',
          },
          {
            term: 'Volatilidade',
            definition: 'Intensidade das variações de preço de um ativo.',
          },
        ],
      },
    ],
  },
];

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

export function getTrack(id: string): Track | undefined {
  return TRACKS.find((track) => track.id === id);
}

export function getLesson(id: string): Lesson | undefined {
  return LESSONS.find((lesson) => lesson.id === id);
}

export function lessonsOfTrack(trackId: string): Lesson[] {
  return LESSONS.filter((lesson) => lesson.trackId === trackId);
}

/** A aula que vem logo depois na ordem do conteúdo, se existir. */
export function nextLesson(id: string): Lesson | undefined {
  const index = LESSONS.findIndex((lesson) => lesson.id === id);
  return index >= 0 ? LESSONS[index + 1] : undefined;
}

/** Minúsculas e sem acentos, para a busca ignorar “Preço” x “preco”. */
export function normalizeText(text: string): string {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();
}

function blockText(block: Block): string {
  switch (block.type) {
    case 'p':
    case 'h':
      return block.text;
    case 'list':
      return block.items.join(' ');
    case 'callout':
      return `${block.title ?? ''} ${block.text}`;
    case 'table':
      return [...block.head, ...block.rows.flat()].join(' ');
    case 'terms':
      return block.items.map((item) => `${item.term} ${item.definition}`).join(' ');
    case 'calculator':
      return 'calculadora juros compostos';
  }
}

/** Texto pesquisável de uma aula: título, resumo e corpo, já normalizado. */
export function lessonSearchText(lesson: Lesson): string {
  return normalizeText(
    `${lesson.title} ${lesson.summary} ${lesson.blocks.map(blockText).join(' ')}`,
  );
}