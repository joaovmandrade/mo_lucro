import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/ai_categorization_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'DESPESA';
  String _category = 'alimentação';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _descController.addListener(_onDescChanged);
  }

  void _onDescChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      final desc = _descController.text;
      if (desc.isNotEmpty && desc.length > 3) {
        final suggestion = await ref.read(aiCategorizationProvider.notifier).suggestCategory(desc);
        if (suggestion != null && mounted) {
          final mapped = _mapDbCategory(suggestion);
          if (mapped != null) {
            setState(() {
              _category = mapped;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Categoria selecionada por IA: $mapped'), duration: const Duration(seconds: 2)),
            );
          }
        }
      }
    });
  }

  String? _mapDbCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('aliment')) return 'alimentação';
    if (lower.contains('transport')) return 'transporte';
    if (lower.contains('saúd') || lower.contains('saud')) return 'saúde';
    if (lower.contains('lazer')) return 'lazer';
    if (lower.contains('educaç') || lower.contains('estud')) return 'estudos';
    if (lower.contains('moradia')) return 'moradia';
    return null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lançamento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'DESPESA'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _type == 'DESPESA'
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _type == 'DESPESA'
                              ? AppColors.error
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text('Despesa',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _type == 'DESPESA'
                                  ? AppColors.error
                                  : AppColors.textTertiary,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = 'RECEITA'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _type == 'RECEITA'
                            ? AppColors.profit.withOpacity(0.1)
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _type == 'RECEITA'
                              ? AppColors.profit
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text('Receita',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _type == 'RECEITA'
                                  ? AppColors.profit
                                  : AppColors.textTertiary,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Descrição',
              hint: 'Ex: Supermercado',
              controller: _descController,
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Valor (R\$)',
              hint: '0,00',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.attach_money),
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Categoria', style: TextStyle(
                  fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: ['alimentação', 'transporte', 'moradia', 'saúde',
                    'lazer', 'estudos', 'contas fixas', 'investimentos', 'outros']
                      .map((c) => DropdownMenuItem(value: c,
                          child: Text(c[0].toUpperCase() + c.substring(1))))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? 'outros'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Salvar',
              icon: Icons.check_rounded,
              onPressed: () {
                if (_formKey.currentState!.validate()) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
