import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/core/errors/app_exception.dart';
import 'package:smart_scanner/features/save/presentation/providers/save_providers.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/camera_preview_widget.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_list_panel.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_mode_chip.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(scannerRepositoryProvider);

    final inspectionList = ref.watch(inspectionListProvider);
    final scanMode = ref.watch(scanModeProvider);
    final isProcessing = ref.watch(scanProcessingProvider);
    final isSaving = ref.watch(saveProcessingProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isOcrMode = scanMode == ScanMode.ocr;
    final canSave = inspectionList.isNotEmpty && !isProcessing && !isSaving;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CameraPreviewWidget(),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        ScanModeChip(
                          mode: ScanMode.barcodeQr,
                          isSelected: scanMode == ScanMode.barcodeQr,
                          isEnabled: !isProcessing && !isSaving,
                          onTap: () => ref
                              .read(scanModeProvider.notifier)
                              .setMode(ScanMode.barcodeQr),
                        ),
                        const SizedBox(width: 8),
                        ScanModeChip(
                          mode: ScanMode.ocr,
                          isSelected: scanMode == ScanMode.ocr,
                          isEnabled: !isProcessing && !isSaving,
                          onTap: () => ref
                              .read(scanModeProvider.notifier)
                              .setMode(ScanMode.ocr),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 220,
                      height: isOcrMode ? 180 : 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  if (isOcrMode)
                    Positioned(
                      top: 56,
                      left: 24,
                      right: 24,
                      child: Text(
                        'Align text inside the frame only.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 14,
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: isProcessing || isSaving
                            ? null
                            : () => _handleScan(context, ref, scanMode),
                        icon: Icon(
                          isOcrMode
                              ? Icons.document_scanner_outlined
                              : Icons.qr_code_scanner_rounded,
                        ),
                        label: Text(isOcrMode ? 'Scan Text' : 'Scan'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: InspectionListPanel(
              items: inspectionList,
              scanMode: scanMode,
              onSave: () => _handleSave(context, ref),
              isSaveEnabled: canSave,
              isSaving: isSaving,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan(
    BuildContext context,
    WidgetRef ref,
    ScanMode scanMode,
  ) async {
    if (scanMode == ScanMode.barcodeQr) {
      _handleBarcodeScan(context, ref);
      return;
    }

    await _handleOcrScan(context, ref);
  }

  void _handleBarcodeScan(BuildContext context, WidgetRef ref) {
    final detection =
        ref.read(scannerRepositoryProvider).peekPendingDetection();

    if (detection == null) {
      _showMessage(
        context,
        'No code detected. Align the barcode or QR within the frame.',
      );
      return;
    }

    _addScanToList(
      context,
      ref,
      value: detection.value,
      type: detection.type,
    );
  }

  Future<void> _handleOcrScan(BuildContext context, WidgetRef ref) async {
    final processingNotifier = ref.read(scanProcessingProvider.notifier);
    processingNotifier.setProcessing(true);

    try {
      final recognizedText = await ref
          .read(scannerRepositoryProvider)
          .recognizeTextFromFrame();

      if (!context.mounted) {
        return;
      }

      _addScanToList(
        context,
        ref,
        value: recognizedText,
        type: ScanType.ocr,
      );
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, error.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Text recognition failed. Please try again.',
      );
    } finally {
      processingNotifier.setProcessing(false);
    }
  }

  void _addScanToList(
    BuildContext context,
    WidgetRef ref, {
    required String value,
    required ScanType type,
  }) {
    final quantity = ref.read(scanQuantityProvider);
    final item = ScanItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      value: value,
      type: type,
      scannedAt: DateTime.now(),
      quantity: quantity,
    );

    final result = ref.read(inspectionListProvider.notifier).addScan(item);

    if (result == AddScanResult.duplicate) {
      _showMessage(
        context,
        'Duplicate scan: this code is already in the inspection list.',
        isWarning: true,
      );
      return;
    }

    ref.read(lastScannedCodeProvider.notifier).setCode(value);
    ref.read(scanQuantityProvider.notifier).reset();
    _showMessage(context, 'Added to inspection list.');
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final items = ref.read(inspectionListProvider);
    if (items.isEmpty) {
      _showMessage(context, 'Inspection list is empty.');
      return;
    }

    final savingNotifier = ref.read(saveProcessingProvider.notifier);
    savingNotifier.setSaving(true);

    try {
      final savedFile = await ref
          .read(inspectionExportRepositoryProvider)
          .exportInspectionList(items);

      ref.read(inspectionListProvider.notifier).clear();
      ref.read(lastScannedCodeProvider.notifier).clear();
      ref.read(scanQuantityProvider.notifier).reset();

      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Saved ${savedFile.itemCount} items to ${AppConstants.publicScansPathLabel}/${savedFile.fileName}.',
      );
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, error.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Failed to save inspection list. Please try again.',
      );
    } finally {
      savingNotifier.setSaving(false);
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isWarning = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isWarning ? const Color(0xFFB45309) : null,
        ),
      );
  }
}
