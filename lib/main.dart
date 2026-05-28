import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/admin/data/admin_repository.dart';
import 'features/admin/logic/admin_provider.dart';
import 'features/doctor/data/doctor_repository.dart';
import 'features/doctor/logic/doctor_provider.dart';
import 'features/patient/data/patient_repository.dart';
import 'features/patient/logic/patient_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error (likely missing google-services.json): $e');
  }
  
  await initializeDateFormatting('id_ID', null);
  
  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient);
  final adminRepository = AdminRepository(apiClient);
  final doctorRepository = DoctorRepository(apiClient);
  final patientRepository = PatientRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => AdminProvider(adminRepository)),
        ChangeNotifierProvider(create: (_) => DoctorProvider(doctorRepository)),
        ChangeNotifierProvider(create: (_) => PatientProvider(patientRepository)),
      ],
      child: const NalasevaApp(),
    ),
  );
}

class NalasevaApp extends StatelessWidget {
  const NalasevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NalaSeva',
      navigatorKey: AppRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
