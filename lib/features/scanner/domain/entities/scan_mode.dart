enum ScanMode {
  barcodeQr,
  ocr,
}

extension ScanModeLabel on ScanMode {
  String get label {
    return switch (this) {
      ScanMode.barcodeQr => 'Barcode / QR',
      ScanMode.ocr => 'OCR',
    };
  }
}
