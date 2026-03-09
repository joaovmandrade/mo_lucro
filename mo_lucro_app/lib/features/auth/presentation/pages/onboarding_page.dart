import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Onboarding screens (3 pages) introducing the app.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Controle Total',
      description:
          'Organize seus investimentos e gastos pessoais em um único lugar, '
          'de forma simples e segura.',
      color: AppColors.primary,
    ),
    _OnboardingData(
      icon: Icons.insights_rounded,
      title: 'Análises Inteligentes',
      description:
          'Acompanhe a evolução do seu patrimônio, analise riscos e '
          'compare rentabilidades com gráficos visuais.',
      color: AppColors.secondary,
    ),
    _OnboardingData(
      icon: Icons.school_rounded,
      title: 'Educação Financeira',
      description:
          'Descubra seu perfil de investidor e receba orientações '
          'educativas personalizadas para suas finanças.',
      color: AppColors.invested,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Pular'),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 80,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: i == _currentPage ? 32 : 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Começar'
                        : 'Próximo',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        context.go('/login');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
