import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/file_list/data/datasources/scan_file_local_datasource.dart';
import 'package:smart_scanner/features/file_list/presentation/utils/file_display_formatter.dart';

void main() {
  group('ScanFileLocalDatasource', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('smart_scanner_test_');
    });

    tearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('lists csv files sorted by modified date descending', () async {
      final olderFile = File('${tempDirectory.path}/inspection_old.csv');
      final newerFile = File('${tempDirectory.path}/inspection_new.csv');

      await olderFile.writeAsString(
        '#,Type,Value,Scanned At\n1,Barcode,OLD,2026-06-16 10:00:00\n',
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await newerFile.writeAsString(
        '#,Type,Value,Scanned At\n1,Barcode,NEW,2026-06-16 11:00:00\n2,QR Code,NEW2,2026-06-16 11:01:00\n',
      );

      final datasource = ScanFileLocalDatasource(
        directoriesOverride: [tempDirectory],
      );

      final files = await datasource.listSavedFiles();

      expect(files.length, 2);
      expect(files.first.fileName, 'inspection_new.csv');
      expect(files.first.rowCount, 2);
      expect(files.last.fileName, 'inspection_old.csv');
      expect(files.last.rowCount, 1);
    });
  });

  group('FileDisplayFormatter', () {
    test('formats bytes and kilobytes', () {
      expect(FileDisplayFormatter.formatFileSize(512), '512 B');
      expect(FileDisplayFormatter.formatFileSize(2048), '2.0 KB');
    });
  });
}
