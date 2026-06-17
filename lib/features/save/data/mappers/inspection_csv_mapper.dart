import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

abstract final class InspectionCsvMapper {
  static const _headers = ['#', 'Code', 'Quantity', 'Type', 'Scanned At'];

  static final DateFormat _scannedAtFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String toCsv(List<ScanItem> items) {
    final rows = <List<dynamic>>[
      _headers,
      for (var index = 0; index < items.length; index++)
        [
          index + 1,
          items[index].value,
          items[index].quantity,
          items[index].type.label,
          _scannedAtFormat.format(items[index].scannedAt),
        ],
    ];

    return const ListToCsvConverter().convert(rows);
  }
}
