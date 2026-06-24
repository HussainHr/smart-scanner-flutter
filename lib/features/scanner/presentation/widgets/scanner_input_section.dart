import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/core/widgets/app_loading_indicator.dart';
import 'package:smart_scanner/core/widgets/quantity_text_field.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_code_input.dart';

class ScannerInputSection extends ConsumerWidget {
  const ScannerInputSection({
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
    final quantity = ref.watch(scanQuantityProvider);
    final lastScannedCode = ref.watch(lastScannedCodeProvider);
    final activeItem = _findActiveItem(items, lastScannedCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _InlineLabel(text: 'Code'),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _InputBox(
                child: ScanCodeInput(
                  code: lastScannedCode ?? '',
                  enabled: activeItem != null,
                  darkStyle: true,
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
            const SizedBox(width: 8),
            _InlineLabel(text: 'Quantity'),
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              child: _InputBox(
                child: QuantityTextField(
                  quantity: activeItem?.quantity ?? quantity,
                  darkStyle: true,
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
        const SizedBox(height: 10),
        FilledButton(
          onPressed: isSaveEnabled && !isSaving ? onSave : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.scannerMint,
            foregroundColor: AppTheme.scannerMintOn,
            disabledBackgroundColor: AppTheme.scannerMint.withValues(alpha: 0.35),
            disabledForegroundColor: AppTheme.scannerMintOn.withValues(alpha: 0.5),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          child: isSaving
              ? const AppLoadingIndicator(
                  size: 20,
                  color: AppTheme.scannerMintOn,
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _InlineLabel extends StatelessWidget {
  const _InlineLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.scannerMint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.scannerMintOn,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.scannerInputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.scannerInputBorder),
      ),
      child: child,
    );
  }
}
