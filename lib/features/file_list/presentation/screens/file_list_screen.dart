import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/core/utils/app_snackbar.dart';
import 'package:smart_scanner/core/widgets/app_empty_state.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/presentation/providers/file_list_providers.dart';
import 'package:smart_scanner/features/file_list/presentation/utils/delete_file_dialog.dart';
import 'package:smart_scanner/features/file_list/presentation/widgets/scan_file_list_tile.dart';

class FileListScreen extends ConsumerStatefulWidget {
  const FileListScreen({super.key});

  @override
  ConsumerState<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends ConsumerState<FileListScreen> {
  @override
  void initState() {
    super.initState();
    _refreshFileList();
  }

  @override
  void activate() {
    super.activate();
    _refreshFileList();
  }

  void _refreshFileList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fileListProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fileListAsync = ref.watch(fileListProvider);
    final deletingFileName = ref.watch(fileDeleteProvider);
    final sendingFileName = ref.watch(fileSendProvider);

    return Scaffold(
      backgroundColor: AppTheme.fileListBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.fileListAppBar,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Saved File List'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.read(fileListProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 22,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Inspection List',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: fileListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load saved files',
                message: error.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.read(fileListProvider.notifier).refresh(),
              ),
              data: (files) {
                if (files.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'No saved files yet',
                    message:
                        'Export scans from the Scanner screen. Spreadsheet files will appear here and in ${AppConstants.publicScansPathLabel}.',
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.fileListAppBar,
                  onRefresh: () => ref.read(fileListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: files.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = files[index];
                      return ScanFileListTile(
                        entry: entry,
                        isDeleting: deletingFileName == entry.fileName,
                        isSending: sendingFileName == entry.fileName,
                        onView: () => context.push(
                          AppConstants.routeFileView,
                          extra: entry,
                        ),
                        onDelete: () => _deleteFile(entry),
                        onSend: () => _sendFile(entry),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(ScanFileEntry entry) async {
    final shouldDelete = await showDeleteFileDialog(context, entry.fileName);
    if (!shouldDelete || !mounted) {
      return;
    }

    try {
      await ref.read(fileDeleteProvider.notifier).delete(entry);
      if (!mounted) {
        return;
      }

      AppSnackbar.show(context, 'File deleted.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.show(context, 'Failed to delete file: $error');
    }
  }

  Future<void> _sendFile(ScanFileEntry entry) async {
    try {
      await ref.read(fileSendProvider.notifier).send(entry);
      if (!mounted) {
        return;
      }

      AppSnackbar.show(context, 'Gmail opened with attachment.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.show(context, 'Failed to send file: $error');
    }
  }
}
