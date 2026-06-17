class SavedScanFile {
  const SavedScanFile({
    required this.path,
    required this.fileName,
    required this.savedAt,
    required this.itemCount,
  });

  final String path;
  final String fileName;
  final DateTime savedAt;
  final int itemCount;
}
