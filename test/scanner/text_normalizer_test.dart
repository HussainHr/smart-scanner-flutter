import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/scanner/data/utils/text_normalizer.dart';

void main() {
  group('normalizeRecognizedText', () {
    test('trims and collapses whitespace', () {
      expect(
        normalizeRecognizedText('  Smart   Scanner  App  '),
        'Smart Scanner App',
      );
    });

    test('returns empty string for blank input', () {
      expect(normalizeRecognizedText('   \n\t  '), '');
      expect(normalizeRecognizedText(null), '');
    });
  });
}
