import 'package:flutter/material.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_data_table.dart';

class CsvPreviewTable extends StatelessWidget {
  const CsvPreviewTable({
    super.key,
    required this.rows,
  });

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text('No data rows found in this file.'),
      );
    }

    final headers = rows.first;
    final dataRows = rows.length > 1 ? rows.sublist(1) : <List<String>>[];

    final tableRows = <InspectionTableRow>[
      for (var index = 0; index < dataRows.length; index++)
        InspectionTableRow(
          id: '$index',
          code: _readCode(dataRows[index], headers),
          quantity: _readQuantity(dataRows[index], headers),
        ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: InspectionDataTable(rows: tableRows),
    );
  }

  String _readCode(List<String> row, List<String> headers) {
    final code = _cellValue(row, headers, 'Code');
    if (code != '-') {
      return code;
    }

    return _cellValue(row, headers, 'Value');
  }

  int _readQuantity(List<String> row, List<String> headers) {
    return int.tryParse(_cellValue(row, headers, 'Quantity', fallback: '1')) ?? 1;
  }

  String _cellValue(
    List<String> row,
    List<String> headers,
    String headerName, {
    String fallback = '-',
  }) {
    final headerIndex = headers.indexWhere(
      (header) => header.toLowerCase() == headerName.toLowerCase(),
    );

    if (headerIndex == -1 || headerIndex >= row.length) {
      return fallback;
    }

    final value = row[headerIndex].trim();
    return value.isEmpty ? fallback : value;
  }
}
