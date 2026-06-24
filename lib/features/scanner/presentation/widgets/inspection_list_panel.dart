import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_data_table.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_empty_state.dart';

class InspectionListPanel extends ConsumerWidget {
  const InspectionListPanel({
    super.key,
    required this.items,
  });

  final List<ScanItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastScannedCode = ref.watch(lastScannedCodeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: AppTheme.fileListAppBar,
              ),
              const SizedBox(width: 8),
              const Text(
                'Inspection List',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const InspectionEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: InspectionDataTable(
                    rows: [
                      for (final item in items)
                        InspectionTableRow(
                          id: item.id,
                          code: item.value,
                          quantity: item.quantity,
                        ),
                    ],
                    showResetColumn: true,
                    scannerStyle: true,
                    onReset: (id) =>
                        ref.read(inspectionListProvider.notifier).removeScan(id),
                    onQuantityChanged: (id, nextQuantity) {
                      ref
                          .read(inspectionListProvider.notifier)
                          .updateQuantity(id, nextQuantity);

                      final item = items.firstWhere((entry) => entry.id == id);
                      if (item.value == lastScannedCode) {
                        ref
                            .read(scanQuantityProvider.notifier)
                            .setQuantity(nextQuantity);
                      }
                    },
                    onRowSelected: (code) {
                      ref.read(lastScannedCodeProvider.notifier).setCode(code);
                      final item =
                          items.firstWhere((entry) => entry.value == code);
                      ref
                          .read(scanQuantityProvider.notifier)
                          .setQuantity(item.quantity);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
