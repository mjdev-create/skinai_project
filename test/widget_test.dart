import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('Home screen shows Open Login button', (WidgetTester tester) async {
    await tester.pumpWidget(const SkinaiApp());

    expect(find.text('Open Login'), findsOneWidget);

    await tester.tap(find.text('Open Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login placeholder'), findsOneWidget);
  });
}