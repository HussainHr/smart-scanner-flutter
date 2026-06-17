import 'package:intl/intl.dart';

abstract final class AppDateFormatter {
  static final DateFormat fileListTile = DateFormat('yyyy/MM/dd HH:mm:ss');
  static final DateFormat fileDetail = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat exportTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss');
}
