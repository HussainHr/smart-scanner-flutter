import 'dart:io';

import 'package:smart_scanner/core/storage/media_store_storage.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';

class ScanFileLocalDatasource {
  ScanFileLocalDatasource({List<Directory>? directoriesOverride})
      : _directoriesOverride = directoriesOverride;

  final List<Directory>? _directoriesOverride;

  Future<List<ScanFileEntry>> listSavedFiles() async {
    if (_directoriesOverride != null) {
      return _listFromDirectories(_directoriesOverride);
    }

    return MediaStoreStorage.listCsvFiles();
  }

  Future<List<ScanFileEntry>> _listFromDirectories(
    List<Directory> directories,
  ) async {
    final entriesByPath = <String, ScanFileEntry>{};

    for (final directory in directories) {
      if (!directory.existsSync()) {
        continue;
      }

      for (final file in directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.csv'))) {
        final stat = await file.stat();
        entriesByPath[file.path] = ScanFileEntry(
          path: file.path,
          fileName: _fileNameFromPath(file.path),
          modifiedAt: stat.modified,
          sizeInBytes: stat.size,
          rowCount: _countCsvRows(file),
        );
      }
    }

    return entriesByPath.values.toList()
      ..sort((left, right) => right.modifiedAt.compareTo(left.modifiedAt));
  }

  String _fileNameFromPath(String path) {
    final separatorIndex = path.lastIndexOf(Platform.pathSeparator);
    if (separatorIndex == -1) {
      return path;
    }

    return path.substring(separatorIndex + 1);
  }

  int _countCsvRows(File file) {
    final lines = file
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return 0;
    }

    return lines.length - 1;
  }
}
