import 'package:flutter/material.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';

class InspectionEmptyState extends StatelessWidget {
  const InspectionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.scannerMint.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: AppTheme.scannerMint.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'There is no Data.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
