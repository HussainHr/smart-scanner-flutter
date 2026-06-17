import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';

abstract class ScanFileRepository {
  Future<List<ScanFileEntry>> listSavedFiles();
}
