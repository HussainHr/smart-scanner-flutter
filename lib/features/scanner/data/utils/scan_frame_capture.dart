import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/core/errors/app_exception.dart';

abstract final class ScanFrameCapture {
  static Future<String> captureCenterFrame({
    required GlobalKey boundaryKey,
    required Size frameSize,
  }) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null) {
      throw const AppException('Camera preview is not ready.');
    }

    final previewSize = boundary.size;
    if (previewSize.isEmpty) {
      throw const AppException('Camera preview has no size yet.');
    }

    final frameRect = Rect.fromCenter(
      center: Offset(previewSize.width / 2, previewSize.height / 2),
      width: frameSize.width,
      height: frameSize.height,
    );

    final pixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final capturedImage = await boundary.toImage(pixelRatio: pixelRatio);

    final fullBytes = await capturedImage.toByteData(format: ui.ImageByteFormat.png);
    capturedImage.dispose();

    if (fullBytes == null) {
      throw const AppException('Failed to capture the scan frame.');
    }

    final decoded = img.decodeImage(fullBytes.buffer.asUint8List());
    if (decoded == null) {
      throw const AppException('Failed to process the captured frame.');
    }

    final cropLeft = (frameRect.left * pixelRatio).round().clamp(0, decoded.width - 1);
    final cropTop = (frameRect.top * pixelRatio).round().clamp(0, decoded.height - 1);
    final cropWidth = (frameSize.width * pixelRatio).round().clamp(
          1,
          decoded.width - cropLeft,
        );
    final cropHeight = (frameSize.height * pixelRatio).round().clamp(
          1,
          decoded.height - cropTop,
        );

    final cropped = img.copyCrop(
      decoded,
      x: cropLeft,
      y: cropTop,
      width: cropWidth,
      height: cropHeight,
    );

    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/scan_frame_${DateTime.now().microsecondsSinceEpoch}.jpg';

    await File(filePath).writeAsBytes(img.encodeJpg(cropped, quality: 92));

    return filePath;
  }
}
