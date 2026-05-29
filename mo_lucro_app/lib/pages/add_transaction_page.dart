import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/transaction_service.dart';
import '../utils/formatters.dart';

class AddTransactionPage extends StatefulWidget {
  final String initialType;
  const AddTransactionPage({super.key, this.initialType = 'expense'});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _service     = TransactionService();
  final _formKey     = GlobalKey<FormState>();
  final _amountCtrl  = TextEditingController();
  final _descCtrl    = TextEditingController();

  late String _type;
  String   _category = 'others';
  DateTime _date     = DateTime.now();
  bool     _loading  = false;

  static const _expenseCategories = {
    'food':          ('Alimentação',  Icons.restaurant_outlined),
    'transport':     ('Transporte',   Icons.directions_car_outlined),
    'health':        ('Saúde',        Icons.local_hospital_outlined),
    'education':     ('Educação',     Icons.school_outlined),
    'entertainment': ('Lazer',        Icons.movie_outlined),
    'housing':       ('Moradia',      Icons.home_outlined),
    'utilities':     ('Utilidades',   Icons.bolt_outlined),
    'shopping':      ('Compras',      Icons.shopping_bag_outlined),
    'others':        ('Outros',       Icons.category_outlined),
  };

  static const _incomeCategories = {
    'salary':        ('Salário',      Icons.work_outlined),
    'investment':    ('Investimento', Icons.trending_up_rounded),
    'bonus':         ('Bônus',        Icons.stars_rounded),
    'others':        ('Outros',       Icons.category_outlined),
  };

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Map<String, (String, IconData)> get _categories =>
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
        type:        _type,
        amount:      double.parse(_amountCtrl.text.replaceAll(',', '.')),
        category:    _category,
        description: _descCtrl.text.trim(),
        date:        _date,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.profit, size: 18),
              const SizedBox(width: 8),
              Text(_type == 'income'
                  ? 'Receita registrada!'
                  : 'Despesa registrada!'),
            ]),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'),
              backgroundColor: AppColors.loss),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome  = _type == 'income';
    final typeColor = isIncome ? AppColors.profit : AppColors.loss;
    final amount    = double.tryParse(
            _amountCtrl.text.replaceAll(',', '.')) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        title: const Text('Nova Transação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Type toggle ──────────────────────────────────
            Row(
              children: [
                _TypeBtn(
                  label: 'Receita',
                  value: 'income',
                  selected: _type,
                  color: AppColors.profit,
                  icon: Icons.arrow_upward_rounded,
                  onTap: (v) => setState(() {
                    _type = v;
                    _category = 'others';
                  }),
                ),
                const SizedBox(width: 10),
                _TypeBtn(
                  label: 'Despesa',
                  value: 'expense',
                  selected: _type,
                  color: AppColors.loss,
                  icon: Icons.arrow_downward_rounded,
                  onTap: (v) => setState(() {
                    _type = v;
                    _category = 'others';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Amount (large) ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(color: typeColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    isIncome ? 'Valor da Receita' : 'Valor da Despesa',
                    style: TextStyle(
                        color: typeColor.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0,00',
                      hintStyle: TextStyle(
                          color: typeColor.withOpacity(0.3), fontSize: 32),
                      prefixText: 'R\$ ',
                      prefixStyle: TextStyle(
                          color: typeColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe o valor';
                      if (double.tryParse(v.replaceAll(',', '.')) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Category grid ────────────────────────────────
            _FieldLabel('Categoria'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.entries.map((e) {
                final isSelected = _category == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _category = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? typeColor.withOpacity(0.12)
                          : AppColors.bg2,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: isSelected ? typeColor : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(e.value.$2,
                            color: isSelected ? typeColor : AppColors.textMuted,
                            size: 14),
                        const SizedBox(width: 5),
                        Text(
                          e.value.$1,
                          style: TextStyle(
                            color: isSelected
                                ? typeColor
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Description ──────────────────────────────────
            _FieldLabel('Descrição (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLength: 80,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ex: Almoço, Uber, Netflix...',
                counterText: '',
                prefixIcon: Icon(Icons.edit_outlined,
                    color: AppColors.textMuted, size: 18),
              ),
            ),
            const SizedBox(height: 16),

            // ── Date ─────────────────────────────────────────
            _FieldLabel('Data'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bg4,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
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
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isIncome ? 'Registrar Receita' : 'Registrar Despesa',
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
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
            color: isSelected ? color.withOpacity(0.12) : AppColors.bg2,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? color : AppColors.textMuted, size: 16),
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
