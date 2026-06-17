class ScanFileEntry {
  const ScanFileEntry({
    required this.path,
    required this.fileName,
    required this.modifiedAt,
    required this.sizeInBytes,
    required this.rowCount,
    this.contentUri,
  });

  final String path;
  final String fileName;
  final DateTime modifiedAt;
  final int sizeInBytes;
  final int rowCount;
  final String? contentUri;
}
