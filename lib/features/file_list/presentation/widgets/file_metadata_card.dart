import 'package:flutter/material.dart';
import 'package:smart_scanner/core/utils/app_date_formatter.dart';
import 'package:smart_scanner/features/file_list/domain/entities/scan_file_entry.dart';
import 'package:smart_scanner/features/file_list/presentation/utils/file_display_formatter.dart';

class FileMetadataCard extends StatelessWidget {
  const FileMetadataCard({
    super.key,
    required this.entry,
  });

  final ScanFileEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.rowCount} items • ${FileDisplayFormatter.formatFileSize(entry.sizeInBytes)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              AppDateFormatter.fileDetail.format(entry.modifiedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
