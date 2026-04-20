import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mo_lucro_app/pages/login_page.dart';

void main() {
  testWidgets('Login page renders email, password and button',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign in'), findsOneWidget);
  });
}
