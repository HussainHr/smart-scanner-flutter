enum ScanMode {
  barcodeQr,
  ocr,
}

extension ScanModeLabel on ScanMode {
  String get label {
    return switch (this) {
      ScanMode.barcodeQr => 'BR/QR',
      ScanMode.ocr => 'OCR',
    };
  }
}
