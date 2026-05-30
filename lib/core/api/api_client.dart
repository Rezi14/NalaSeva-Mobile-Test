import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../router/app_router.dart';

class ApiClient {
  late Dio dio;
  static const String baseUrl = 'https://nalaseva-api.up.railway.app/api/';
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) {
        if (status == null) return false;
        return status < 500 && status != 401; // Throw exception if status is 401 to handle it in onError
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Jangan tambahkan token jika sedang login
        if (options.path.contains('login')) {
          return handler.next(options);
        }

        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          // Hapus token akses sesi yang kedaluwarsa beserta data id terkait
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'user_role');
          await _storage.delete(key: 'patient_id');
          await _storage.delete(key: 'doctor_id');
          // Global contextless redirect to login screen
          AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
        }
        return handler.next(e);
      },
    ));
  }
}
