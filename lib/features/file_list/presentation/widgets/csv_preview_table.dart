import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: dataRows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final row = dataRows[index];
        final type = _cellValue(row, headers, 'Type');
        final value = _cellValue(row, headers, 'Value');
        final scannedAt = _cellValue(row, headers, 'Scanned At');
        final rowNumber = _cellValue(row, headers, '#', fallback: '${index + 1}');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#$rowNumber',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                scannedAt,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
              ),
            ],
          ),
        );
      },
    );
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
