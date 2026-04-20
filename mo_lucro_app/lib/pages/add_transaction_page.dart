import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/transaction_service.dart';
import '../utils/formatters.dart';

class AddTransactionPage extends StatefulWidget {
  /// 'income' or 'expense' — pre-selected type
  final String initialType;

  const AddTransactionPage({super.key, this.initialType = 'expense'});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _service = TransactionService();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  late String _type;
  String _category = 'others';
  DateTime _date = DateTime.now();
  bool _loading = false;

  static const _expenseCategories = {
    'food': 'Alimentação',
    'transport': 'Transporte',
    'health': 'Saúde',
    'education': 'Educação',
    'entertainment': 'Lazer',
    'housing': 'Moradia',
    'utilities': 'Utilidades',
    'others': 'Outros',
  };

  static const _incomeCategories = {
    'salary': 'Salário',
    'investment': 'Investimento',
    'others': 'Outros',
  };

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Map<String, String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

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
      await _service.addTransaction(
        type: _type,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        category: _category,
        description: _descController.text.trim(),
        date: _date,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação registrada!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: AppColors.loss),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'income';
    final typeColor = isIncome ? AppColors.profit : AppColors.loss;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: const Text('Nova Transação'),
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
            _SectionLabel('Tipo'),
            const SizedBox(height: 8),
            Row(
              children: [
                _TypeBtn(
                  label: 'Receita',
                  value: 'income',
                  selected: _type,
                  color: AppColors.profit,
                  icon: Icons.arrow_upward_rounded,
                  onTap: (v) {
                    setState(() {
                      _type = v;
                      _category = 'others';
                    });
                  },
                ),
                const SizedBox(width: 10),
                _TypeBtn(
                  label: 'Despesa',
                  value: 'expense',
                  selected: _type,
                  color: AppColors.loss,
                  icon: Icons.arrow_downward_rounded,
                  onTap: (v) {
                    setState(() {
                      _type = v;
                      _category = 'others';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount
            _SectionLabel('Valor'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: typeColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: '0,00',
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                    color: typeColor, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o valor';
                if (double.tryParse(v.replaceAll(',', '.')) == null)
                  return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

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
                  value: _categories.containsKey(_category)
                      ? _category
                      : _categories.keys.first,
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

            // Description
            _SectionLabel('Descrição (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              maxLength: 80,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ex: Almoço, Uber, Netflix...',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _SectionLabel('Data'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
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
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.bg0),
                    )
                  : Text(isIncome ? 'Registrar receita' : 'Registrar despesa'),
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

class _TypeBtn extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color color;
  final IconData icon;
  final ValueChanged<String> onTap;

  const _TypeBtn({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.icon,
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppColors.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : AppColors.textMuted, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
