import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/features/scanner/presentation/controllers/scanner_actions.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/camera_preview_widget.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_list_panel.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_mode_selector.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scanner_camera_stack.dart';
import 'package:smart_scanner/features/save/presentation/providers/save_providers.dart';

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
    final canSave = inspectionList.isNotEmpty && !isProcessing && !isSaving;
    final isBusy = isProcessing || isSaving;

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
          const SizedBox(height: 5),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ScannerCameraStack(
                cameraPreview: const CameraPreviewWidget(),
                modeSelector: ScanModeSelector(isEnabled: !isBusy),
                scanMode: scanMode,
                isProcessing: isProcessing,
                isSaving: isSaving,
                onScanPressed: () => ScannerActions.scan(context, ref, scanMode),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: InspectionListPanel(
              items: inspectionList,
              onSave: () => ScannerActions.saveInspectionList(context, ref),
              isSaveEnabled: canSave,
              isSaving: isSaving,
            ),
          ),
        ],
      ),
    );
  }
}
