import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/services/firebase_messaging_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final _storage = const FlutterSecureStorage();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._repository);

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.login(email, password);
      _user = result['user'];
      await _storage.write(key: 'access_token', value: result['token']);
      
      if (!kIsWeb) {
        try {
          final fcmService = FirebaseMessagingService();
          await fcmService.initialize();
          final token = await fcmService.getFCMToken();
          if (token != null) {
            await _repository.updateFcmToken(token);
          }
        } catch (e) {
          debugPrint('FCM Setup Error: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        nationalId: nationalId,
        gender: gender,
        birthDate: birthDate,
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

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      _user = null;
      await _storage.delete(key: 'access_token');
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? nationalId,
    String? gender,
    String? birthDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
        nationalId: nationalId,
        gender: gender,
        birthDate: birthDate,
      );
      // Re-fetch complete profile to get all relationships (doctor, patient, etc.)
      _user = await _repository.getProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> forgotPassword(String email, String nationalId, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.forgotPassword(email, nationalId, newPassword);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        _user = await _repository.getProfile();
      } catch (e) {
        _user = null;
        await _storage.delete(key: 'access_token');
      }
    } else {
      _user = null;
    }
    notifyListeners();
  }
}
