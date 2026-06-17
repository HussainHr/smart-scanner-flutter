import 'dart:typed_data';

import 'package:smart_scanner/core/storage/media_store_storage.dart';
import 'package:smart_scanner/features/save/domain/entities/saved_scan_file.dart';

class InspectionExportDatasource {
  Future<SavedScanFile> saveSpreadsheet({
    required String fileName,
    required Uint8List fileBytes,
    required int itemCount,
  }) async {
    final savedFile = await MediaStoreStorage.saveSpreadsheet(
      fileName: fileName,
      fileBytes: fileBytes,
      itemCount: itemCount,
    );

    return SavedScanFile(
      path: savedFile.path,
      fileName: savedFile.fileName,
      savedAt: DateTime.now(),
      itemCount: itemCount,
    );
  }
}
