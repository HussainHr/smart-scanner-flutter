import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

abstract final class InspectionExcelMapper {
  static const _headers = ['#', 'Code', 'Quantity', 'Type', 'Scanned At'];

  static final DateFormat _scannedAtFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static const _headerFill = 'FF0E7490';
  static const _headerFont = 'FFFFFFFF';
  static const _zebraFill = 'FFF1F5F9';

  static Uint8List toBytes(List<ScanItem> items) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet() ?? excel.tables.keys.first;
    excel.rename(defaultSheet, 'Inspection List');
    final activeSheet = excel['Inspection List'];

    _setColumnWidths(activeSheet);

    for (var column = 0; column < _headers.length; column++) {
      final cell = activeSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0),
      );
      cell.value = TextCellValue(_headers[column]);
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
        fontColorHex: ExcelColor.fromHexString(_headerFont),
        backgroundColorHex: ExcelColor.fromHexString(_headerFill),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final rowIndex = index + 1;
      final isEvenRow = rowIndex.isEven;

      _writeCell(
        activeSheet,
        columnIndex: 0,
        rowIndex: rowIndex,
        value: '${index + 1}',
        isEvenRow: isEvenRow,
        align: HorizontalAlign.Center,
      );
      _writeCell(
        activeSheet,
        columnIndex: 1,
        rowIndex: rowIndex,
        value: item.value,
        isEvenRow: isEvenRow,
      );
      _writeCell(
        activeSheet,
        columnIndex: 2,
        rowIndex: rowIndex,
        value: '${item.quantity}',
        isEvenRow: isEvenRow,
        align: HorizontalAlign.Center,
      );
      _writeCell(
        activeSheet,
        columnIndex: 3,
        rowIndex: rowIndex,
        value: item.type.label,
        isEvenRow: isEvenRow,
      );
      _writeCell(
        activeSheet,
        columnIndex: 4,
        rowIndex: rowIndex,
        value: _scannedAtFormat.format(item.scannedAt),
        isEvenRow: isEvenRow,
      );
    }

    final encoded = excel.encode();
    if (encoded == null) {
      throw StateError('Failed to encode inspection spreadsheet.');
    }

    return Uint8List.fromList(encoded);
  }

  static void _setColumnWidths(Sheet sheet) {
    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 28);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 14);
    sheet.setColumnWidth(4, 24);
  }

  static void _writeCell(
    Sheet sheet, {
    required int columnIndex,
    required int rowIndex,
    required String value,
    required bool isEvenRow,
    HorizontalAlign align = HorizontalAlign.Left,
  }) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: columnIndex,
        rowIndex: rowIndex,
      ),
    );
    cell.value = TextCellValue(value);
    cell.cellStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: align,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: isEvenRow
          ? ExcelColor.fromHexString(_zebraFill)
          : ExcelColor.white,
    );
  }
}
