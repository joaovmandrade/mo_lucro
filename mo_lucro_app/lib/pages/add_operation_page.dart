import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/operation_service.dart';
import '../services/market_data_service.dart';
import '../utils/formatters.dart';

// ─────────────────────────────────────────────────────────────
// Asset option model
// ─────────────────────────────────────────────────────────────
class _AssetOption {
  final String ticker;
  final String name;
  const _AssetOption(this.ticker, this.name);
}

// ─────────────────────────────────────────────────────────────
// Static asset lists per category
// ─────────────────────────────────────────────────────────────
const _stocks = [
  _AssetOption('PETR4', 'Petrobras'),
  _AssetOption('PETR3', 'Petrobras ON'),
  _AssetOption('VALE3', 'Vale'),
  _AssetOption('ITUB4', 'Itaú Unibanco'),
  _AssetOption('ITUB3', 'Itaú Unibanco ON'),
  _AssetOption('BBDC4', 'Bradesco'),
  _AssetOption('BBDC3', 'Bradesco ON'),
  _AssetOption('ABEV3', 'Ambev'),
  _AssetOption('B3SA3', 'B3'),
  _AssetOption('WEGE3', 'Weg'),
  _AssetOption('RENT3', 'Localiza'),
  _AssetOption('RADL3', 'Raia Drogasil'),
  _AssetOption('MGLU3', 'Magazine Luiza'),
  _AssetOption('PRIO3', 'PetroRio'),
  _AssetOption('EGIE3', 'Engie Brasil'),
  _AssetOption('BBSE3', 'BB Seguridade'),
  _AssetOption('GGBR4', 'Gerdau'),
  _AssetOption('HAPV3', 'Hapvida'),
  _AssetOption('HYPE3', 'Hypera'),
  _AssetOption('JBSS3', 'JBS'),
  _AssetOption('KLBN11', 'Klabin'),
  _AssetOption('LREN3', 'Lojas Renner'),
  _AssetOption('MDIA3', 'M. Dias Branco'),
  _AssetOption('MRFG3', 'Marfrig'),
  _AssetOption('MULT3', 'Multiplan'),
  _AssetOption('RDOR3', 'Rede D\'Or'),
  _AssetOption('SAPR11', 'Sanepar'),
  _AssetOption('SBSP3', 'Sabesp'),
  _AssetOption('SLCE3', 'SLC Agrícola'),
  _AssetOption('TOTS3', 'Totvs'),
  _AssetOption('UGPA3', 'Ultrapar'),
  _AssetOption('USIM5', 'Usiminas'),
  _AssetOption('VIVT3', 'Telefônica Brasil'),
  _AssetOption('YDUQ3', 'Yduqs'),
  _AssetOption('CSAN3', 'Cosan'),
  _AssetOption('ELET3', 'Eletrobras ON'),
  _AssetOption('ELET6', 'Eletrobras PNB'),
  _AssetOption('ENEV3', 'Eneva'),
  _AssetOption('SUZB3', 'Suzano'),
  _AssetOption('BBAS3', 'Banco do Brasil'),
];

const _cryptos = [
  _AssetOption('BTC', 'Bitcoin'),
  _AssetOption('ETH', 'Ethereum'),
  _AssetOption('BNB', 'BNB (Binance)'),
  _AssetOption('SOL', 'Solana'),
  _AssetOption('ADA', 'Cardano'),
  _AssetOption('XRP', 'XRP (Ripple)'),
  _AssetOption('DOGE', 'Dogecoin'),
  _AssetOption('DOT', 'Polkadot'),
  _AssetOption('MATIC', 'Polygon'),
  _AssetOption('LTC', 'Litecoin'),
  _AssetOption('USDT', 'Tether'),
  _AssetOption('USDC', 'USD Coin'),
];

const _fixedIncome = [
  _AssetOption('SELIC', 'Tesouro Selic'),
  _AssetOption('IPCA+', 'Tesouro IPCA+'),
  _AssetOption('PRE', 'Tesouro Prefixado'),
  _AssetOption('CDB', 'CDB'),
  _AssetOption('LCI', 'LCI'),
  _AssetOption('LCA', 'LCA'),
  _AssetOption('CRI', 'CRI'),
  _AssetOption('CRA', 'CRA'),
  _AssetOption('DEB', 'Debêntures'),
  _AssetOption('POUP', 'Poupança'),
];

const _others = [
  _AssetOption('MXRF11', 'Maxi Renda FII'),
  _AssetOption('HGLG11', 'CSHG Logística FII'),
  _AssetOption('KNRI11', 'Kinea Renda Imob.'),
  _AssetOption('VISC11', 'Vinci Shopping'),
  _AssetOption('XPML11', 'XP Malls'),
  _AssetOption('RBRP11', 'RBR Properties'),
  _AssetOption('BCFF11', 'BTG Pactual FoF'),
  _AssetOption('HFOF11', 'Hedge Top FoF'),
  _AssetOption('OUTRO', 'Outro'),
];

List<_AssetOption> _optionsFor(String category) {
  switch (category) {
    case 'stocks':       return _stocks;
    case 'crypto':       return _cryptos;
    case 'fixed_income': return _fixedIncome;
    default:             return _others;
  }
}

// ─────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────
class AddOperationPage extends StatefulWidget {
  const AddOperationPage({super.key});

  @override
  State<AddOperationPage> createState() => _AddOperationPageState();
}

class _AddOperationPageState extends State<AddOperationPage> {
  final _service = OperationService();
  final _marketService = MarketDataService();
  final _formKey = GlobalKey<FormState>();

  final _assetController  = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController  = TextEditingController();
  final _assetFocusNode   = FocusNode();
  final _layerLink        = LayerLink();

  String _type     = 'buy';
  String _category = 'stocks';
  DateTime _date   = DateTime.now();
  bool _loading    = false;

  // Autocomplete state
  List<_AssetOption> _suggestions = [];
  OverlayEntry? _overlayEntry;
  bool _fetchingPrice = false;
  bool _priceIsAuto   = false;

  static const _categories = {
    'stocks':       'Ações',
    'crypto':       'Criptomoedas',
    'fixed_income': 'Renda Fixa',
    'others':       'Outros',
  };

  @override
  void initState() {
    super.initState();
    _assetFocusNode.addListener(() {
      if (!_assetFocusNode.hasFocus) _removeOverlay();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _assetController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _assetFocusNode.dispose();
    super.dispose();
  }

  // ── Autocomplete logic ───────────────────────────────────
  void _onAssetChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) { _removeOverlay(); return; }

    final lower = trimmed.toLowerCase();
    final matches = _optionsFor(_category)
        .where((o) =>
            o.ticker.toLowerCase().contains(lower) ||
            o.name.toLowerCase().contains(lower))
        .take(6)
        .toList();

    if (matches.isEmpty) { _removeOverlay(); return; }
    _suggestions = matches;
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(builder: (_) => _SuggestionsOverlay(
      link: _layerLink,
      suggestions: _suggestions,
      onSelect: _selectAsset,
    ));
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectAsset(_AssetOption option) {
    _removeOverlay();
    _assetController.text = option.ticker;
    _assetFocusNode.unfocus();
    // Reset price when a new asset is selected
    setState(() {
      _priceIsAuto = false;
      _priceController.clear();
    });
    _fetchPrice(option.ticker);
  }

  Future<void> _fetchPrice(String ticker) async {
    if (_category == 'fixed_income') return; // manual for fixed income
    setState(() => _fetchingPrice = true);

    final quote = await _marketService.getQuote(ticker, category: _category);

    if (!mounted) return;
    setState(() {
      _fetchingPrice = false;
      if (quote.success && quote.price > 0) {
        _priceController.text = quote.price.toStringAsFixed(2);
        _priceIsAuto = true;
      }
    });
  }

  // ── Form helpers ─────────────────────────────────────────
  double get _total {
    final qty   = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0;
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'))    ?? 0;
    return qty * price;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final qty   = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));

    if (qty == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valores inválidos'), backgroundColor: AppColors.loss),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.addOperation(
        type:     _type,
        asset:    _assetController.text.trim().toUpperCase(),
        category: _category,
        quantity: qty,
        price:    price,
        date:     _date,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operação registrada!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.loss),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onCategoryChanged(String cat) {
    setState(() {
      _category      = cat;
      _priceIsAuto   = false;
      _fetchingPrice = false;
    });
    _assetController.clear();
    _priceController.clear();
    _removeOverlay();
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        title: const Text('Nova Operação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ── Tipo ──────────────────────────────────────
            _Label('Tipo de operação'),
            const SizedBox(height: 8),
            Row(children: [
              _TypeBtn(label: 'Compra', value: 'buy',
                  selected: _type, color: AppColors.profit,
                  onTap: (v) => setState(() => _type = v)),
              const SizedBox(width: 10),
              _TypeBtn(label: 'Venda', value: 'sell',
                  selected: _type, color: AppColors.loss,
                  onTap: (v) => setState(() => _type = v)),
            ]),
            const SizedBox(height: 20),

            // ── Categoria ─────────────────────────────────
            _Label('Categoria'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bg1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  dropdownColor: AppColors.bg1,
                  isExpanded: true,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  items: _categories.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) => _onCategoryChanged(v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Ativo (com autocomplete) ───────────────────
            _Label('Código do ativo'),
            const SizedBox(height: 8),
            CompositedTransformTarget(
              link: _layerLink,
              child: TextFormField(
                controller: _assetController,
                focusNode: _assetFocusNode,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
                decoration: InputDecoration(
                  hintText: _hintForCategory(_category),
                  prefixIcon: const Icon(Icons.bar_chart, color: AppColors.textMuted),
                  suffixIcon: _assetController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _assetController.clear();
                            _priceController.clear();
                            setState(() { _priceIsAuto = false; });
                            _removeOverlay();
                          },
                        )
                      : null,
                ),
                onChanged: _onAssetChanged,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o código' : null,
              ),
            ),
            const SizedBox(height: 16),

            // ── Quantidade + Preço ─────────────────────────
            Row(children: [
              // Quantidade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Quantidade'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: '100'),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Preço (read-only quando auto)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      _Label('Preço (R\$)'),
                      if (_priceIsAuto) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.profit.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Auto',
                              style: TextStyle(
                                  color: AppColors.profitDark,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      readOnly: _priceIsAuto,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          color: _priceIsAuto
                              ? AppColors.profitDark
                              : AppColors.textPrimary,
                          fontWeight: _priceIsAuto ? FontWeight.w700 : FontWeight.normal),
                      decoration: InputDecoration(
                        hintText: '0,00',
                        filled: true,
                        fillColor: _priceIsAuto ? AppColors.profit.withOpacity(0.06) : AppColors.bg3,
                        suffixIcon: _fetchingPrice
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.primary),
                                ),
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Data ──────────────────────────────────────
            _Label('Data'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bg1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 12),
                  Text(AppFormatters.dateFull(_date),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // ── Total preview ─────────────────────────────
            if (_total > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total da operação',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(AppFormatters.currency(_total),
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Salvar ────────────────────────────────────
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Salvar operação'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _hintForCategory(String cat) {
    switch (cat) {
      case 'stocks':       return 'Ex: PETR4, VALE3...';
      case 'crypto':       return 'Ex: BTC, ETH...';
      case 'fixed_income': return 'Ex: CDB, SELIC...';
      default:             return 'Ex: MXRF11...';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Suggestions overlay
// ─────────────────────────────────────────────────────────────
class _SuggestionsOverlay extends StatelessWidget {
  final LayerLink link;
  final List<_AssetOption> suggestions;
  final ValueChanged<_AssetOption> onSelect;

  const _SuggestionsOverlay({
    required this.link,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: MediaQuery.of(context).size.width - 40,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(0, 56),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: suggestions.asMap().entries.map((entry) {
                final i = entry.key;
                final opt = entry.value;
                return _SuggestionItem(
                  option: opt,
                  isLast: i == suggestions.length - 1,
                  onTap: () => onSelect(opt),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final _AssetOption option;
  final bool isLast;
  final VoidCallback onTap;

  const _SuggestionItem({
    required this.option,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(0),
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                option.ticker.length > 3
                    ? option.ticker.substring(0, 3)
                    : option.ticker,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.ticker,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(option.name,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.north_west_rounded,
              color: AppColors.textMuted, size: 14),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color color;
  final ValueChanged<String> onTap;

  const _TypeBtn({
    required this.label, required this.value,
    required this.selected, required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : AppColors.bg1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
