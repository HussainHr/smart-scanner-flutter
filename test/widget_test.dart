import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/app.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';

void main() {
  testWidgets('Smart Scanner bootstrap screen renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartScannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
  });
}
