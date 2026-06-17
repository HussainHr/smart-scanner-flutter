import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';

abstract class ScanFileRepository {
  Future<List<ScanFileEntry>> listSavedFiles();

  Future<List<int>> readFileBytes(ScanFileEntry entry);

  Future<void> shareFile(ScanFileEntry entry);

  Future<void> sendFileByEmail(ScanFileEntry entry);

  Future<void> deleteFile(ScanFileEntry entry);
}
