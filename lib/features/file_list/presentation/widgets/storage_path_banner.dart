import 'package:flutter/material.dart';
import 'package:smart_scanner/core/widgets/app_info_banner.dart';

class StoragePathBanner extends StatelessWidget {
  const StoragePathBanner({
    super.key,
    required this.storagePath,
  });

  final String storagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: AppInfoBanner(
        icon: Icons.folder_outlined,
        message: 'Files are saved in $storagePath',
      ),
    );
  }
}
