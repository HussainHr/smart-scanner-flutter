import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/core/router/app_router.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';

class SmartScannerApp extends ConsumerWidget {
  const SmartScannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
