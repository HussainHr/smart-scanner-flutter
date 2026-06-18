import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';

abstract final class MediaStoreBootstrap {
  static Future<void> initialize() async {
    await ensureReady();
  }

  static Future<void> ensureReady() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await MediaStore.ensureInitialized();
    MediaStore.appFolder = AppConstants.scansDirectoryName;
  }
}
