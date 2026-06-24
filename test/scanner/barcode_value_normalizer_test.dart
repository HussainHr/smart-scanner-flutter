import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_scanner/features/scanner/data/utils/barcode_value_normalizer.dart';

void main() {
  group('BarcodeValueNormalizer', () {
    test('normalizes spaced Code 39 values with asterisks', () {
      expect(
        BarcodeValueNormalizer.normalize(
          '* 4 9 1 0 0 4 1 8 5 0 0 0 1 *',
          BarcodeFormat.code39,
        ),
        '4910041850001',
      );
    });

    test('normalizes compact Code 39 values', () {
      expect(
        BarcodeValueNormalizer.normalize(
          '*4910041851000000*',
          BarcodeFormat.code39,
        ),
        '4910041851000000',
      );
    });

    test('normalizes Codabar NW-7 values with start and stop characters', () {
      expect(
        BarcodeValueNormalizer.normalize(
          'a1234561234a',
          BarcodeFormat.codabar,
        ),
        '1234561234',
      );

      expect(
        BarcodeValueNormalizer.normalize(
          'b 1 2 3 4 5 6 2 3 4 5 b',
          BarcodeFormat.codabar,
        ),
        '1234562345',
      );
    });

    test('trims generic barcode values', () {
      expect(
        BarcodeValueNormalizer.normalize('  ABC-123  ', BarcodeFormat.code128),
        'ABC-123',
      );
    });
  });
}
