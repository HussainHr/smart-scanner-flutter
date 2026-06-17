import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SavedFileIndexEntry {
  const SavedFileIndexEntry({
    required this.fileName,
    required this.path,
    required this.savedAt,
    required this.itemCount,
    required this.sizeInBytes,
    this.contentUri,
  });

  final String fileName;
  final String path;
  final String? contentUri;
  final DateTime savedAt;
  final int itemCount;
  final int sizeInBytes;

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'path': path,
      'contentUri': contentUri,
      'savedAt': savedAt.toIso8601String(),
      'itemCount': itemCount,
      'sizeInBytes': sizeInBytes,
    };
  }

  factory SavedFileIndexEntry.fromJson(Map<String, dynamic> json) {
    return SavedFileIndexEntry(
      fileName: json['fileName'] as String,
      path: json['path'] as String,
      contentUri: json['contentUri'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
      itemCount: json['itemCount'] as int,
      sizeInBytes: json['sizeInBytes'] as int,
    );
  }
}

abstract final class SavedFileIndex {
  static const _fileName = 'saved_scan_files.json';

  static Future<void> add(SavedFileIndexEntry entry) async {
    final entries = await readAll();
    entries.removeWhere((existing) => existing.fileName == entry.fileName);
    entries.add(entry);
    await _writeAll(entries);
  }

  static Future<SavedFileIndexEntry?> findByFileName(String fileName) async {
    for (final entry in await readAll()) {
      if (entry.fileName == fileName) {
        return entry;
      }
    }

    return null;
  }

  static Future<List<SavedFileIndexEntry>> readAll() async {
    final file = await _indexFile();

    if (!file.existsSync()) {
      return [];
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => SavedFileIndexEntry.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  static Future<void> _writeAll(List<SavedFileIndexEntry> entries) async {
    final file = await _indexFile();
    final encoded = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    await file.writeAsString(encoded);
  }

  static Future<File> _indexFile() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    return File('${appDirectory.path}/$_fileName');
  }
}
