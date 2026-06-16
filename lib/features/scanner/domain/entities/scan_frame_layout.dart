import 'dart:ui';

abstract final class ScanFrameLayout {
  static const Size barcodeFrame = Size(220, 220);
  static const Size ocrFrame = Size(220, 140);

  static Size frameForMode(bool isOcrMode) {
    return isOcrMode ? ocrFrame : barcodeFrame;
  }
}
