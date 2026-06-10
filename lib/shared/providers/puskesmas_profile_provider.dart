import 'package:flutter/foundation.dart';
import '../models/puskesmas_profile_model.dart';
import '../repositories/puskesmas_profile_repository.dart';

class PuskesmasProfileProvider extends ChangeNotifier {
  final PuskesmasProfileRepository _repository;

  PuskesmasProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  PuskesmasProfileProvider(this._repository);

  PuskesmasProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPuskesmasProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.fetchProfile();
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
      _profile = await _repository.updateProfile(
        name: name,
        address: address,
        phone: phone,
        email: email,
        latitude: latitude,
        longitude: longitude,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
