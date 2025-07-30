// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:civiquizz/main.dart';

void main() {
  testWidgets('Civiquizz app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CiviquizzApp());

    // Verify that the login screen is displayed
    expect(find.text('Civiquizz'), findsOneWidget);
    expect(find.text('Le Jeu de la Constitution'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
  });
}
