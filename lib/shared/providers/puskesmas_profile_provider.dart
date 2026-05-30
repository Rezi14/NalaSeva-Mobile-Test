import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/error_parser.dart';
import '../models/puskesmas_profile_model.dart';

class PuskesmasProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  PuskesmasProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  PuskesmasProfileProvider(this._apiClient);

  PuskesmasProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPuskesmasProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('puskesmas-profile');
      final responseData = response.data['data'];
      _profile = PuskesmasProfileModel.fromJson(responseData);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ErrorParser.parse(e, 'Gagal mengambil profil Puskesmas').toString();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePuskesmasProfile({
    required String name,
    required String address,
    required String phone,
    required String email,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      _profile = PuskesmasProfileModel.fromJson(responseData);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ErrorParser.parse(e, 'Gagal memperbarui profil Puskesmas').toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
