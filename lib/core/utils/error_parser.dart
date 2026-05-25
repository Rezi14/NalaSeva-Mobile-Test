import 'dart:convert';
import 'package:dio/dio.dart';

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
          } catch (_) {}
          // Hindari melempar string HTML raksasa jika itu halaman stack trace 500
          if (data.trim().startsWith('<!DOCTYPE') || data.trim().startsWith('<html')) {
            return defaultMsg;
          }
          return data.length > 100 ? data.substring(0, 100) : data;
        }
      }
    } catch (_) {}
    return e.message ?? defaultMsg;
  }
}
