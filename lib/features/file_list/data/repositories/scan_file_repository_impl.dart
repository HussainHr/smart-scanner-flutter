import 'package:smart_scanner/features/file_list/data/datasources/scan_file_content_datasource.dart';
import 'package:smart_scanner/features/file_list/data/datasources/scan_file_local_datasource.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/domain/repositories/scan_file_repository.dart';

class ScanFileRepositoryImpl implements ScanFileRepository {
  ScanFileRepositoryImpl(
    this._localDatasource,
    this._contentDatasource,
  );

  final ScanFileLocalDatasource _localDatasource;
  final ScanFileContentDatasource _contentDatasource;

  @override
  Future<List<ScanFileEntry>> listSavedFiles() {
    return _localDatasource.listSavedFiles();
  }

  @override
  Future<String> readFileContent(ScanFileEntry entry) {
    return _contentDatasource.readContent(entry);
  }

  @override
  Future<void> shareFile(ScanFileEntry entry) {
    return _contentDatasource.share(entry);
  }
}
