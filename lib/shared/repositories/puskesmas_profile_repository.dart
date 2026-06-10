import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/utils/error_parser.dart';
import '../models/puskesmas_profile_model.dart';

class PuskesmasProfileRepository {
  final ApiClient _apiClient;

  PuskesmasProfileRepository(this._apiClient);

  Future<PuskesmasProfileModel> fetchProfile() async {
    try {
      final response = await _apiClient.dio.get('puskesmas-profile');
      final responseData = response.data['data'];
      return PuskesmasProfileModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil profil Puskesmas');
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
      final responseData = response.data['data'];
      return PuskesmasProfileModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui profil Puskesmas');
    }
  }
}
