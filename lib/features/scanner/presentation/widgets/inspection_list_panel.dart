import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/core/widgets/app_loading_indicator.dart';
import 'package:smart_scanner/core/widgets/labeled_field.dart';
import 'package:smart_scanner/core/widgets/quantity_text_field.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_data_table.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_empty_state.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_code_input.dart';

class InspectionListPanel extends ConsumerWidget {
  const InspectionListPanel({
    super.key,
    required this.items,
    this.onSave,
    this.isSaveEnabled = false,
    this.isSaving = false,
  });

  final List<ScanItem> items;
  final VoidCallback? onSave;
  final bool isSaveEnabled;
  final bool isSaving;

  ScanItem? _findActiveItem(List<ScanItem> items, String? lastScannedCode) {
    if (lastScannedCode == null || lastScannedCode.isEmpty) {
      return null;
    }

    for (final item in items) {
      if (item.value == lastScannedCode) {
        return item;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final quantity = ref.watch(scanQuantityProvider);
    final lastScannedCode = ref.watch(lastScannedCodeProvider);
    final activeItem = _findActiveItem(items, lastScannedCode);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.grid_view_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Inspection List',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: isSaveEnabled && !isSaving ? onSave : null,
                  icon: isSaving
                      ? const AppLoadingIndicator(size: 16)
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(isSaving ? 'Saving...' : 'Save'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: LabeledField(
                    label: 'Code',
                    child: ScanCodeInput(
                      code: lastScannedCode ?? '',
                      enabled: activeItem != null,
                      onChanged: (code) {
                        if (activeItem == null) {
                          return;
                        }

                        ref.read(inspectionListProvider.notifier).updateCode(activeItem.id, code);
                        ref.read(lastScannedCodeProvider.notifier).setCode(code);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: LabeledField(
                    label: 'Quantity',
                    child: QuantityTextField(
                      quantity: activeItem?.quantity ?? quantity,
                      onChanged: (value) {
                        ref.read(scanQuantityProvider.notifier).setQuantity(value);
                        if (activeItem != null) {
                          ref.read(inspectionListProvider.notifier).updateQuantity(activeItem.id, value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const InspectionEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
      ),
    );
  }
}
