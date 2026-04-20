import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/investments/presentation/pages/investments_page.dart';
import '../../features/investments/presentation/pages/add_investment_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/goals/presentation/pages/add_goal_page.dart';
import '../../features/simulators/presentation/pages/simulator_page.dart';
import '../../features/reports/presentation/pages/risk_analysis_page.dart';
import '../../features/profile/presentation/pages/profile_quiz_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/reports/presentation/pages/maturity_calendar_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../shell/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // --- Public routes ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // --- Authenticated routes with bottom nav ---
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/investments',
            builder: (context, state) => const InvestmentsPage(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesPage(),
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // --- Full-screen routes ---
      GoRoute(
        path: '/investments/add',
        builder: (context, state) => const AddInvestmentPage(),
      ),
      GoRoute(
        path: '/expenses/add',
        builder: (context, state) => const AddExpensePage(),
      ),
      GoRoute(
        path: '/goals/add',
        builder: (context, state) => const AddGoalPage(),
      ),
      GoRoute(
        path: '/simulators',
        builder: (context, state) => const SimulatorPage(),
      ),
      GoRoute(
        path: '/reports/risk',
        builder: (context, state) => const RiskAnalysisPage(),
      ),
      GoRoute(
        path: '/reports/maturities',
        builder: (context, state) => const MaturityCalendarPage(),
      ),
      GoRoute(
        path: '/profile/quiz',
        builder: (context, state) => const ProfileQuizPage(),
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const NewsPage(),
      ),
    ],
  );
});
