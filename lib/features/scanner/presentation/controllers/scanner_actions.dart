import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/core/errors/app_exception.dart';
import 'package:smart_scanner/core/utils/app_snackbar.dart';
import 'package:smart_scanner/features/file_list/presentation/providers/file_list_providers.dart';
import 'package:smart_scanner/features/save/presentation/providers/save_providers.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';

abstract final class ScannerActions {
  static Future<void> scan(
    BuildContext context,
    WidgetRef ref,
    ScanMode scanMode,
  ) async {
    if (scanMode == ScanMode.barcodeQr) {
      _scanBarcode(context, ref);
      return;
    }

    await _scanOcr(context, ref);
  }

  static void _scanBarcode(BuildContext context, WidgetRef ref) {
    final repository = ref.read(scannerRepositoryProvider);
    final detection = repository.peekPendingDetection();

    if (detection == null) {
      AppSnackbar.show(
        context,
        'No code detected. Align the barcode or QR within the frame.',
      );
      return;
    }

    repository.consumePendingDetection();

    _addToInspectionList(
      context,
      ref,
      value: detection.value,
      type: detection.type,
    );
  }

  static Future<void> _scanOcr(BuildContext context, WidgetRef ref) async {
    final processingNotifier = ref.read(scanProcessingProvider.notifier);
    processingNotifier.setProcessing(true);

    try {
      final recognizedText = await ref
          .read(scannerRepositoryProvider)
          .recognizeTextFromFrame();

      if (!context.mounted) {
        return;
      }

      _addToInspectionList(
        context,
        ref,
        value: recognizedText,
        type: ScanType.ocr,
      );
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(context, error.message);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(
        context,
        'Text recognition failed. Please try again.',
      );
    } finally {
      processingNotifier.setProcessing(false);
    }
  }

  static void _addToInspectionList(
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

    ref.read(lastScannedCodeProvider.notifier).setCode(value);
    ref.read(pendingBarcodeProvider.notifier).clear();
    ref.read(scanQuantityProvider.notifier).reset();

    if (result == AddScanResult.added) {
      AppSnackbar.show(context, 'Added to inspection list.');
      return;
    }

    AppSnackbar.show(context, 'Quantity updated for ${value.trim()}.');
  }

  static Future<void> saveInspectionList(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final items = ref.read(inspectionListProvider);
    if (items.isEmpty) {
      AppSnackbar.show(context, 'Inspection list is empty.');
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
      ref.read(pendingBarcodeProvider.notifier).clear();
      ref.read(scanQuantityProvider.notifier).reset();
      await ref.read(fileListProvider.notifier).refresh();

      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(
        context,
        'Saved ${savedFile.itemCount} items as ${savedFile.fileName}.',
      );
    } on AppException catch (error) {
      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(context, error.message);
    } on PlatformException catch (error) {
      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(
        context,
        error.message ?? 'Failed to save inspection list. Please try again.',
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      AppSnackbar.show(
        context,
        'Failed to save inspection list. Please try again.',
      );
    } finally {
      savingNotifier.setSaving(false);
    }
  }
}
