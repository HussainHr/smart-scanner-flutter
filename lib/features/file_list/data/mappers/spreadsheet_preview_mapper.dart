import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:smart_scanner/features/file_list/data/mappers/csv_preview_mapper.dart';

abstract final class SpreadsheetPreviewMapper {
  static List<List<String>> parseRows(String fileName, Uint8List bytes) {
    if (fileName.toLowerCase().endsWith('.xlsx')) {
      return _parseXlsx(bytes);
    }

    final content = String.fromCharCodes(bytes);
    return CsvPreviewMapper.parseRows(content);
  }

  static List<List<String>> _parseXlsx(Uint8List bytes) {
    if (bytes.isEmpty) {
      return [];
    }

    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.firstOrNull;
    if (sheet == null) {
      return [];
    }

    final rows = <List<String>>[];
    for (var rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
      final row = <String>[];
      for (var columnIndex = 0; columnIndex < sheet.maxColumns; columnIndex++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: columnIndex,
            rowIndex: rowIndex,
          ),
        );
        row.add(_cellToString(cell));
      }

      while (row.isNotEmpty && row.last.trim().isEmpty) {
        row.removeLast();
      }

      if (row.any((cell) => cell.trim().isNotEmpty)) {
        rows.add(row);
      }
    }

    return rows;
  }

  static String _cellToString(Data? cell) {
    if (cell == null || cell.value == null) {
      return '';
    }

    final value = cell.value!;
    if (value is TextCellValue) {
      return value.value.toString();
    }
    if (value is IntCellValue) {
      return '${value.value}';
    }
    if (value is DoubleCellValue) {
      return '${value.value}';
    }
    if (value is BoolCellValue) {
      return '${value.value}';
    }
    if (value is DateCellValue) {
      return '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';
    }
    if (value is DateTimeCellValue) {
      return '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')} '
          '${value.hour.toString().padLeft(2, '0')}:'
          '${value.minute.toString().padLeft(2, '0')}:'
          '${value.second.toString().padLeft(2, '0')}';
    }

    return value.toString();
  }
}
