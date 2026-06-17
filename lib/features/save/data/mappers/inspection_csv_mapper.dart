import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

abstract final class InspectionCsvMapper {
  static const _headers = ['#', 'Type', 'Value', 'Scanned At'];

  static final DateFormat _scannedAtFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String toCsv(List<ScanItem> items) {
    final rows = <List<dynamic>>[
      _headers,
      for (var index = 0; index < items.length; index++)
        [
          index + 1,
          items[index].type.label,
          items[index].value,
          _scannedAtFormat.format(items[index].scannedAt),
        ],
    ];

    return const ListToCsvConverter().convert(rows);
  }
}

abstract final class InspectionFileNameBuilder {
  static final DateFormat _timestampFormat = DateFormat('yyyyMMdd_HHmmss');

  static String build() {
    final timestamp = _timestampFormat.format(DateTime.now());
    return 'inspection_$timestamp.csv';
  }
}
