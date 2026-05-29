import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';

// Dark blue colors specific to the login screen
const _kLoginBg = Color(0xFF1B2A4A);
const _kLoginCard = Color(0xFF243158);
const _kLoginInput = Color(0xFF1E2D50);
const _kLoginBorder = Color(0xFF344370);
const _kLoginBlue = Color(0xFF1E88E5);
const _kLoginText = Colors.white;
const _kLoginDim = Color(0x80FFFFFF);
const _kLoginMuted = Color(0x40FFFFFF);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isSignUp = false;
  String? _error;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: const [
                Icon(Icons.check_circle_outline,
                    color: AppColors.profit, size: 18),
                SizedBox(width: 8),
                Text('Conta criada com sucesso! Bem-vindo 🎉'),
              ]),
            ),
          );
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = _friendlyError(e.message));
    } catch (_) {
      setState(() => _error = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _error = null;
      _passCtrl.clear();
      _confirmCtrl.clear();
    });
    _animCtrl.reset();
    _animCtrl.forward();
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'Email ou senha incorretos.';
    }
    if (raw.contains('already registered') ||
        raw.contains('already been registered')) {
      return 'Este email já está cadastrado.';
    }
    if (raw.contains('weak_password') || raw.contains('weak password')) {
      return 'Senha muito fraca (mínimo 6 caracteres).';
    }
    if (raw.contains('network') || raw.contains('Failed to fetch')) {
      return 'Sem conexão. Verifique sua internet.';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: _kLoginBg,
      body: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -80,
            left: -60,
            child: _Circle(size: 220, color: _kLoginBlue.withOpacity(0.08)),
          ),
          Positioned(
            top: 40,
            left: -30,
            child: _Circle(size: 130, color: _kLoginBlue.withOpacity(0.06)),
          ),
          Positioned(
            bottom: -60,
            right: -50,
            child: _Circle(size: 200, color: _kLoginBlue.withOpacity(0.06)),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // ── Logo ──────────────────────────
                        _Logo(),
                        const SizedBox(height: 36),

                        // ── Title ─────────────────────────
                        Text(
                          _isSignUp ? 'Crie sua conta' : 'Bem-vindo de volta',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _kLoginText,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isSignUp
                              ? 'Comece a investir agora'
                              : 'Acesse sua conta para continuar',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _kLoginDim,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Card ──────────────────────────
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _kLoginCard,
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: _kLoginBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // E-mail
                              _FieldLabel('E-MAIL'),
                              const SizedBox(height: 8),
                              _LoginField(
                                controller: _emailCtrl,
                                hint: 'seu@email.com',
                                prefixIcon:
                                    Icons.alternate_email_rounded,
                                keyboardType:
                                    TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Informe o email';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(v))
                                    return 'Email inválido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Senha
                              _FieldLabel('SENHA'),
                              const SizedBox(height: 8),
                              _LoginField(
                                controller: _passCtrl,
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePass,
                                suffixIcon: _EyeToggle(
                                  obscure: _obscurePass,
                                  onTap: () => setState(
                                      () => _obscurePass = !_obscurePass),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Informe a senha';
                                  if (_isSignUp && v.length < 6)
                                    return 'Mínimo 6 caracteres';
                                  return null;
                                },
                              ),

                              // Confirmar senha (signup)
                              if (_isSignUp) ...[
                                const SizedBox(height: 20),
                                _FieldLabel('CONFIRMAR SENHA'),
                                const SizedBox(height: 8),
                                _LoginField(
                                  controller: _confirmCtrl,
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: _obscureConfirm,
                                  suffixIcon: _EyeToggle(
                                    obscure: _obscureConfirm,
                                    onTap: () => setState(() =>
                                        _obscureConfirm = !_obscureConfirm),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Confirme a senha';
                                    if (v != _passCtrl.text)
                                      return 'As senhas não coincidem';
                                    return null;
                                  },
                                ),
                              ],

                              if (!_isSignUp) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Esqueceu a senha?',
                                    style: const TextStyle(
                                      color: _kLoginBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],

                              // Error
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                _ErrorBanner(message: _error!),
                              ],

                              const SizedBox(height: 20),

                              // Submit
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kLoginBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.lg),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _isSignUp
                                                  ? 'Cadastrar'
                                                  : 'Entrar',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 18),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Divider ───────────────────────
                        Row(children: [
                          Expanded(
                            child: Container(
                                height: 1, color: _kLoginBorder),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14),
                            child: const Text(
                              'ou',
                              style: TextStyle(
                                  color: _kLoginMuted, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                height: 1, color: _kLoginBorder),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // ── Google ────────────────────────
                        Tooltip(
                          message: 'Em breve',
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: _kLoginBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.lg),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _kLoginBorder,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                          color: _kLoginDim,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Continuar com Google',
                                    style: TextStyle(
                                      color: _kLoginDim,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Toggle ────────────────────────
                        GestureDetector(
                          onTap: _toggleMode,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: _isSignUp
                                  ? 'Já tem uma conta? '
                                  : 'Não tem uma conta? ',
                              style: const TextStyle(
                                color: _kLoginMuted,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: _isSignUp ? 'Entrar' : 'Cadastre-se',
                                  style: const TextStyle(
                                    color: _kLoginBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kLoginBlue.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.bar_chart_rounded,
              color: Colors.white, size: 32),
        ),
        const SizedBox(height: 14),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Mo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Lucro',
                style: TextStyle(
                  color: _kLoginBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Invista. Cresça. Ganhe.',
          style: TextStyle(
            color: _kLoginDim,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _kLoginDim,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LoginField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autocorrect: false,
      style: const TextStyle(color: _kLoginText, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: _kLoginMuted, fontSize: 14),
        filled: true,
        fillColor: _kLoginInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: _kLoginBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: _kLoginBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide:
              const BorderSide(color: _kLoginBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.loss),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide:
              const BorderSide(color: AppColors.loss, width: 1.5),
        ),
        prefixIcon: Icon(prefixIcon, color: _kLoginDim, size: 18),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 16),
        errorStyle: const TextStyle(color: AppColors.loss),
      ),
      validator: validator,
    );
  }
}

class _EyeToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;
  const _EyeToggle({required this.obscure, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: _kLoginDim,
          size: 20,
        ),
        onPressed: onTap,
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.loss.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.loss.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.loss, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.loss, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
