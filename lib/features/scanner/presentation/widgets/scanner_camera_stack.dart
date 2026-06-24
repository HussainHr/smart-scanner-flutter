import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_frame_layout.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';

class ScannerCameraStack extends ConsumerStatefulWidget {
  const ScannerCameraStack({
    super.key,
    required this.cameraPreview,
    required this.scanMode,
    required this.isProcessing,
    required this.isSaving,
  });

  final Widget cameraPreview;
  final ScanMode scanMode;
  final bool isProcessing;
  final bool isSaving;

  @override
  ConsumerState<ScannerCameraStack> createState() => _ScannerCameraStackState();
}

class _ScannerCameraStackState extends ConsumerState<ScannerCameraStack> {
  bool _torchOn = false;

  Future<void> _toggleTorch() async {
    final controller = ref.read(barcodeScannerDatasourceProvider).controller;
    await controller.toggleTorch();
    if (mounted) {
      setState(() => _torchOn = !_torchOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBarcodeMode = widget.scanMode == ScanMode.barcodeQr;
    final isBusy = widget.isProcessing || widget.isSaving;
    final frameSize = ScanFrameLayout.barcodeFrame;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.cameraPreview,
          // if (isBarcodeMode)
          //   Center(
          //     child: Container(
          //       width: frameSize.width,
          //       height: frameSize.height,
          //       decoration: BoxDecoration(
          //         border: Border.all(
          //           color: Colors.white.withValues(alpha: 0.85),
          //           width: 2,
          //         ),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),
          //   ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                tooltip: _torchOn ? 'Flash off' : 'Flash on',
                onPressed: isBusy ? null : _toggleTorch,
                icon: Icon(
                  _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          if (widget.isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
