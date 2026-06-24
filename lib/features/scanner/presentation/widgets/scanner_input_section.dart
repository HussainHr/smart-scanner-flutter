import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/core/widgets/quantity_text_field.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_code_input.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scanner_action_button.dart';

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

  bool get _hasListData => items.isNotEmpty;

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

    final codeInput = ScanCodeInput(
      code: lastScannedCode ?? '',
      enabled: activeItem != null,
      darkStyle: true,
      onChanged: (code) {
        if (activeItem == null) {
          return;
        }

        ref.read(inspectionListProvider.notifier).updateCode(activeItem.id, code);
        ref.read(lastScannedCodeProvider.notifier).setCode(code);
      },
    );

    final quantityInput = QuantityTextField(
      quantity: activeItem?.quantity ?? quantity,
      darkStyle: true,
      textAlign: TextAlign.center,
      onChanged: (value) {
        ref.read(scanQuantityProvider.notifier).setQuantity(value);
        if (activeItem != null) {
          ref
              .read(inspectionListProvider.notifier)
              .updateQuantity(activeItem.id, value);
        }
      },
    );

    if (!_hasListData) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _StackedField(label: 'Code', child: codeInput),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _StackedField(label: 'Quantity', child: quantityInput),
          ),
        ],
      );
    }

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
              child: _InputBox(child: codeInput),
            ),
            const SizedBox(width: 8),
            _InlineLabel(text: 'Quantity'),
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              child: _InputBox(child: quantityInput),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ScannerActionButton(
          label: 'Save',
          onPressed: isSaveEnabled && !isSaving ? onSave : null,
          isLoading: isSaving,
        ),
      ],
    );
  }
}

class _StackedField extends StatelessWidget {
  const _StackedField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: const BoxDecoration(
            color: AppTheme.scannerMint,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.scannerMintOn,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.scannerInputBg,
            border: Border.all(
              color: AppTheme.scannerMint.withValues(alpha: 0.55),
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: child,
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
