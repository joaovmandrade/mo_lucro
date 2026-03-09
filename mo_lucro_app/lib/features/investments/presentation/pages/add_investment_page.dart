import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Add/Create investment form page.
class AddInvestmentPage extends StatefulWidget {
  const AddInvestmentPage({super.key});

  @override
  State<AddInvestmentPage> createState() => _AddInvestmentPageState();
}

class _AddInvestmentPageState extends State<AddInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _institutionController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'CDB';
  String _selectedIndexer = 'CDI';
  String _selectedLiquidity = 'DIARIA';
  DateTime _investmentDate = DateTime.now();
  DateTime? _maturityDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Investimento'),
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
            // Type selector
            const Text('Tipo de Ativo', style: TextStyle(
              fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.investmentTypes.map((type) {
                final isSelected = _selectedType == type['value'];
                return ChoiceChip(
                  label: Text(type['label'] as String),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedType = type['value'] as String),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Nome do Ativo',
              hint: 'Ex: CDB Banco Inter 120%',
              controller: _nameController,
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Valor Aplicado (R\$)',
              hint: '0,00',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.attach_money),
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),

            // Indexer + Rate
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Indexador', style: TextStyle(
                        fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedIndexer,
                        items: AppConstants.indexerTypes.map((idx) {
                          return DropdownMenuItem(
                            value: idx['value'] as String,
                            child: Text(idx['label'] as String),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() =>
                            _selectedIndexer = v ?? 'CDI'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Taxa (%)',
                    hint: '120',
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Instituição',
              hint: 'Ex: Nubank, Inter, XP',
              controller: _institutionController,
              prefixIcon: const Icon(Icons.business),
            ),
            const SizedBox(height: 16),

            // Liquidity
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Liquidez', style: TextStyle(
                  fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedLiquidity,
                  items: AppConstants.liquidityTypes.map((liq) {
                    return DropdownMenuItem(
                      value: liq['value'] as String,
                      child: Text(liq['label'] as String),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() =>
                      _selectedLiquidity = v ?? 'DIARIA'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Data do Aporte',
                    hint: 'Selecionar',
                    readOnly: true,
                    controller: TextEditingController(
                      text: '${_investmentDate.day.toString().padLeft(2, '0')}/'
                          '${_investmentDate.month.toString().padLeft(2, '0')}/'
                          '${_investmentDate.year}',
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _investmentDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _investmentDate = date);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Vencimento',
                    hint: 'Opcional',
                    readOnly: true,
                    controller: TextEditingController(
                      text: _maturityDate != null
                          ? '${_maturityDate!.day.toString().padLeft(2, '0')}/'
                              '${_maturityDate!.month.toString().padLeft(2, '0')}/'
                              '${_maturityDate!.year}'
                          : '',
                    ),
                    prefixIcon: const Icon(Icons.event),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2050),
                      );
                      if (date != null) {
                        setState(() => _maturityDate = date);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Observações',
              hint: 'Anotações sobre o investimento...',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            AppButton(
              text: 'Salvar Investimento',
              isLoading: _isLoading,
              icon: Icons.check_rounded,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Save via API
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
