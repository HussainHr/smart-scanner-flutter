import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

class ScanItem {
  const ScanItem({
    required this.id,
    required this.value,
    required this.type,
    required this.scannedAt,
    this.quantity = 1,
  });

  final String id;
  final String value;
  final ScanType type;
  final DateTime scannedAt;
  final int quantity;

  ScanItem copyWith({
    String? id,
    String? value,
    ScanType? type,
    DateTime? scannedAt,
    int? quantity,
  }) {
    return ScanItem(
      id: id ?? this.id,
      value: value ?? this.value,
      type: type ?? this.type,
      scannedAt: scannedAt ?? this.scannedAt,
      quantity: quantity ?? this.quantity,
    );
  }
}
