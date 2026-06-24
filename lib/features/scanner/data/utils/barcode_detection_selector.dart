import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_scanner/features/scanner/data/utils/barcode_value_normalizer.dart';

abstract final class BarcodeDetectionSelector {
  static Barcode? selectBest(List<Barcode> barcodes) {
    Barcode? best;
    var bestScore = -1;

    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue?.trim();
      final displayValue = barcode.displayValue?.trim();
      final source = rawValue?.isNotEmpty == true
          ? rawValue!
          : displayValue?.isNotEmpty == true
              ? displayValue!
              : null;
      if (source == null) {
        continue;
      }

      final normalized =
          BarcodeValueNormalizer.normalize(source, barcode.format);
      if (normalized.isEmpty) {
        continue;
      }

      var score = normalized.length * 10;
      if (barcode.format != BarcodeFormat.unknown) {
        score += 50;
      }
      if (barcode.format == BarcodeFormat.code39 ||
          barcode.format == BarcodeFormat.codabar ||
          barcode.format == BarcodeFormat.code128) {
        score += 100;
      }

      final area = barcode.size.width * barcode.size.height;
      if (area.isFinite && area > 0) {
        score += area.round();
      }

      if (score > bestScore) {
        bestScore = score;
        best = barcode;
      }
    }

    return best;
  }
}
