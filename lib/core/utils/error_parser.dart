import 'dart:convert';
import 'package:dio/dio.dart';
import 'app_logger.dart';

class ErrorParser {
  /// Mendeteksi apakah pesan merupakan error sistem/backend mentah (seperti database crash, SQL state, dll.)
  static bool isSystemError(String? text) {
    if (text == null) return false;
    final lower = text.toLowerCase();
    return lower.contains('sqlstate') ||
        lower.contains('queryexception') ||
        lower.contains('exception') ||
        lower.contains('database') ||
        lower.contains('syntax error') ||
        lower.contains('nullpointer') ||
        lower.contains('laravel') ||
        lower.contains('php') ||
        lower.contains('server error') ||
        lower.contains('internal server');
  }

  /// Mengambil pesan error dari [DioException] secara aman terlepas dari format respons.
  static String parse(DioException e, String defaultMsg) {
    try {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return defaultMsg;
      }

      final data = e.response?.data;
      if (data != null) {
        if (data is Map) {
          final status = data['status']?.toString();
          final message = data['message']?.toString();
          if (status == 'error' || isSystemError(message)) {
            return defaultMsg;
          }
          return message ?? defaultMsg;
        } else if (data is String) {
          try {
            final decoded = jsonDecode(data);
            if (decoded is Map) {
              final status = decoded['status']?.toString();
              final message = decoded['message']?.toString();
              if (status == 'error' || isSystemError(message)) {
                return defaultMsg;
              }
              return message ?? defaultMsg;
            }
          } catch (error, stackTrace) {
            AppLogger.debug(
              'Gagal decode body error JSON, fallback ke message default',
              tag: 'ErrorParser',
            );
            AppLogger.error(
              'Body error JSON tidak valid',
              error: error,
              stackTrace: stackTrace,
              tag: 'ErrorParser',
            );
          }
          // Hindari melempar string HTML raksasa jika itu halaman stack trace 500
          if (data.trim().startsWith('<!DOCTYPE') || data.trim().startsWith('<html')) {
            return defaultMsg;
          }
          if (isSystemError(data)) {
            return defaultMsg;
          }
          return data.length > 100 ? data.substring(0, 100) : data;
        }
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'ErrorParser gagal mengekstrak pesan error',
        error: error,
        stackTrace: stackTrace,
        tag: 'ErrorParser',
      );
    }
    return e.message ?? defaultMsg;
  }
}
