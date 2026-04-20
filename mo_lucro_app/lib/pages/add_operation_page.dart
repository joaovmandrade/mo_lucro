import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/operation_service.dart';
import '../utils/formatters.dart';

class AddOperationPage extends StatefulWidget {
  const AddOperationPage({super.key});

  @override
  State<AddOperationPage> createState() => _AddOperationPageState();
}

class _AddOperationPageState extends State<AddOperationPage> {
  final _service = OperationService();
  final _formKey = GlobalKey<FormState>();

  final _assetController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  String _type = 'buy';
  String _category = 'stocks';
  DateTime _date = DateTime.now();
  bool _loading = false;

  static const _categories = {
    'stocks': 'Ações',
    'crypto': 'Criptomoedas',
    'fixed_income': 'Renda Fixa',
    'others': 'Outros',
  };

  @override
  void dispose() {
    _assetController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _total {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return qty * price;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.bg2,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _service.addOperation(
        type: _type,
        asset: _assetController.text.trim().toUpperCase(),
        category: _category,
        quantity: double.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        date: _date,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operação registrada com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: ${e.toString()}'),
              backgroundColor: AppColors.loss),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
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
            // Type toggle
            _SectionLabel('Tipo de operação'),
            const SizedBox(height: 8),
            Row(
              children: [
                _TypeButton(
                  label: 'Compra',
                  value: 'buy',
                  selected: _type,
                  color: AppColors.profit,
                  onTap: (v) => setState(() => _type = v),
                ),
                const SizedBox(width: 10),
                _TypeButton(
                  label: 'Venda',
                  value: 'sell',
                  selected: _type,
                  color: AppColors.loss,
                  onTap: (v) => setState(() => _type = v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category
            _SectionLabel('Categoria'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  dropdownColor: AppColors.bg2,
                  isExpanded: true,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  items: _categories.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Asset
            _SectionLabel('Código do ativo'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _assetController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Ex: PETR4, BTC, TESOURO',
                prefixIcon: Icon(Icons.bar_chart, color: AppColors.textMuted),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o código do ativo' : null,
            ),
            const SizedBox(height: 16),

            // Quantity + Price row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Quantidade'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: '0'),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obrigatório';
                          if (double.tryParse(v) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Preço (R\$)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: '0,00'),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obrigatório';
                          if (double.tryParse(v) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date
            _SectionLabel('Data'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.textMuted, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      AppFormatters.dateFull(_date),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Total preview
            if (_total > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total da operação',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    Text(
                      AppFormatters.currency(_total),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Save button
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.bg0),
                    )
                  : const Text('Salvar operação'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

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

class _TypeButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color color;
  final ValueChanged<String> onTap;

  const _TypeButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
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
            color: isSelected ? color.withOpacity(0.15) : AppColors.bg2,
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
