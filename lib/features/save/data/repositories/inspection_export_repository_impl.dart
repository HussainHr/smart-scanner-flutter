import 'package:smart_scanner/core/errors/app_exception.dart';
import 'package:smart_scanner/features/save/data/datasources/inspection_export_datasource.dart';
import 'package:smart_scanner/features/save/data/mappers/inspection_csv_mapper.dart';
import 'package:smart_scanner/features/save/domain/entities/saved_scan_file.dart';
import 'package:smart_scanner/features/save/domain/repositories/inspection_export_repository.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';

class InspectionExportRepositoryImpl implements InspectionExportRepository {
  InspectionExportRepositoryImpl(this._datasource);

  final InspectionExportDatasource _datasource;

  @override
  Future<SavedScanFile> exportInspectionList(List<ScanItem> items) async {
    if (items.isEmpty) {
      throw const AppException('Inspection list is empty.');
    }

    final csvContent = InspectionCsvMapper.toCsv(items);
    final fileName = InspectionFileNameBuilder.build();

    return _datasource.saveCsv(
      fileName: fileName,
      csvContent: csvContent,
      itemCount: items.length,
    );
  }
}
