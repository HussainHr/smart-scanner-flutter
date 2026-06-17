import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/features/home/presentation/widgets/home_header.dart';
import 'package:smart_scanner/features/home/presentation/widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 36),
              Text(
                'Main Menu',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              MenuCard(
                title: 'Scanner',
                subtitle: 'Scan barcodes, QR codes, and text with OCR',
                icon: Icons.document_scanner_outlined,
                accentColor: colorScheme.primary,
                onTap: () => context.push(AppConstants.routeScanner),
              ),
              const SizedBox(height: 12),
              MenuCard(
                title: 'Saved File List',
                subtitle: 'View, share, and manage exported spreadsheets',
                icon: Icons.folder_open_rounded,
                accentColor: colorScheme.secondary,
                onTap: () => context.push(AppConstants.routeFileList),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Select an option to get started',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
