import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/core/errors/app_exception.dart';
import 'package:smart_scanner/features/save/data/datasources/inspection_export_datasource.dart';
import 'package:smart_scanner/features/save/data/repositories/inspection_export_repository_impl.dart';
import 'package:smart_scanner/features/save/domain/entities/saved_scan_file.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

class _FakeInspectionExportDatasource extends InspectionExportDatasource {
  SavedScanFile? lastSaved;

  @override
  Future<SavedScanFile> saveSpreadsheet({
    required String fileName,
    required Uint8List fileBytes,
    required int itemCount,
  }) async {
    lastSaved = SavedScanFile(
      path: '/tmp/$fileName',
      fileName: fileName,
      savedAt: DateTime(2026, 6, 16, 15, 0),
      itemCount: itemCount,
    );
    return lastSaved!;
  }
}

void main() {
  group('InspectionExportRepositoryImpl', () {
    test('throws when inspection list is empty', () async {
      final datasource = _FakeInspectionExportDatasource();
      final repository = InspectionExportRepositoryImpl(datasource);

      expect(
        () => repository.exportInspectionList([]),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            'Inspection list is empty.',
          ),
        ),
      );
    });

    test('exports items to spreadsheet through datasource', () async {
      final datasource = _FakeInspectionExportDatasource();
      final repository = InspectionExportRepositoryImpl(datasource);
      final items = [
        ScanItem(
          id: '1',
          value: 'ITEM-1',
          type: ScanType.ocr,
          scannedAt: DateTime(2026, 6, 16, 15, 0),
        ),
      ];

      final savedFile = await repository.exportInspectionList(items);

      expect(savedFile.itemCount, 1);
      expect(savedFile.fileName, startsWith('inspection_'));
      expect(savedFile.fileName, endsWith('.xlsx'));
      expect(datasource.lastSaved?.itemCount, 1);
    });
  });
}
