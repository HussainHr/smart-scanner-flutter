import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/data/widgets/barcode_camera_preview.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';

class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasource = ref.watch(barcodeScannerDatasourceProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BarcodeCameraPreview(datasource: datasource),
    );
  }
}
