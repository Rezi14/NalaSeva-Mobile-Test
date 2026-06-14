import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/utils/error_parser.dart';
import '../models/puskesmas_profile_model.dart';

class PuskesmasProfileRepository {
  final ApiClient _apiClient;

  PuskesmasProfileRepository(this._apiClient);

  String _errorMessage(DioException e, String defaultMsg) {
    return ErrorParser.parse(e, defaultMsg);
  }

  void _checkResponse(Response response, String defaultError) {
    final data = response.data;
    if (data is Map) {
      final isNotSuccess = data.containsKey('status') && data['status'] != 'success';
      final isHttpError = response.statusCode != null && response.statusCode! >= 400;

      if (isNotSuccess || isHttpError) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = errors.values
              .expand((v) => v is List ? v.map((e) => e.toString()) : [v.toString()])
              .join('\n');
          if (messages.isNotEmpty) throw messages;
        }

        final msg = data['message']?.toString();
        if (data['status'] == 'error' || ErrorParser.isSystemError(msg)) {
          throw defaultError;
        }
        throw msg ?? defaultError;
      }
    }
  }

  Future<PuskesmasProfileModel> fetchProfile() async {
    try {
      final response = await _apiClient.dio.get('puskesmas-profile');
      _checkResponse(response, 'Gagal mengambil profil Puskesmas');
      final responseData = response.data['data'];
      return PuskesmasProfileModel.fromJson(responseData);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil profil Puskesmas');
    }
  }

  Future<PuskesmasProfileModel> updateProfile({
    required String name,
    required String address,
    required String phone,
    required String email,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        'puskesmas-profile',
        data: {
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      _checkResponse(response, 'Gagal memperbarui profil Puskesmas');
      final responseData = response.data['data'];
      return PuskesmasProfileModel.fromJson(responseData);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal memperbarui profil Puskesmas');
    }
  }
}
