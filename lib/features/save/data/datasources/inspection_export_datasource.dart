import 'dart:io';

import 'package:smart_scanner/core/storage/scans_directory.dart';
import 'package:smart_scanner/features/save/domain/entities/saved_scan_file.dart';

class InspectionExportDatasource {
  Future<SavedScanFile> saveCsv({
    required String fileName,
    required String csvContent,
    required int itemCount,
  }) async {
    final scansDir = await ScansDirectory.resolve();
    final file = File('${scansDir.path}/$fileName');

    await file.writeAsString(csvContent);

    return SavedScanFile(
      path: file.path,
      fileName: fileName,
      savedAt: DateTime.now(),
      itemCount: itemCount,
    );
  }
}
