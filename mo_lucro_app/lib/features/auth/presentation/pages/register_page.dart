import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../providers/auth_provider.dart';

/// Register page — connected to AuthProvider.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted && success) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Criar Conta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Preencha seus dados para começar',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 32),

                if (authState.error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(authState.error!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),

                AppTextField(label: 'Nome completo', hint: 'João Silva',
                  controller: _nameController, validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outlined)),
                const SizedBox(height: 20),
                AppTextField(label: 'Email', hint: 'seu@email.com',
                  controller: _emailController, validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined)),
                const SizedBox(height: 20),
                AppTextField(label: 'Senha', hint: 'Mínimo 6 caracteres',
                  controller: _passwordController, validator: Validators.password,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )),
                const SizedBox(height: 20),
                AppTextField(label: 'Confirmar Senha', hint: 'Repita sua senha',
                  controller: _confirmPasswordController,
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                  obscureText: true, prefixIcon: const Icon(Icons.lock_outlined)),
                const SizedBox(height: 32),
                AppButton(text: 'Criar Conta', onPressed: _handleRegister, isLoading: authState.isLoading),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Já tem conta? ', style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(onPressed: () => context.go('/login'),
                    child: const Text('Faça login', style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
