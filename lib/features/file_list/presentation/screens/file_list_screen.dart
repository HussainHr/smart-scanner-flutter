import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/core/storage/media_store_storage.dart';
import 'package:smart_scanner/features/file_list/presentation/providers/file_list_providers.dart';
import 'package:smart_scanner/features/file_list/presentation/widgets/scan_file_list_tile.dart';

class FileListScreen extends ConsumerStatefulWidget {
  const FileListScreen({super.key});

  @override
  ConsumerState<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends ConsumerState<FileListScreen> {
  String? _storagePath;

  @override
  void initState() {
    super.initState();
    _storagePath = MediaStoreStorage.displayPathLabel();
    _loadStoragePath();
  }

  Future<void> _loadStoragePath() async {
    try {
      final storagePath = await MediaStoreStorage.displayPath();
      if (!mounted) {
        return;
      }

      setState(() {
        _storagePath = storagePath;
      });
    } catch (_) {
      // Storage path is informational only.
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileListAsync = ref.watch(fileListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
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
          if (_storagePath != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Files are saved in $_storagePath',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: fileListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _FileListMessage(
                icon: Icons.error_outline_rounded,
                title: 'Could not load saved files',
                message: error.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.read(fileListProvider.notifier).refresh(),
              ),
              data: (files) {
                if (files.isEmpty) {
                  return _FileListMessage(
                    icon: Icons.folder_open_rounded,
                    title: 'No saved files yet',
                    message:
                        'Export scans from the Scanner screen. CSV files will appear here and in ${AppConstants.publicScansPathLabel}.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(fileListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: files.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = files[index];
                      return ScanFileListTile(
                        entry: entry,
                        onTap: () => context.push(
                          AppConstants.routeFileView,
                          extra: entry,
                        ),
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
}

class _FileListMessage extends StatelessWidget {
  const _FileListMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
