import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/app.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';

void main() {
  testWidgets('Home screen shows main menu options', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartScannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Scanner'), findsOneWidget);
    expect(find.text('Saved File List'), findsOneWidget);
  });

  testWidgets('Home navigates to scanner and back', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartScannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scanner'));
    await tester.pumpAndSettle();

    expect(find.text('Scanner'), findsWidgets);
    expect(
      find.text('Camera scanning will be implemented in Sprint 2.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Main Menu'), findsOneWidget);
  });
}
