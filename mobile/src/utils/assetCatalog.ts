/** Listas estáticas de ativos por categoria — porte de add_operation_page.dart. */

export type AssetOption = { ticker: string; name: string };

const STOCKS: AssetOption[] = [
  { ticker: 'PETR4', name: 'Petrobras' },
  { ticker: 'PETR3', name: 'Petrobras ON' },
  { ticker: 'VALE3', name: 'Vale' },
  { ticker: 'ITUB4', name: 'Itaú Unibanco' },
  { ticker: 'ITUB3', name: 'Itaú Unibanco ON' },
  { ticker: 'BBDC4', name: 'Bradesco' },
  { ticker: 'BBDC3', name: 'Bradesco ON' },
  { ticker: 'ABEV3', name: 'Ambev' },
  { ticker: 'B3SA3', name: 'B3' },
  { ticker: 'WEGE3', name: 'Weg' },
  { ticker: 'RENT3', name: 'Localiza' },
  { ticker: 'RADL3', name: 'Raia Drogasil' },
  { ticker: 'MGLU3', name: 'Magazine Luiza' },
  { ticker: 'PRIO3', name: 'PetroRio' },
  { ticker: 'EGIE3', name: 'Engie Brasil' },
  { ticker: 'BBSE3', name: 'BB Seguridade' },
  { ticker: 'GGBR4', name: 'Gerdau' },
  { ticker: 'HAPV3', name: 'Hapvida' },
  { ticker: 'HYPE3', name: 'Hypera' },
  { ticker: 'JBSS3', name: 'JBS' },
  { ticker: 'KLBN11', name: 'Klabin' },
  { ticker: 'LREN3', name: 'Lojas Renner' },
  { ticker: 'MDIA3', name: 'M. Dias Branco' },
  { ticker: 'MRFG3', name: 'Marfrig' },
  { ticker: 'MULT3', name: 'Multiplan' },
  { ticker: 'RDOR3', name: "Rede D'Or" },
  { ticker: 'SAPR11', name: 'Sanepar' },
  { ticker: 'SBSP3', name: 'Sabesp' },
  { ticker: 'SLCE3', name: 'SLC Agrícola' },
  { ticker: 'TOTS3', name: 'Totvs' },
  { ticker: 'UGPA3', name: 'Ultrapar' },
  { ticker: 'USIM5', name: 'Usiminas' },
  { ticker: 'VIVT3', name: 'Telefônica Brasil' },
  { ticker: 'YDUQ3', name: 'Yduqs' },
  { ticker: 'CSAN3', name: 'Cosan' },
  { ticker: 'ELET3', name: 'Eletrobras ON' },
  { ticker: 'ELET6', name: 'Eletrobras PNB' },
  { ticker: 'ENEV3', name: 'Eneva' },
  { ticker: 'SUZB3', name: 'Suzano' },
  { ticker: 'BBAS3', name: 'Banco do Brasil' },
];

const CRYPTOS: AssetOption[] = [
  { ticker: 'BTC', name: 'Bitcoin' },
  { ticker: 'ETH', name: 'Ethereum' },
  { ticker: 'BNB', name: 'BNB (Binance)' },
  { ticker: 'SOL', name: 'Solana' },
  { ticker: 'ADA', name: 'Cardano' },
  { ticker: 'XRP', name: 'XRP (Ripple)' },
  { ticker: 'DOGE', name: 'Dogecoin' },
  { ticker: 'DOT', name: 'Polkadot' },
  { ticker: 'MATIC', name: 'Polygon' },
  { ticker: 'LTC', name: 'Litecoin' },
  { ticker: 'USDT', name: 'Tether' },
  { ticker: 'USDC', name: 'USD Coin' },
];

const FIXED_INCOME: AssetOption[] = [
  { ticker: 'SELIC', name: 'Tesouro Selic' },
  { ticker: 'IPCA+', name: 'Tesouro IPCA+' },
  { ticker: 'PRE', name: 'Tesouro Prefixado' },
  { ticker: 'CDB', name: 'CDB' },
  { ticker: 'LCI', name: 'LCI' },
  { ticker: 'LCA', name: 'LCA' },
  { ticker: 'CRI', name: 'CRI' },
  { ticker: 'CRA', name: 'CRA' },
  { ticker: 'DEB', name: 'Debêntures' },
  { ticker: 'POUP', name: 'Poupança' },
];

const OTHERS: AssetOption[] = [
  { ticker: 'MXRF11', name: 'Maxi Renda FII' },
  { ticker: 'HGLG11', name: 'CSHG Logística FII' },
  { ticker: 'KNRI11', name: 'Kinea Renda Imob.' },
  { ticker: 'VISC11', name: 'Vinci Shopping' },
  { ticker: 'XPML11', name: 'XP Malls' },
  { ticker: 'RBRP11', name: 'RBR Properties' },
  { ticker: 'BCFF11', name: 'BTG Pactual FoF' },
  { ticker: 'HFOF11', name: 'Hedge Top FoF' },
  { ticker: 'OUTRO', name: 'Outro' },
];

export function optionsFor(category: string): AssetOption[] {
  switch (category) {
    case 'stocks':
      return STOCKS;
    case 'crypto':
      return CRYPTOS;
    case 'fixed_income':
      return FIXED_INCOME;
    default:
      return OTHERS;
  }
}

/** Até 6 sugestões por ticker ou nome, como _onAssetChanged. */
export function suggestAssets(category: string, query: string): AssetOption[] {
  const trimmed = query.trim().toLowerCase();
  if (trimmed.length === 0) return [];

  return optionsFor(category)
    .filter(
      (option) =>
        option.ticker.toLowerCase().includes(trimmed) ||
        option.name.toLowerCase().includes(trimmed),
    )
    .slice(0, 6);
}

export function assetHintFor(category: string): string {
  switch (category) {
    case 'stocks':
      return 'Ex: PETR4, VALE3...';
    case 'crypto':
      return 'Ex: BTC, ETH...';
    case 'fixed_income':
      return 'Ex: CDB, SELIC...';
    default:
      return 'Ex: MXRF11...';
  }
}
