import 'package:flutter/material.dart';

class ScannerStoppedBanner extends StatelessWidget {
  const ScannerStoppedBanner({super.key});

  static const Color _background = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Scanning stopped.',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
