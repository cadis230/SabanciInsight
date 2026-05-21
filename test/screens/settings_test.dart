import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:project_step_3/screens/settings_screen.dart';
import 'package:project_step_3/providers/theme_provider.dart';
import 'package:project_step_3/providers/auth_provider.dart';

void main() {

  testWidgets('Settings screen renders main settings options', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Delete Uploaded Transcript'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
  });
}