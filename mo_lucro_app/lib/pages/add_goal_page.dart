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

    // Parse usando replaceAll para vírgula ou ponto
    final targetRaw =
        _targetController.text.trim().replaceAll(',', '.');
    final currentRaw =
        _currentController.text.trim().replaceAll(',', '.');

    final target = double.tryParse(targetRaw);
    final current =
        currentRaw.isEmpty ? 0.0 : double.tryParse(currentRaw);

    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Valor alvo inválido'),
            backgroundColor: AppColors.loss),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.addGoal(
        title: _titleController.text.trim(),
        targetValue: target,
        currentValue: current ?? 0.0,
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
            // ── Icon decorativo ─────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Icon(Icons.flag_rounded,
                    color: AppColors.warning, size: 36),
              ),
            ),
            const SizedBox(height: 24),

            // ── Nome ────────────────────────────────────────
            _Label('Nome da meta'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style:
                  const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ex: Reserva de emergência, Viagem...',
                prefixIcon: Icon(Icons.flag_outlined,
                    color: AppColors.textMuted, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o nome da meta'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Valor alvo ──────────────────────────────────
            _Label('Valor alvo (R\$)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: '10000',
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Informe o valor alvo';
                final parsed =
                    double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0)
                  return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Valor atual (opcional) ──────────────────────
            _Label('Valor atual (R\$) — opcional'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              style:
                  const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '0',
                prefixText: 'R\$ ',
              ),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  if (double.tryParse(v.replaceAll(',', '.')) ==
                      null) {
                    return 'Valor inválido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // ── Save ────────────────────────────────────────
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white))
                  : const Text('Criar meta'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

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