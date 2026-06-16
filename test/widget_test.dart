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

  testWidgets('Home navigates to scanner screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartScannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scanner'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Scanner'), findsWidgets);
    expect(find.text('Inspection List'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Barcode / QR'), findsOneWidget);
  });
}
