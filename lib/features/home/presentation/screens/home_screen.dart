import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/features/home/presentation/widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuCard(
              title: 'Scanner',
              icon: Icons.document_scanner_outlined,
              onTap: () => context.push(AppConstants.routeScanner),
            ),
            const SizedBox(height: 16),
            MenuCard(
              title: 'Saved File List',
              icon: Icons.folder_outlined,
              onTap: () => context.push(AppConstants.routeFileList),
            ),
          ],
        ),
      ),
    );
  }
}
