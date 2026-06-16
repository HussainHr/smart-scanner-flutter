import 'package:smart_scanner/core/errors/app_exception.dart';

class Failure {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  factory Failure.fromException(AppException exception) {
    return Failure(
      message: exception.message,
      code: exception.code,
    );
  }
}
