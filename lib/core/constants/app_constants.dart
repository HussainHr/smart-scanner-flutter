class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Scanner';

  static const String routeHome = '/';
  static const String routeScanner = '/scanner';
  static const String routeFileList = '/file-list';
  static const String routeFileView = '/file-list/view';

  static const String scansDirectoryName = 'Smart Scanner';

  static String get publicScansPathLabel => 'Download/$scansDirectoryName';
}
