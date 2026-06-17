import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/core/errors/app_exception.dart';
import 'package:smart_scanner/core/storage/saved_file_index.dart';
import 'package:smart_scanner/core/storage/scans_directory.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';

class MediaStoreSaveResult {
  const MediaStoreSaveResult({
    required this.path,
    required this.fileName,
    this.contentUri,
  });

  final String path;
  final String fileName;
  final String? contentUri;
}

abstract final class MediaStoreStorage {
  static final MediaStore _mediaStore = MediaStore();

  static Future<MediaStoreSaveResult> saveCsv({
    required String fileName,
    required String csvContent,
    required int itemCount,
  }) async {
    if (!kIsWeb && Platform.isAndroid) {
      return _saveCsvOnAndroid(
        fileName: fileName,
        csvContent: csvContent,
        itemCount: itemCount,
      );
    }

    return _saveCsvToAppStorage(
      fileName: fileName,
      csvContent: csvContent,
      itemCount: itemCount,
    );
  }

  static Future<List<ScanFileEntry>> listCsvFiles() async {
    final entriesByKey = <String, ScanFileEntry>{};

    if (!kIsWeb && Platform.isAndroid) {
      final indexedEntries = await _listIndexedAndroidFiles();
      for (final entry in indexedEntries) {
        entriesByKey[entry.fileName] = entry;
      }

      final directoryEntries = await _listAndroidDirectoryFiles();
      for (final entry in directoryEntries) {
        entriesByKey.putIfAbsent(entry.fileName, () => entry);
      }
    }

    for (final directory in await ScansDirectory.resolveLegacyDirectories()) {
      if (!directory.existsSync()) {
        continue;
      }

      for (final file in directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.csv'))) {
        final stat = await file.stat();
        entriesByKey[file.path] = ScanFileEntry(
          path: file.path,
          fileName: _fileNameFromPath(file.path),
          modifiedAt: stat.modified,
          sizeInBytes: stat.size,
          rowCount: _countCsvRows(file),
        );
      }
    }

    final entries = entriesByKey.values.toList()
      ..sort((left, right) => right.modifiedAt.compareTo(left.modifiedAt));

    return entries;
  }

  static String displayPathLabel() {
    if (!kIsWeb && Platform.isAndroid) {
      return AppConstants.publicScansPathLabel;
    }

    return AppConstants.scansDirectoryName;
  }

  static Future<String> displayPath() async {
    if (!kIsWeb && Platform.isAndroid) {
      return AppConstants.publicScansPathLabel;
    }

    final directory = await ScansDirectory.resolveForAppStorage();
    return ScansDirectory.toDisplayPath(directory.path);
  }

  static Future<MediaStoreSaveResult> _saveCsvOnAndroid({
    required String fileName,
    required String csvContent,
    required int itemCount,
  }) async {
    final tempDirectory = await getTemporaryDirectory();
    final tempFile = File('${tempDirectory.path}/$fileName');
    await tempFile.writeAsString(csvContent, encoding: utf8);

    final saveInfo = await _mediaStore.saveFile(
      tempFilePath: tempFile.path,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    if (saveInfo == null) {
      throw const AppException(
        'Failed to save file to Downloads. Please try again.',
      );
    }

    final contentUri = saveInfo.uri.toString();
    final displayPath = await _mediaStore.getFilePathFromUri(
          uriString: contentUri,
        ) ??
        '${AppConstants.publicScansPathLabel}/${saveInfo.name}';

    await SavedFileIndex.add(
      SavedFileIndexEntry(
        fileName: saveInfo.name,
        path: displayPath,
        contentUri: contentUri,
        savedAt: DateTime.now(),
        itemCount: itemCount,
        sizeInBytes: csvContent.length,
      ),
    );

    return MediaStoreSaveResult(
      path: displayPath,
      fileName: saveInfo.name,
      contentUri: contentUri,
    );
  }

  static Future<MediaStoreSaveResult> _saveCsvToAppStorage({
    required String fileName,
    required String csvContent,
    required int itemCount,
  }) async {
    final scansDirectory = await ScansDirectory.resolveForAppStorage();
    final file = File('${scansDirectory.path}/$fileName');
    await file.writeAsString(csvContent, encoding: utf8);

    await SavedFileIndex.add(
      SavedFileIndexEntry(
        fileName: fileName,
        path: file.path,
        savedAt: DateTime.now(),
        itemCount: itemCount,
        sizeInBytes: csvContent.length,
      ),
    );

    return MediaStoreSaveResult(
      path: file.path,
      fileName: fileName,
    );
  }

  static Future<List<ScanFileEntry>> _listIndexedAndroidFiles() async {
    final entries = <ScanFileEntry>[];

    for (final indexEntry in await SavedFileIndex.readAll()) {
      if (indexEntry.contentUri != null) {
        final exists = await _mediaStore.isFileUriExist(
          uriString: indexEntry.contentUri!,
        );

        if (!exists) {
          continue;
        }
      }

      entries.add(
        ScanFileEntry(
          path: indexEntry.path,
          fileName: indexEntry.fileName,
          modifiedAt: indexEntry.savedAt,
          sizeInBytes: indexEntry.sizeInBytes,
          rowCount: indexEntry.itemCount,
        ),
      );
    }

    return entries;
  }

  static Future<List<ScanFileEntry>> _listAndroidDirectoryFiles() async {
    if (MediaStore.appFolder.isEmpty) {
      return [];
    }

    final directory = Directory(
      DirType.download.fullPath(
        relativePath: MediaStore.appFolder,
        dirName: DirName.download,
      ),
    );

    if (!directory.existsSync()) {
      return [];
    }

    final entries = <ScanFileEntry>[];

    for (final file in directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.csv'))) {
      final stat = await file.stat();
      entries.add(
        ScanFileEntry(
          path: file.path,
          fileName: _fileNameFromPath(file.path),
          modifiedAt: stat.modified,
          sizeInBytes: stat.size,
          rowCount: _countCsvRows(file),
        ),
      );
    }

    return entries;
  }

  static String _fileNameFromPath(String path) {
    final separatorIndex = path.lastIndexOf(Platform.pathSeparator);
    if (separatorIndex == -1) {
      return path;
    }

    return path.substring(separatorIndex + 1);
  }

  static int _countCsvRows(File file) {
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
