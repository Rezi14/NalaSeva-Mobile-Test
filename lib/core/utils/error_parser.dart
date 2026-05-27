import 'dart:convert';
import 'package:dio/dio.dart';
import 'app_logger.dart';

class ErrorParser {
  /// Mengambil pesan error dari [DioException] secara aman terlepas dari format respons.
  static String parse(DioException e, String defaultMsg) {
    try {
      final data = e.response?.data;
      if (data != null) {
        if (data is Map) {
          return data['message']?.toString() ?? defaultMsg;
        } else if (data is String) {
          try {
            final decoded = jsonDecode(data);
            if (decoded is Map) {
              return decoded['message']?.toString() ?? defaultMsg;
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
