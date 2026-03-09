import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widget tests for core Mo Lucro UI components.

// Helper to wrap widgets in test-friendly MaterialApp + ProviderScope
Widget createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AppButton Widget', () {
    testWidgets('renders with text', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(createTestApp(
        ElevatedButton(
          onPressed: () => pressed = true,
          child: const Text('Entrar'),
        ),
      ));

      expect(find.text('Entrar'), findsOneWidget);
      await tester.tap(find.text('Entrar'));
      expect(pressed, true);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(createTestApp(
        const ElevatedButton(
          onPressed: null,
          child: SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('StatCard Widget', () {
    testWidgets('displays title and value', (tester) async {
      await tester.pumpWidget(createTestApp(
        Column(children: [
          const Text('Investido'),
          const Text('R\$ 100.000'),
          Icon(Icons.trending_up_rounded, color: Colors.blue),
        ]),
      ));

      expect(find.text('Investido'), findsOneWidget);
      expect(find.text('R\$ 100.000'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });
  });

  group('Login Form', () {
    testWidgets('validates empty email', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(createTestApp(
        Form(
          key: formKey,
          child: Column(children: [
            TextFormField(
              validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            ElevatedButton(
              onPressed: () => formKey.currentState?.validate(),
              child: const Text('Entrar'),
            ),
          ]),
        ),
      ));

      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Obrigatório'), findsOneWidget);
    });

    testWidgets('validates email format', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(createTestApp(
        Form(
          key: formKey,
          child: Column(children: [
            TextFormField(
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obrigatório';
                if (!v.contains('@')) return 'Email inválido';
                return null;
              },
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            ElevatedButton(
              onPressed: () => formKey.currentState?.validate(),
              child: const Text('Validar'),
            ),
          ]),
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'invalido');
      await tester.tap(find.text('Validar'));
      await tester.pump();
      expect(find.text('Email inválido'), findsOneWidget);
    });
  });

  group('Navigation Elements', () {
    testWidgets('bottom nav renders all tabs', (tester) async {
      await tester.pumpWidget(createTestApp(
        Row(children: [
          Column(children: [
            const Icon(Icons.dashboard_rounded),
            const Text('Início'),
          ]),
          Column(children: [
            const Icon(Icons.trending_up_rounded),
            const Text('Investir'),
          ]),
          Column(children: [
            const Icon(Icons.receipt_long_rounded),
            const Text('Gastos'),
          ]),
          Column(children: [
            const Icon(Icons.flag_rounded),
            const Text('Metas'),
          ]),
          Column(children: [
            const Icon(Icons.person_rounded),
            const Text('Perfil'),
          ]),
        ]),
      ));

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Investir'), findsOneWidget);
      expect(find.text('Gastos'), findsOneWidget);
      expect(find.text('Metas'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });
  });
}
