import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nalaseva/features/auth/data/auth_repository.dart';
import 'package:nalaseva/features/auth/logic/auth_provider.dart';
import 'package:nalaseva/shared/models/user_model.dart';

// Custom Mock for AuthRepository
class MockAuthRepository implements AuthRepository {
  UserModel? mockUser;
  bool shouldThrowError = false;
  String errorMessage = 'Error occurred';
  String? lastFcmToken;
  
  Map<String, dynamic>? lastRegisterData;
  Map<String, dynamic>? lastUpdateProfileData;
  Map<String, dynamic>? lastForgotPasswordData;



  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (shouldThrowError) throw errorMessage;
    return {
      'token': 'mocked_access_token',
      'user': mockUser ?? UserModel(id: 1, name: 'John Doe', email: email, role: 'patient', patientId: 101),
    };
  }

  @override
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
    if (shouldThrowError) throw errorMessage;
    lastRegisterData = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'nationalId': nationalId,
      'gender': gender,
      'birthDate': birthDate,
    };
  }

  @override
  Future<void> logout() async {
    if (shouldThrowError) throw errorMessage;
  }

  @override
  Future<void> updateFcmToken(String token) async {
    lastFcmToken = token;
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? nationalId,
    String? gender,
    String? birthDate,
  }) async {
    if (shouldThrowError) throw errorMessage;
    lastUpdateProfileData = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (nationalId != null) 'national_id': nationalId,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
    };
    return mockUser ?? UserModel(id: 1, name: name ?? 'John Doe', email: email ?? 'john@gmail.com', role: 'patient', patientId: 101);
  }

  @override
  Future<UserModel> getProfile() async {
    if (shouldThrowError) throw errorMessage;
    return mockUser ?? UserModel(id: 1, name: 'John Doe', email: 'john@gmail.com', role: 'patient', patientId: 101);
  }

  @override
  Future<String?> requestPasswordResetOtp(String email, String nationalId) async {
    if (shouldThrowError) throw errorMessage;
    return '123456';
  }

  @override
  Future<void> forgotPassword(String email, String nationalId, String otpCode, String newPassword) async {
    if (shouldThrowError) throw errorMessage;
    lastForgotPasswordData = {
      'email': email,
      'national_id': nationalId,
      'otp_code': otpCode,
      'new_password': newPassword,
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Mock Secure Storage (supporting old and new channel names)
  final Map<String, String> secureStorageValues = {};
  
  Future<dynamic> mockCallHandler(MethodCall methodCall) async {
    if (methodCall.method == 'write') {
      secureStorageValues[methodCall.arguments['key']] = methodCall.arguments['value'];
      return null;
    }
    if (methodCall.method == 'read') {
      return secureStorageValues[methodCall.arguments['key']];
    }
    if (methodCall.method == 'delete') {
      secureStorageValues.remove(methodCall.arguments['key']);
      return null;
    }
    if (methodCall.method == 'deleteAll') {
      secureStorageValues.clear();
      return null;
    }
    return null;
  }

  const channelOld = MethodChannel('plugins.itrix.com/flutter_secure_storage');
  const channelNew = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channelOld, mockCallHandler);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channelNew, mockCallHandler);

  late MockAuthRepository mockRepository;
  late AuthProvider authProvider;

  setUp(() {
    secureStorageValues.clear();
    mockRepository = MockAuthRepository();
    authProvider = AuthProvider(mockRepository);
  });

  group('AuthProvider Tests', () {
    test('Login sukses menyimpan data ke storage dan memuat user profile', () async {
      final user = UserModel(
        id: 1,
        name: 'Ahmad Prioritas',
        email: 'ahmad@example.com',
        role: 'patient',
        patientId: 202,
      );
      mockRepository.mockUser = user;

      expect(authProvider.isLoading, false);
      expect(authProvider.user, null);

      await authProvider.login('ahmad@example.com', 'password123');

      expect(authProvider.isLoading, false);
      expect(authProvider.user?.name, 'Ahmad Prioritas');
      expect(authProvider.user?.role, 'patient');
      expect(authProvider.user?.patientId, 202);
      expect(authProvider.error, null);

      // Pastikan token dan data terkait ditulis ke Secure Storage
      expect(secureStorageValues['access_token'], 'mocked_access_token');
      expect(secureStorageValues['user_role'], 'patient');
      expect(secureStorageValues['patient_id'], '202');
    });

    test('Login sukses sebagai apoteker (pharmacist) menyimpan data ke storage', () async {
      final user = UserModel(
        id: 3,
        name: 'Apoteker Utama Puskesmas',
        email: 'apoteker@apoteker.com',
        role: 'pharmacist',
      );
      mockRepository.mockUser = user;

      await authProvider.login('apoteker@apoteker.com', 'password123');

      expect(authProvider.isLoading, false);
      expect(authProvider.user?.name, 'Apoteker Utama Puskesmas');
      expect(authProvider.user?.role, 'pharmacist');
      expect(authProvider.error, null);

      expect(secureStorageValues['access_token'], 'mocked_access_token');
      expect(secureStorageValues['user_role'], 'pharmacist');
    });

    test('Login gagal mengatur error dan melempar Exception', () async {
      mockRepository.shouldThrowError = true;
      mockRepository.errorMessage = 'Kredensial tidak valid';

      await expectLater(
        authProvider.login('invalid@gmail.com', 'wrong'),
        throwsA('Kredensial tidak valid'),
      );

      expect(authProvider.isLoading, false);
      expect(authProvider.user, null);
      expect(authProvider.error, 'Kredensial tidak valid');
    });

    test('Registrasi pasien mengirim parameter data dengan benar', () async {
      await authProvider.register(
        name: 'Budi Santoso',
        email: 'budi@gmail.com',
        password: 'password123',
        phone: '081234567890',
        address: 'Sleman, DIY',
        nationalId: '1234567890123456',
        gender: 'Laki-laki',
        birthDate: '1995-05-15',
      );

      expect(authProvider.isLoading, false);
      expect(authProvider.error, null);
      expect(mockRepository.lastRegisterData?['name'], 'Budi Santoso');
      expect(mockRepository.lastRegisterData?['nationalId'], '1234567890123456');
    });

    test('Logout menghapus seluruh key dari Secure Storage dan membersihkan user state', () async {
      // Setup initial logged-in state
      secureStorageValues['access_token'] = 'token_lama';
      secureStorageValues['user_role'] = 'patient';
      secureStorageValues['patient_id'] = '101';
      mockRepository.mockUser = UserModel(id: 1, name: 'John', email: 'john@gmail.com', role: 'patient');
      await authProvider.checkAuth();

      expect(authProvider.user, isNotNull);

      await authProvider.logout();

      expect(authProvider.user, null);
      expect(secureStorageValues['access_token'], null);
      expect(secureStorageValues['user_role'], null);
      expect(secureStorageValues['patient_id'], null);
    });

    test('Update profil sukses memperbarui data dan relasi user', () async {
      mockRepository.mockUser = UserModel(
        id: 1,
        name: 'Budi Edit',
        email: 'budi@gmail.com',
        role: 'patient',
        patientId: 303,
      );

      await authProvider.updateProfile(
        name: 'Budi Edit',
        phone: '0811111111',
      );

      expect(authProvider.user?.name, 'Budi Edit');
      expect(secureStorageValues['patient_id'], '303');
    });

    test('Lupa password OTP flow bekerja sesuai skenario', () async {
      final otp = await authProvider.requestPasswordResetOtp('john@gmail.com', '1234567890123456');
      expect(otp, '123456');

      await authProvider.forgotPassword('john@gmail.com', '1234567890123456', '123456', 'passwordbaru');
      expect(mockRepository.lastForgotPasswordData?['new_password'], 'passwordbaru');
    });

    test('checkAuth (Session Restore) sukses ketika online', () async {
      secureStorageValues['access_token'] = 'token_valid';
      mockRepository.mockUser = UserModel(id: 1, name: 'John Doe', email: 'john@gmail.com', role: 'doctor', doctorId: 99);

      await authProvider.checkAuth();

      expect(authProvider.user?.name, 'John Doe');
      expect(authProvider.user?.role, 'doctor');
      expect(secureStorageValues['user_role'], 'doctor');
      expect(secureStorageValues['doctor_id'], '99');
    });

    test('checkAuth (Session Restore) memaksa logout jika token kedaluwarsa/tidak valid (401/403)', () async {
      secureStorageValues['access_token'] = 'token_invalid';
      secureStorageValues['user_role'] = 'patient';
      
      mockRepository.shouldThrowError = true;
      mockRepository.errorMessage = 'Unauthorized (401)';

      await authProvider.checkAuth();

      expect(authProvider.user, null);
      expect(secureStorageValues['access_token'], null);
      expect(secureStorageValues['user_role'], null);
    });

    test('checkAuth (Session Restore) dengan offline handling (Sentinel Offline) jika terjadi error jaringan', () async {
      secureStorageValues['access_token'] = 'token_valid';
      secureStorageValues['user_role'] = 'doctor';
      secureStorageValues['doctor_id'] = '99';
      
      mockRepository.shouldThrowError = true;
      mockRepository.errorMessage = 'Connection timeout / server down (500)';

      await authProvider.checkAuth();

      // Sentinel offline harus terbuat dan mempertahankan role & cached ID
      expect(authProvider.user, isNotNull);
      expect(authProvider.user?.name, 'Offline User');
      expect(authProvider.user?.role, 'doctor');
      expect(authProvider.user?.doctorId, 99);
      
      // Token tidak boleh dihapus agar user bisa mencoba kembali nanti saat online
      expect(secureStorageValues['access_token'], 'token_valid');
    });
  });
}
