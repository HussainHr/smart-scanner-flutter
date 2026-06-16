import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

class ScanItem {
  const ScanItem({
    required this.id,
    required this.value,
    required this.type,
    required this.scannedAt,
  });

  final String id;
  final String value;
  final ScanType type;
  final DateTime scannedAt;

  ScanItem copyWith({
    String? id,
    String? value,
    ScanType? type,
    DateTime? scannedAt,
  }) {
    return ScanItem(
      id: id ?? this.id,
      value: value ?? this.value,
      type: type ?? this.type,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }
}
