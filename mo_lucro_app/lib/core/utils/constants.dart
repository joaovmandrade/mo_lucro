/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const appName = 'Mo Lucro';
  static const appVersion = '1.0.0';

  // Investment types
  static const investmentTypes = [
    {'value': 'CDB', 'label': 'CDB', 'icon': 'account_balance'},
    {'value': 'TESOURO_DIRETO', 'label': 'Tesouro Direto', 'icon': 'flag'},
    {'value': 'POUPANCA', 'label': 'Poupança', 'icon': 'savings'},
    {'value': 'ACOES', 'label': 'Ações', 'icon': 'show_chart'},
    {'value': 'FUNDOS_IMOBILIARIOS', 'label': 'Fundos Imobiliários', 'icon': 'apartment'},
    {'value': 'FUNDOS', 'label': 'Fundos', 'icon': 'pie_chart'},
    {'value': 'CRIPTO', 'label': 'Criptomoedas', 'icon': 'currency_bitcoin'},
    {'value': 'CAIXA', 'label': 'Caixa', 'icon': 'account_balance_wallet'},
    {'value': 'OUTROS', 'label': 'Outros', 'icon': 'more_horiz'},
  ];

  // Indexers
  static const indexerTypes = [
    {'value': 'CDI', 'label': '% do CDI'},
    {'value': 'IPCA', 'label': 'IPCA +'},
    {'value': 'PREFIXADO', 'label': 'Prefixado'},
    {'value': 'SELIC', 'label': 'Selic'},
    {'value': 'NENHUM', 'label': 'Nenhum'},
  ];

  // Liquidity
  static const liquidityTypes = [
    {'value': 'DIARIA', 'label': 'Liquidez Diária'},
    {'value': 'D1', 'label': 'D+1'},
    {'value': 'D2', 'label': 'D+2'},
    {'value': 'D30', 'label': 'D+30'},
    {'value': 'NO_VENCIMENTO', 'label': 'No Vencimento'},
    {'value': 'VARIAVEL', 'label': 'Variável'},
  ];

  // Goal types
  static const goalTypes = [
    {'value': 'RESERVA_EMERGENCIA', 'label': 'Reserva de Emergência', 'icon': 'shield'},
    {'value': 'VIAGEM', 'label': 'Viagem', 'icon': 'flight'},
    {'value': 'CARRO', 'label': 'Carro', 'icon': 'directions_car'},
    {'value': 'CASA_PROPRIA', 'label': 'Casa Própria', 'icon': 'home'},
    {'value': 'APOSENTADORIA', 'label': 'Aposentadoria', 'icon': 'elderly'},
    {'value': 'ESTUDOS', 'label': 'Estudos', 'icon': 'school'},
    {'value': 'PERSONALIZADA', 'label': 'Meta Personalizada', 'icon': 'star'},
  ];

  // Priorities
  static const priorities = [
    {'value': 'BAIXA', 'label': 'Baixa'},
    {'value': 'MEDIA', 'label': 'Média'},
    {'value': 'ALTA', 'label': 'Alta'},
    {'value': 'URGENTE', 'label': 'Urgente'},
  ];

  // Disclaimer
  static const disclaimer =
      'As informações apresentadas são de caráter educativo e não '
      'constituem recomendação de investimento. Consulte um profissional '
      'certificado antes de tomar decisões financeiras.';
}
