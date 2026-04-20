import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/goal_service.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _service = GoalService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _service.addGoal(
        title: _titleController.text.trim(),
        targetValue:
            double.parse(_targetController.text.replaceAll(',', '.')),
        currentValue: double.tryParse(
                _currentController.text.replaceAll(',', '.')) ??
            0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meta criada!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: $e'), backgroundColor: AppColors.loss),
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
        title: const Text('Nova Meta'),
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
            // Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Icon(Icons.flag_rounded,
                    color: AppColors.warning, size: 36),
              ),
            ),
            const SizedBox(height: 24),

            _label('Nome da meta'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ex: Reserva de emergência, Viagem...',
                prefixIcon:
                    Icon(Icons.flag_outlined, color: AppColors.textMuted, size: 20),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o nome da meta' : null,
            ),
            const SizedBox(height: 16),

            _label('Valor alvo (R\$)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: '10.000,00',
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                    color: AppColors.warning, fontWeight: FontWeight.w700),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o valor alvo';
                if (double.tryParse(v.replaceAll(',', '.')) == null)
                  return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _label('Valor atual (R\$) — opcional'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '0,00',
                prefixText: 'R\$ ',
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Valor inválido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.bg0),
                    )
                  : const Text('Criar meta'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}
