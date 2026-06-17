import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/file_list/data/datasources/scan_file_content_datasource.dart';
import 'package:smart_scanner/features/file_list/data/datasources/scan_file_local_datasource.dart';
import 'package:smart_scanner/features/file_list/data/mappers/spreadsheet_preview_mapper.dart';
import 'package:smart_scanner/features/file_list/data/repositories/scan_file_repository_impl.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/domain/repositories/scan_file_repository.dart';

final scanFileRepositoryProvider = Provider<ScanFileRepository>((ref) {
  return ScanFileRepositoryImpl(
    ScanFileLocalDatasource(),
    ScanFileContentDatasource(),
  );
});

class FileListNotifier extends AsyncNotifier<List<ScanFileEntry>> {
  @override
  Future<List<ScanFileEntry>> build() {
    return ref.read(scanFileRepositoryProvider).listSavedFiles();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(scanFileRepositoryProvider).listSavedFiles(),
    );
  }
}

final fileListProvider =
    AsyncNotifierProvider<FileListNotifier, List<ScanFileEntry>>(
  FileListNotifier.new,
);

final filePreviewRowsProvider = FutureProvider.autoDispose
    .family<List<List<String>>, ScanFileEntry>((ref, entry) async {
  final bytes = await ref.read(scanFileRepositoryProvider).readFileBytes(entry);
  return SpreadsheetPreviewMapper.parseRows(
    entry.fileName,
    Uint8List.fromList(bytes),
  );
});

class FileShareNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> share(ScanFileEntry entry) async {
    state = true;
    try {
      await ref.read(scanFileRepositoryProvider).shareFile(entry);
    } finally {
      state = false;
    }
  }
}

final fileShareProvider = NotifierProvider<FileShareNotifier, bool>(
  FileShareNotifier.new,
);

class FileSendNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> send(ScanFileEntry entry) async {
    state = entry.fileName;
    try {
      await ref.read(scanFileRepositoryProvider).sendFileByEmail(entry);
    } finally {
      state = null;
    }
  }
}

final fileSendProvider = NotifierProvider<FileSendNotifier, String?>(
  FileSendNotifier.new,
);

class FileDeleteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> delete(ScanFileEntry entry) async {
    state = entry.fileName;
    try {
      await ref.read(scanFileRepositoryProvider).deleteFile(entry);
      await ref.read(fileListProvider.notifier).refresh();
    } finally {
      state = null;
    }
  }
}

final fileDeleteProvider = NotifierProvider<FileDeleteNotifier, String?>(
  FileDeleteNotifier.new,
);
