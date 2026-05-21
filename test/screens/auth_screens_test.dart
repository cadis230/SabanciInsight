import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_step_3/screens/forgot_password_flow.dart';

import 'package:project_step_3/screens/login_screen.dart';

void main() {
  testWidgets('Login shows error when email is empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email giriniz'), findsOneWidget);
  });

  testWidgets('Login shows error when email domain is not Sabanci', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Sabancı Üniversitesi email adresi giriniz'), findsOneWidget);
  });

  testWidgets('Login shows error when password is shorter than 6 characters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'test@sabanciuniv.edu');
    await tester.enterText(find.byType(TextFormField).at(1), '123');

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('En az 6 karakter giriniz'), findsOneWidget);
  });

  testWidgets('Forgot password Send Code button is disabled for invalid email', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'test@gmail.com');
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(button.onPressed, isNull);
  });

  testWidgets('Forgot password Send Code button is enabled for Sabanci email', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'test@sabanciuniv.edu');
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(button.onPressed, isNotNull);
  });
}

