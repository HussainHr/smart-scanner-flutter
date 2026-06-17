import 'package:smart_scanner/features/file_list/data/datasources/scan_file_local_datasource.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/domain/repositories/scan_file_repository.dart';

class ScanFileRepositoryImpl implements ScanFileRepository {
  ScanFileRepositoryImpl(this._datasource);

  final ScanFileLocalDatasource _datasource;

  @override
  Future<List<ScanFileEntry>> listSavedFiles() {
    return _datasource.listSavedFiles();
  }
}
