import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLogger {
  static void info(String message, {String? tag}) {
    _log('INFO', message, tag);
  }

  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _log('DEBUG', message, tag);
    }
  }

  static void warning(String message, {String? tag}) {
    _log('WARNING', message, tag);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    final fullMessage = error != null ? '$message | Error: $error' : message;
    _log('ERROR', fullMessage, tag);
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }
  }

  static void _log(String level, String message, String? tag) {
    final prefix = tag != null ? '[$level][$tag]' : '[$level]';
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    debugPrint('$timestamp $prefix: $message');
  }
}
