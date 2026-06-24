import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/features/scanner/presentation/controllers/scanner_actions.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/camera_preview_widget.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_list_panel.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_mode_selector.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scanner_action_button.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scanner_camera_stack.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scanner_stopped_banner.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scanner_input_section.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scanner_scanned_result_field.dart';
import 'package:smart_scanner/features/save/presentation/providers/save_providers.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(scannerRepositoryProvider);

    final inspectionList = ref.watch(inspectionListProvider);
    final scanMode = ref.watch(scanModeProvider);
    final lastScannedCode = ref.watch(lastScannedCodeProvider);
    final pendingBarcode = ref.watch(pendingBarcodeProvider);
    final displayCode = lastScannedCode ?? pendingBarcode ?? '';
    final isProcessing = ref.watch(scanProcessingProvider);
    final isSaving = ref.watch(saveProcessingProvider);
    final canSave = inspectionList.isNotEmpty && !isProcessing && !isSaving;
    final isBusy = isProcessing || isSaving;

    return Scaffold(
      backgroundColor: AppTheme.scannerBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scannerAppBar,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ScannerCameraStack(
                      cameraPreview: const CameraPreviewWidget(),
                      scanMode: scanMode,
                      isProcessing: isProcessing,
                      isSaving: isSaving,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (inspectionList.isEmpty) ...[
                    const ScannerStoppedBanner(),
                    const SizedBox(height: 10),
                  ],
                  ScannerScannedResultField(code: displayCode),
                  const SizedBox(height: 10),
                  ScanModeSelector(isEnabled: !isBusy),
                  const SizedBox(height: 10),
                  ScannerActionButton(
                    label: 'Scan',
                    onPressed: isBusy
                        ? null
                        : () =>
                        ScannerActions.scan(context, ref, scanMode),
                    isLoading: isProcessing,
                  ),
                  const SizedBox(height: 10),
                  ScannerInputSection(
                    items: inspectionList,
                    onSave: () => ScannerActions.saveInspectionList(
                      context,
                      ref,
                    ),
                    isSaveEnabled: canSave,
                    isSaving: isSaving,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: InspectionListPanel(items: inspectionList),
          ),
        ],
      ),
    );
  }
}
