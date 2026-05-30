import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/utils/error_parser.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['status'] != 'success') {
        throw response.data['message'] ?? 'Gagal login';
      }
      
      final data = response.data['data'];
      return {
        'token': data['access_token'],
        'user': UserModel.fromJson(data['user']),
      };
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal login. Periksa koneksi atau kredensial Anda.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String nationalId,
    required String gender,
    required String birthDate,
  }) async {
    try {
      final response = await _apiClient.dio.post('auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'national_id': nationalId,
        'phone_number': phone,
        'gender': gender,
        'birth_date': birthDate,
        'address': address,
        'role': 'patient',
      });

      if (response.data['status'] != 'success') {
        throw response.data['message'] ?? 'Gagal registrasi';
      }
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal registrasi. Silakan coba lagi.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('auth/logout');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal logout');
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _apiClient.dio.post('auth/fcm-token', data: {
        'fcm_token': token,
      });
    } catch (e) {
      // Just catch silently to not interrupt the login flow
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? nationalId,
    String? gender,
    String? birthDate,
  }) async {
    try {
      final response = await _apiClient.dio.post('auth/update-profile', data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) ...{
          'phone': phone,
          'phone_number': phone,
        },
        if (address != null) 'address': address,
        if (nationalId != null) 'national_id': nationalId,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birth_date': birthDate,
      });

      if (response.data['status'] != 'success') {
        throw response.data['message'] ?? 'Gagal memperbarui profil';
      }

      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui profil. Silakan coba lagi.');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get('auth/profile');
      final data = response.data['data'];
      
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil profil');
    }
  }

  Future<String?> requestPasswordResetOtp(String email, String nationalId) async {
    try {
      final response = await _apiClient.dio.post('auth/forgot-password/otp', data: {
        'email': email,
        'national_id': nationalId,
      });

      if (response.data['status'] != 'success') {
        throw response.data['message'] ?? 'Gagal meminta OTP';
      }
      
      final data = response.data['data'];
      return data?['otp_code_testing']?.toString();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal meminta OTP. Periksa data Anda.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email, String nationalId, String otpCode, String newPassword) async {
    try {
      final response = await _apiClient.dio.post('auth/forgot-password', data: {
        'email': email,
        'national_id': nationalId,
        'otp_code': otpCode,
        'new_password': newPassword,
      });

      if (response.data['status'] != 'success') {
        throw response.data['message'] ?? 'Gagal reset password';
      }
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal reset password. Periksa data Anda.');
    } catch (e) {
      rethrow;
    }
  }
}

