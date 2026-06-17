import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';

abstract final class ScansDirectory {
  static Future<Directory> resolveForAppStorage() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    return _ensureExists(
      Directory('${appDirectory.path}/${AppConstants.scansDirectoryName}'),
    );
  }

  static Future<List<Directory>> resolveLegacyDirectories() async {
    final directories = <Directory>[];
    final seenPaths = <String>{};

    for (final directory in [
      await resolveForAppStorage(),
      await _legacyScansDirectory(),
    ]) {
      if (seenPaths.add(directory.path)) {
        directories.add(directory);
      }
    }

    return directories;
  }

  static String toDisplayPath(String absolutePath) {
    const internalStoragePrefix = '/storage/emulated/0/';
    if (absolutePath.startsWith(internalStoragePrefix)) {
      return absolutePath.replaceFirst(internalStoragePrefix, '');
    }

    return absolutePath;
  }

  static Future<Directory> _legacyScansDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    return Directory('${appDirectory.path}/scans');
  }

  static Future<Directory> _ensureExists(Directory directory) async {
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    return directory;
  }
}
