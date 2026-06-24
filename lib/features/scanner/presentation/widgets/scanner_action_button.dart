import 'package:flutter/material.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/core/widgets/app_loading_indicator.dart';

class ScannerActionButton extends StatelessWidget {
  const ScannerActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  static const double widthFactor = 0.45;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.scannerMint,
            foregroundColor: AppTheme.scannerMintOn,
            disabledBackgroundColor:
                AppTheme.scannerMint.withValues(alpha: 0.35),
            disabledForegroundColor:
                AppTheme.scannerMintOn.withValues(alpha: 0.5),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          child: isLoading
              ? const AppLoadingIndicator(
                  size: 20,
                  color: AppTheme.scannerMintOn,
                )
              : Text(label),
        ),
      ),
    );
  }
}
