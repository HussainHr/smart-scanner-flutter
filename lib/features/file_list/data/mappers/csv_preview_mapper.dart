import 'package:csv/csv.dart';

abstract final class CsvPreviewMapper {
  static List<List<String>> parseRows(String content) {
    if (content.trim().isEmpty) {
      return [];
    }

    final normalized = content.replaceAll('\r\n', '\n');
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(normalized);

    return rows
        .map((row) => row.map((cell) => cell.toString()).toList())
        .toList();
  }
}
