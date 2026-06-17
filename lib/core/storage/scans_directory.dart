import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';

abstract final class ScansDirectory {
  static Future<Directory> resolve() async {
    final appDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory(
      '${appDir.path}/${AppConstants.scansDirectoryName}',
    );

    if (!scansDir.existsSync()) {
      await scansDir.create(recursive: true);
    }

    return scansDir;
  }
}
