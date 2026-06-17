import 'package:share_plus/share_plus.dart';
import 'package:smart_scanner/core/storage/media_store_storage.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';

class ScanFileContentDatasource {
  Future<String> readContent(ScanFileEntry entry) {
    return MediaStoreStorage.readCsvContent(entry);
  }

  Future<void> share(ScanFileEntry entry) async {
    final file = await MediaStoreStorage.prepareShareableFile(entry);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'text/csv',
          name: entry.fileName,
        ),
      ],
      subject: entry.fileName,
      text: 'Inspection scan export',
    );
  }

  Future<void> sendByEmail(ScanFileEntry entry) async {
    final file = await MediaStoreStorage.prepareShareableFile(entry);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'text/csv',
          name: entry.fileName,
        ),
      ],
      subject: 'Inspection List - ${entry.fileName}',
      text: 'Please find the attached inspection list CSV.',
    );
  }

  Future<void> delete(ScanFileEntry entry) {
    return MediaStoreStorage.deleteCsvFile(entry);
  }
}
