import 'package:smart_scanner/features/save/domain/entities/saved_scan_file.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';

abstract class InspectionExportRepository {
  Future<SavedScanFile> exportInspectionList(List<ScanItem> items);
}
