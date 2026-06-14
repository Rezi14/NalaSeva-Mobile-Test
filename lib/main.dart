import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'shared/repositories/payment_repository.dart';
import 'shared/providers/payment_provider.dart';
import 'features/pharmacy/data/pharmacy_repository.dart';
import 'features/pharmacy/logic/pharmacy_provider.dart';
import 'shared/providers/puskesmas_profile_provider.dart';
import 'shared/repositories/puskesmas_profile_repository.dart';
import 'core/services/firebase_messaging_service.dart';
import 'shared/widgets/session_timeout_listener.dart';
import 'shared/widgets/connectivity_banner.dart';
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
  final paymentRepository = PaymentRepository(apiClient);
  final pharmacyRepository = PharmacyRepository(apiClient);
  final fcmService = FirebaseMessagingService(authRepository);
  final puskesmasProfileRepository = PuskesmasProfileRepository(apiClient);
  final puskesmasProfileProvider =
      PuskesmasProfileProvider(puskesmasProfileRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(authRepository, fcmService)),
        ChangeNotifierProvider(
            create: (_) => AdminProvider(adminRepository)),
        ChangeNotifierProvider(
            create: (_) => DoctorProvider(doctorRepository)),
        ChangeNotifierProvider(
            create: (_) => PatientProvider(patientRepository)),
        ChangeNotifierProvider(
            create: (_) => PaymentProvider(paymentRepository)),
        ChangeNotifierProvider(
            create: (_) => PharmacyProvider(pharmacyRepository)),
        ChangeNotifierProvider.value(value: puskesmasProfileProvider),
      ],
      child: const NalasevaApp(),
    ),
  );
}

class NalasevaApp extends StatefulWidget {
  const NalasevaApp({super.key});

  @override
  State<NalasevaApp> createState() => _NalasevaAppState();
}

class _NalasevaAppState extends State<NalasevaApp> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    if (!mounted) return;
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuth().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('Auth check timed out');
        },
      );
    } catch (e) {
      debugPrint('Error during auth check: $e');
    } finally {
      if (mounted) {
        try {
          final authProvider = context.read<AuthProvider>();
          if (authProvider.user != null) {
            context.read<PuskesmasProfileProvider>().fetchPuskesmasProfile();
          }
        } catch (e) {
          debugPrint('Error fetching puskesmas profile on start: $e');
        }
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final user = context.read<AuthProvider>().user;
    String initialRoute = AppRouter.login;
    if (user != null) {
      if (user.role == 'admin') {
        initialRoute = '/admin/home';
      } else if (user.role == 'doctor') {
        initialRoute = '/doctor/home';
      } else if (user.role == 'patient') {
        initialRoute = '/patient/home';
      } else if (user.role == 'pharmacist') {
        initialRoute = '/pharmacy/home';
      }
    }

    return MaterialApp(
      title: 'NalaSeva',
      navigatorKey: AppRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (initialRouteName) {
        return [
          AppRouter.onGenerateRoute(RouteSettings(name: initialRouteName))!,
        ];
      },
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        return SessionTimeoutListener(
          timeoutDuration: const Duration(minutes: 15),
          child: ConnectivityBanner(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}