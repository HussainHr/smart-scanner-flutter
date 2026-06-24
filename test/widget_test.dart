import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/app.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/presentation/providers/file_list_providers.dart';

class _EmptyFileListNotifier extends FileListNotifier {
  @override
  Future<List<ScanFileEntry>> build() async => [];
}

void main() {
  testWidgets('Home screen shows main menu options', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartScannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Main Menu'), findsOneWidget);
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
    expect(find.text('Save'), findsNothing);
    expect(find.text('BR/QR'), findsOneWidget);
  });

  testWidgets('Home navigates to saved file list screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fileListProvider.overrideWith(_EmptyFileListNotifier.new),
        ],
        child: const SmartScannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved File List'));
    await tester.pumpAndSettle();

    expect(find.text('Saved File List'), findsWidgets);
    expect(find.text('No saved files yet'), findsOneWidget);
  });
}
