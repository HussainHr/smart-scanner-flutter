import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/app.dart';
import 'package:smart_scanner/core/storage/media_store_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaStoreBootstrap.initialize();
  runApp(
    const ProviderScope(
      child: SmartScannerApp(),
    ),
  );
}
