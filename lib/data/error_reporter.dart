import 'package:flutter/foundation.dart';

class ErrorReporter {
  static report(dynamic exception, dynamic reason) {
    if (!kReleaseMode) {
      print(
          '<ErrorReporter> $exception, reason: $reason\n${StackTrace.current}');
    }
  }
}
