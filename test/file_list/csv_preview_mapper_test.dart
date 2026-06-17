import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/file_list/data/mappers/csv_preview_mapper.dart';

void main() {
  group('CsvPreviewMapper', () {
    test('parses csv rows into string cells', () {
      const content =
          '#,Code,Quantity,Type,Scanned At\n1,A~001-12345,2,Barcode,2026-06-16 14:30:45\n2,QR-VALUE,1,QR Code,2026-06-16 14:31:10';

      final rows = CsvPreviewMapper.parseRows(content);

      expect(rows.length, 3);
      expect(rows.first, ['#', 'Code', 'Quantity', 'Type', 'Scanned At']);
      expect(rows[1][1], 'A~001-12345');
      expect(rows[1][2], '2');
    });

    test('returns empty list for blank content', () {
      expect(CsvPreviewMapper.parseRows('   '), isEmpty);
    });
  });
}
