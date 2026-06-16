import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:smart_scanner/core/errors/app_exception.dart';
import 'package:smart_scanner/features/scanner/data/utils/text_normalizer.dart';

class OcrDatasource {
  OcrDatasource() : _textRecognizer = TextRecognizer();

  final TextRecognizer _textRecognizer;

  Future<String> recognizeFromFile(String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      throw const AppException('Captured image is not available.');
    }

    final inputImage = InputImage.fromFilePath(filePath);

    final recognizedText = await _textRecognizer
        .processImage(inputImage)
        .timeout(const Duration(seconds: 15));

    final normalized = normalizeRecognizedText(recognizedText.text);

    if (normalized.isEmpty) {
      throw const AppException('No readable text found in the image.');
    }

    return normalized;
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
