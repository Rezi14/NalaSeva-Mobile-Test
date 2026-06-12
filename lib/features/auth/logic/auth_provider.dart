import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/services/firebase_messaging_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final FirebaseMessagingService _fcmService;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._repository, this._fcmService);

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.login(email, password);
      _user = result['user'];
      await _storage.write(key: 'access_token', value: result['token']);
      
      // Fetch full profile with full relationship properties (patient, doctor, etc.)
      try {
        final fullProfile = await _repository.getProfile();
        _user = fullProfile;
      } catch (e) {
        debugPrint('Profile fetch failed during login: $e');
      }

      if (_user != null) {
        await _storage.write(key: 'user_role', value: _user!.role);
        if (_user!.patientId != null) {
          await _storage.write(key: 'patient_id', value: _user!.patientId.toString());
        }
        if (_user!.doctorId != null) {
          await _storage.write(key: 'doctor_id', value: _user!.doctorId.toString());
        }
      }
      
      if (!kIsWeb) {
        // Run FCM setup in background to avoid blocking login flow
        Future.microtask(() async {
          try {
            // Selalu inisialisasi FCM agar listener dan handler terdaftar
            await _fcmService.initialize();
            final token = await _fcmService.getFCMToken();
            if (token != null) {
              await _repository.updateFcmToken(token);
            }
          } catch (e) {
            debugPrint('FCM Setup Error: $e');
          }
        });
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
      await _storage.delete(key: 'user_role');
      await _storage.delete(key: 'patient_id');
      await _storage.delete(key: 'doctor_id');
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
      if (_user != null) {
        if (_user!.patientId != null) {
          await _storage.write(key: 'patient_id', value: _user!.patientId.toString());
        }
        if (_user!.doctorId != null) {
          await _storage.write(key: 'doctor_id', value: _user!.doctorId.toString());
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

  Future<String?> requestPasswordResetOtp(String email, String nationalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final otp = await _repository.requestPasswordResetOtp(email, nationalId);
      _isLoading = false;
      notifyListeners();
      return otp;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> forgotPassword(String email, String nationalId, String otpCode, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.forgotPassword(email, nationalId, otpCode, newPassword);
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
      final savedRole = await _storage.read(key: 'user_role');
      if (savedRole == 'patient') {
        try {
          await _repository.logout().timeout(const Duration(seconds: 2));
        } catch (e) {
          debugPrint('Silent API logout failed for patient on start: $e');
        } finally {
          _user = null;
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'user_role');
          await _storage.delete(key: 'patient_id');
          await _storage.delete(key: 'doctor_id');
        }
        notifyListeners();
        return;
      }
      try {
        _user = await _repository.getProfile();
        if (_user != null) {
          if (_user!.role == 'patient') {
            try {
              await _repository.logout().timeout(const Duration(seconds: 2));
            } catch (e) {
              debugPrint('Silent API logout failed for patient on start: $e');
            } finally {
              _user = null;
              await _storage.delete(key: 'access_token');
              await _storage.delete(key: 'user_role');
              await _storage.delete(key: 'patient_id');
              await _storage.delete(key: 'doctor_id');
            }
            notifyListeners();
            return;
          }
          await _storage.write(key: 'user_role', value: _user!.role);
          if (_user!.patientId != null) {
            await _storage.write(key: 'patient_id', value: _user!.patientId.toString());
          } else {
            await _storage.delete(key: 'patient_id');
          }
          if (_user!.doctorId != null) {
            await _storage.write(key: 'doctor_id', value: _user!.doctorId.toString());
          } else {
            await _storage.delete(key: 'doctor_id');
          }

          if (!kIsWeb) {
            // Run FCM setup in background to avoid blocking app start checkAuth
            Future.microtask(() async {
              try {
                // Selalu inisialisasi FCM agar listener dan handler terdaftar
                await _fcmService.initialize();
                final tokenStr = await _fcmService.getFCMToken();
                if (tokenStr != null) {
                  await _repository.updateFcmToken(tokenStr);
                }
              } catch (e) {
                debugPrint('FCM Setup Error on checkAuth: $e');
              }
            });
          }
        }
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('401') || errStr.contains('unauthorized') || errStr.contains('403') || errStr.contains('forbidden')) {
          _user = null;
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'user_role');
          await _storage.delete(key: 'patient_id');
          await _storage.delete(key: 'doctor_id');
        } else {
          // Kesalahan jaringan / server down sementara: pertahankan token lokal
          // Dan pulihkan dengan UserModel sentinel offline berdasarkan role terakhir beserta ID yang tercache
          final savedRole = await _storage.read(key: 'user_role');
          final savedPatientIdStr = await _storage.read(key: 'patient_id');
          final savedDoctorIdStr = await _storage.read(key: 'doctor_id');
          
          if (savedRole != null) {
            _user = UserModel(
              id: 0,
              name: 'Offline User',
              email: '',
              role: savedRole,
              patientId: savedPatientIdStr != null ? int.tryParse(savedPatientIdStr) : null,
              doctorId: savedDoctorIdStr != null ? int.tryParse(savedDoctorIdStr) : null,
            );
          } else {
            _user = null;
          }
        }
      }
    } else {
      _user = null;
    }
    notifyListeners();
  }
}
