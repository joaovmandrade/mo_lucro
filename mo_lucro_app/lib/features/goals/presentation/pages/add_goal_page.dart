import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});
  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  String _type = 'RESERVA_EMERGENCIA';
  String _priority = 'MEDIA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Meta'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Tipo da Meta', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppConstants.goalTypes.map((t) {
                final sel = _type == t['value'];
                return ChoiceChip(
                  label: Text(t['label'] as String),
                  selected: sel,
                  onSelected: (_) => setState(() => _type = t['value'] as String),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            AppTextField(label: 'Nome da Meta', hint: 'Ex: Viagem 2026', controller: _nameController,
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
            const SizedBox(height: 16),
            AppTextField(label: 'Valor Alvo (R\$)', hint: '0,00', controller: _targetController,
              keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null),
            const SizedBox(height: 16),
            AppTextField(label: 'Valor Atual (R\$)', hint: '0,00', controller: _currentController,
              keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prioridade', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items: AppConstants.priorities.map((p) =>
                    DropdownMenuItem(value: p['value'] as String, child: Text(p['label'] as String))).toList(),
                  onChanged: (v) => setState(() => _priority = v ?? 'MEDIA'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            AppButton(text: 'Salvar Meta', icon: Icons.check_rounded,
              onPressed: () { if (_formKey.currentState!.validate()) context.pop(); }),
          ],
        ),
      ),
    );
  }
}
