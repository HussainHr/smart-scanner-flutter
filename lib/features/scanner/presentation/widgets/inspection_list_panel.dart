import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_data_table.dart';

class InspectionListPanel extends ConsumerWidget {
  const InspectionListPanel({
    super.key,
    required this.items,
    required this.scanMode,
    this.onSave,
    this.isSaveEnabled = false,
    this.isSaving = false,
  });

  final List<ScanItem> items;
  final ScanMode scanMode;
  final VoidCallback? onSave;
  final bool isSaveEnabled;
  final bool isSaving;

  ScanItem? _activeItem(List<ScanItem> items, String? lastScannedCode) {
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
    final activeItem = _activeItem(items, lastScannedCode);

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
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
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
                  child: _LabeledField(
                    label: 'Code',
                    child: _ScanCodeInput(
                      code: lastScannedCode ?? '',
                      enabled: activeItem != null,
                      onChanged: (code) {
                        if (activeItem == null) {
                          return;
                        }

                        ref
                            .read(inspectionListProvider.notifier)
                            .updateCode(activeItem.id, code);
                        ref.read(lastScannedCodeProvider.notifier).setCode(code);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _LabeledField(
                    label: 'Quantity',
                    child: _ScanQuantityInput(
                      quantity: activeItem?.quantity ?? quantity,
                      onChanged: (value) {
                        ref.read(scanQuantityProvider.notifier).setQuantity(value);
                        if (activeItem != null) {
                          ref
                              .read(inspectionListProvider.notifier)
                              .updateQuantity(activeItem.id, value);
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
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 36,
                              color: colorScheme.primary.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No scans yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Scan a barcode or QR code to start building your inspection list.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
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
                      onReset: (id) => ref.read(inspectionListProvider.notifier).removeScan(id),
                      onQuantityChanged: (id, nextQuantity) {
                        ref.read(inspectionListProvider.notifier).updateQuantity(id, nextQuantity);

                        final item = items.firstWhere((entry) => entry.id == id);
                        if (item.value == lastScannedCode) {
                          ref.read(scanQuantityProvider.notifier).setQuantity(nextQuantity);
                        }
                      },
                      onRowSelected: (code) {
                        ref.read(lastScannedCodeProvider.notifier).setCode(code);
                        final item = items.firstWhere((entry) => entry.value == code);
                        ref.read(scanQuantityProvider.notifier).setQuantity(item.quantity);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScanCodeInput extends StatefulWidget {
  const _ScanCodeInput({
    required this.code,
    required this.enabled,
    required this.onChanged,
  });

  final String code;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<_ScanCodeInput> createState() => _ScanCodeInputState();
}

class _ScanCodeInputState extends State<_ScanCodeInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.code);
  }

  @override
  void didUpdateWidget(covariant _ScanCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code && _controller.text != widget.code) {
      _controller.text = widget.code;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!widget.enabled) {
      return Text(
        widget.code,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.code.isEmpty
                  ? colorScheme.onSurface.withValues(alpha: 0.35)
                  : null,
            ),
      );
    }

    return TextField(
      controller: _controller,
      maxLines: 1,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      onChanged: widget.onChanged,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }
}

class _ScanQuantityInput extends StatefulWidget {
  const _ScanQuantityInput({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  State<_ScanQuantityInput> createState() => _ScanQuantityInputState();
}

class _ScanQuantityInputState extends State<_ScanQuantityInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
  }

  @override
  void didUpdateWidget(covariant _ScanQuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity &&
        _controller.text != '${widget.quantity}') {
      _controller.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLines: 1,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      ),
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) {
          widget.onChanged(parsed);
        }
      },
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
