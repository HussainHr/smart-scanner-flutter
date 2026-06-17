import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

abstract final class GmailShareHelper {
  static const _channel = MethodChannel('com.example.smart_scanner/gmail');

  static Future<void> shareFile({
    required String filePath,
    required String mimeType,
    required String subject,
    required String body,
    required String fileName,
  }) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _channel.invokeMethod<void>(
          'shareFile',
          {
            'path': filePath,
            'mimeType': mimeType,
            'subject': subject,
            'body': body,
          },
        );
        return;
      } on PlatformException {
        // Gmail may be unavailable; fall back to the system share sheet.
      }
    }

    await Share.shareXFiles(
      [
        XFile(
          filePath,
          mimeType: mimeType,
          name: fileName,
        ),
      ],
      subject: subject,
      text: body,
    );
  }
}
