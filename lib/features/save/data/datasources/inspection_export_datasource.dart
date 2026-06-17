import 'package:smart_scanner/core/storage/media_store_storage.dart';
import 'package:smart_scanner/features/save/domain/entities/saved_scan_file.dart';

class InspectionExportDatasource {
  Future<SavedScanFile> saveCsv({
    required String fileName,
    required String csvContent,
    required int itemCount,
  }) async {
    final savedFile = await MediaStoreStorage.saveCsv(
      fileName: fileName,
      csvContent: csvContent,
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
