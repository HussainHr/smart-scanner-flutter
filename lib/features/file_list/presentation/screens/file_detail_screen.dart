import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/core/utils/app_snackbar.dart';
import 'package:smart_scanner/core/widgets/app_empty_state.dart';
import 'package:smart_scanner/core/widgets/app_loading_indicator.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/presentation/providers/file_list_providers.dart';
import 'package:smart_scanner/features/file_list/presentation/widgets/file_metadata_card.dart';
import 'package:smart_scanner/features/file_list/presentation/widgets/spreadsheet_preview_table.dart';

class FileDetailScreen extends ConsumerWidget {
  const FileDetailScreen({
    super.key,
    required this.entry,
  });

  final ScanFileEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewRowsAsync = ref.watch(filePreviewRowsProvider(entry));
    final isSharing = ref.watch(fileShareProvider);

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
        title: const Text('View Details'),
        actions: [
          IconButton(
            tooltip: 'Share file',
            onPressed: isSharing ? null : () => _shareFile(context, ref),
            icon: isSharing
                ? AppLoadingIndicator(color: Colors.white)
                : const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FileMetadataCard(entry: entry),
          Expanded(
            child: previewRowsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not open file',
                message: error.toString(),
              ),
              data: (rows) => SpreadsheetPreviewTable(rows: rows),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareFile(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(fileShareProvider.notifier).share(entry);
      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(context, 'Share sheet opened.');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(context, 'Failed to share file: $error');
    }
  }
}
