import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/file_list/data/datasources/scan_file_local_datasource.dart';
import 'package:smart_scanner/features/file_list/data/repositories/scan_file_repository_impl.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/domain/repositories/scan_file_repository.dart';

final scanFileRepositoryProvider = Provider<ScanFileRepository>((ref) {
  return ScanFileRepositoryImpl(ScanFileLocalDatasource());
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
