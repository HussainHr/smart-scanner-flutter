import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/save/data/datasources/inspection_export_datasource.dart';
import 'package:smart_scanner/features/save/data/repositories/inspection_export_repository_impl.dart';
import 'package:smart_scanner/features/save/domain/repositories/inspection_export_repository.dart';

final inspectionExportRepositoryProvider =
    Provider<InspectionExportRepository>((ref) {
  return InspectionExportRepositoryImpl(InspectionExportDatasource());
});

class SaveProcessingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSaving(bool isSaving) {
    state = isSaving;
  }
}

final saveProcessingProvider = NotifierProvider<SaveProcessingNotifier, bool>(
  SaveProcessingNotifier.new,
);
