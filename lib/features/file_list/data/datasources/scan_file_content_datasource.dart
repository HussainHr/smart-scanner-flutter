import 'package:smart_scanner/core/share/gmail_share_helper.dart';
import 'package:smart_scanner/core/storage/media_store_storage.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:share_plus/share_plus.dart';

class ScanFileContentDatasource {
  Future<List<int>> readBytes(ScanFileEntry entry) {
    return MediaStoreStorage.readFileBytes(entry);
  }

  Future<void> share(ScanFileEntry entry) async {
    final file = await MediaStoreStorage.prepareShareableFile(entry);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: _mimeTypeFor(entry.fileName),
          name: entry.fileName,
        ),
      ],
      subject: entry.fileName,
      text: 'Inspection scan export',
    );
  }

  Future<void> sendByEmail(ScanFileEntry entry) async {
    final file = await MediaStoreStorage.prepareShareableFile(entry);

    await GmailShareHelper.shareFile(
      filePath: file.path,
      mimeType: _mimeTypeFor(entry.fileName),
      subject: 'Inspection List - ${entry.fileName}',
      body: 'Please find the attached inspection list.',
      fileName: entry.fileName,
    );
  }

  Future<void> delete(ScanFileEntry entry) {
    return MediaStoreStorage.deleteSavedFile(entry);
  }

  String _mimeTypeFor(String fileName) {
    if (fileName.toLowerCase().endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }

    return 'text/csv';
  }
}
