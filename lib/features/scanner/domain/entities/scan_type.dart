enum ScanType {
  barcode,
  qr,
  ocr,
}

extension ScanTypeLabel on ScanType {
  String get label {
    return switch (this) {
      ScanType.barcode => 'Barcode',
      ScanType.qr => 'QR Code',
      ScanType.ocr => 'OCR',
    };
  }
}
