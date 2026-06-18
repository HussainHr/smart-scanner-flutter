import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/core/errors/app_exception.dart';
import 'package:smart_scanner/core/storage/media_store_bootstrap.dart';
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

  static Future<MediaStoreSaveResult> saveSpreadsheet({
    required String fileName,
    required Uint8List fileBytes,
    required int itemCount,
  }) async {
    if (!kIsWeb && Platform.isAndroid) {
      return _saveSpreadsheetOnAndroid(
        fileName: fileName,
        fileBytes: fileBytes,
        itemCount: itemCount,
      );
    }

    return _saveSpreadsheetToAppStorage(
      fileName: fileName,
      fileBytes: fileBytes,
      itemCount: itemCount,
    );
  }

  static Future<List<ScanFileEntry>> listSavedFiles() async {
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
          .where((file) => _isSupportedExportFile(file.path))) {
        final stat = await file.stat();
        entriesByKey[file.path] = ScanFileEntry(
          path: file.path,
          fileName: _fileNameFromPath(file.path),
          modifiedAt: stat.modified,
          sizeInBytes: stat.size,
          rowCount: _countSpreadsheetRows(file),
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

  static Future<MediaStoreSaveResult> _saveSpreadsheetOnAndroid({
    required String fileName,
    required Uint8List fileBytes,
    required int itemCount,
  }) async {
    File? tempFile;

    try {
      await MediaStoreBootstrap.ensureReady();

      final tempDirectory = await getTemporaryDirectory();
      tempFile = File('${tempDirectory.path}/$fileName');
      await tempFile.writeAsBytes(fileBytes, flush: true);

      final saveInfo = await _mediaStore.saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      if (saveInfo != null) {
        final contentUri = saveInfo.uri.toString();
        final displayPath = await _resolveDisplayPath(
          contentUri: contentUri,
          fileName: saveInfo.name,
        );

        await SavedFileIndex.add(
          SavedFileIndexEntry(
            fileName: saveInfo.name,
            path: displayPath,
            contentUri: contentUri,
            savedAt: DateTime.now(),
            itemCount: itemCount,
            sizeInBytes: fileBytes.length,
          ),
        );

        return MediaStoreSaveResult(
          path: displayPath,
          fileName: saveInfo.name,
          contentUri: contentUri,
        );
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint('MediaStore save failed: ${error.message}');
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint('MediaStore save failed: $error');
      debugPrint('$stackTrace');
    } finally {
      if (tempFile != null && tempFile.existsSync()) {
        await tempFile.delete();
      }
    }

    return _saveSpreadsheetToAppStorage(
      fileName: fileName,
      fileBytes: fileBytes,
      itemCount: itemCount,
    );
  }

  static Future<String> _resolveDisplayPath({
    required String contentUri,
    required String fileName,
  }) async {
    final fallbackPath = '${AppConstants.publicScansPathLabel}/$fileName';

    try {
      return await _mediaStore.getFilePathFromUri(uriString: contentUri) ??
          fallbackPath;
    } on PlatformException catch (error) {
      debugPrint('Could not resolve MediaStore path: ${error.message}');
      return fallbackPath;
    } catch (error) {
      debugPrint('Could not resolve MediaStore path: $error');
      return fallbackPath;
    }
  }

  static Future<MediaStoreSaveResult> _saveSpreadsheetToAppStorage({
    required String fileName,
    required Uint8List fileBytes,
    required int itemCount,
  }) async {
    final scansDirectory = await ScansDirectory.resolveForAppStorage();
    final file = File('${scansDirectory.path}/$fileName');
    await file.writeAsBytes(fileBytes, flush: true);

    await SavedFileIndex.add(
      SavedFileIndexEntry(
        fileName: fileName,
        path: file.path,
        savedAt: DateTime.now(),
        itemCount: itemCount,
        sizeInBytes: fileBytes.length,
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
      if (!_isSupportedExportFile(indexEntry.fileName)) {
        continue;
      }

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
          contentUri: indexEntry.contentUri,
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
        .where((file) => _isSupportedExportFile(file.path))) {
      final stat = await file.stat();
      entries.add(
        ScanFileEntry(
          path: file.path,
          fileName: _fileNameFromPath(file.path),
          modifiedAt: stat.modified,
          sizeInBytes: stat.size,
          rowCount: _countSpreadsheetRows(file),
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

  static bool _isSupportedExportFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.csv') || lower.endsWith('.xlsx');
  }

  static int _countSpreadsheetRows(File file) {
    if (file.path.toLowerCase().endsWith('.xlsx')) {
      try {
        final bytes = file.readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables.values.firstOrNull;
        if (sheet == null || sheet.maxRows <= 1) {
          return 0;
        }

        return sheet.maxRows - 1;
      } catch (_) {
        return 0;
      }
    }

    return _countCsvRows(file);
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

  static Future<Uint8List> readFileBytes(ScanFileEntry entry) async {
    final contentUri = entry.contentUri ??
        (await SavedFileIndex.findByFileName(entry.fileName))?.contentUri;

    if (!kIsWeb && Platform.isAndroid && contentUri != null) {
      final tempDirectory = await getTemporaryDirectory();
      final tempFile = File('${tempDirectory.path}/${entry.fileName}');
      final wasRead = await _mediaStore.readFileUsingUri(
        uriString: contentUri,
        tempFilePath: tempFile.path,
      );

      if (wasRead && tempFile.existsSync()) {
        return tempFile.readAsBytes();
      }
    }

    final file = File(entry.path);
    if (file.existsSync()) {
      return file.readAsBytes();
    }

    if (!kIsWeb && Platform.isAndroid && MediaStore.appFolder.isNotEmpty) {
      final tempDirectory = await getTemporaryDirectory();
      final tempFile = File('${tempDirectory.path}/${entry.fileName}');
      final wasRead = await _mediaStore.readFile(
        fileName: entry.fileName,
        tempFilePath: tempFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      if (wasRead && tempFile.existsSync()) {
        return tempFile.readAsBytes();
      }
    }

    throw const AppException('Could not read the selected file.');
  }

  static Future<File> prepareShareableFile(ScanFileEntry entry) async {
    final bytes = await readFileBytes(entry);
    final tempDirectory = await getTemporaryDirectory();
    final shareFile = File('${tempDirectory.path}/share_${entry.fileName}');
    await shareFile.writeAsBytes(bytes, flush: true);
    return shareFile;
  }

  static Future<void> deleteSavedFile(ScanFileEntry entry) async {
    final indexEntry = await SavedFileIndex.findByFileName(entry.fileName);
    final contentUri = entry.contentUri ?? indexEntry?.contentUri;

    if (!kIsWeb && Platform.isAndroid && contentUri != null) {
      final wasDeleted = await _mediaStore.deleteFileUsingUri(
        uriString: contentUri,
      );

      if (!wasDeleted) {
        throw const AppException('Failed to delete the selected file.');
      }
    } else {
      final file = File(entry.path);
      if (file.existsSync()) {
        await file.delete();
      }
    }

    await SavedFileIndex.removeByFileName(entry.fileName);
  }
}
