import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/presentation/providers/file_list_providers.dart';
import 'package:smart_scanner/features/file_list/presentation/utils/file_display_formatter.dart';
import 'package:smart_scanner/features/file_list/presentation/widgets/csv_preview_table.dart';

class FileDetailScreen extends ConsumerWidget {
  const FileDetailScreen({
    super.key,
    required this.entry,
  });

  final ScanFileEntry entry;

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewRowsAsync = ref.watch(filePreviewRowsProvider(entry));
    final isSharing = ref.watch(fileShareProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('View Details'),
        actions: [
          IconButton(
            tooltip: 'Share CSV',
            onPressed: isSharing
                ? null
                : () => _shareFile(context, ref),
            icon: isSharing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.rowCount} items • ${FileDisplayFormatter.formatFileSize(entry.sizeInBytes)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateFormat.format(entry.modifiedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: previewRowsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _FileDetailMessage(
                icon: Icons.error_outline_rounded,
                title: 'Could not open file',
                message: error.toString(),
              ),
              data: (rows) => CsvPreviewTable(rows: rows),
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

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Share sheet opened.')),
        );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to share file: $error')),
        );
    }
  }
}

class _FileDetailMessage extends StatelessWidget {
  const _FileDetailMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: colorScheme.secondary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
