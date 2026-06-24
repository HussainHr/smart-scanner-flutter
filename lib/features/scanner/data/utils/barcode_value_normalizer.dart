import 'package:mobile_scanner/mobile_scanner.dart';

abstract final class BarcodeValueNormalizer {
  static const _codabarStops = 'abcdABCD';

  static String normalize(String rawValue, BarcodeFormat format) {
    var value = rawValue.trim();
    if (value.isEmpty) {
      return value;
    }

    return switch (format) {
      BarcodeFormat.code39 => _normalizeCode39(value),
      BarcodeFormat.codabar => _normalizeCodabar(value),
      _ => value.replaceAll(RegExp(r'\s+'), ' ').trim(),
    };
  }

  static String _normalizeCode39(String value) {
    var normalized = value.replaceAll('*', '');
    normalized = normalized.replaceAll(RegExp(r'\s+'), '');
    return normalized.toUpperCase();
  }

  static String _normalizeCodabar(String value) {
    var normalized = value.replaceAll(RegExp(r'\s+'), '');

    if (normalized.length >= 2 &&
        _codabarStops.contains(normalized[0]) &&
        _codabarStops.contains(normalized[normalized.length - 1])) {
      normalized = normalized.substring(1, normalized.length - 1);
    }

    return normalized.toUpperCase();
  }
}
