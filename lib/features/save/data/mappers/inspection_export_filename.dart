import 'package:intl/intl.dart';

abstract final class InspectionExportFilename {
  static final DateFormat _timestampFormat = DateFormat('yyyyMMdd_HHmmss');

  static String build() {
    final timestamp = _timestampFormat.format(DateTime.now());
    return 'inspection_$timestamp.xlsx';
  }
}
