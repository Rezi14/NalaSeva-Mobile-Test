import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/logic/auth_provider.dart';

// Auth
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/register_screen.dart';
import '../../features/auth/ui/forgot_password_screen.dart';

// Admin
import '../../features/admin/ui/admin_dashboard.dart';
import '../../features/admin/ui/admin_settings_screen.dart';
import '../../features/admin/ui/user_management_screen.dart';
import '../../features/admin/ui/polyclinic_management_screen.dart';
import '../../features/admin/ui/doctor_management_screen.dart';
import '../../features/admin/ui/doctor_schedule_management_screen.dart';
import '../../features/admin/ui/queue_management_screen.dart';
import '../../features/admin/ui/patient_management_screen.dart';
import '../../features/admin/ui/examination_history_screen.dart';
import '../../features/admin/ui/queue_monitor_screen.dart';
import '../../features/admin/ui/admin_clinic_holidays_screen.dart';
import '../../features/admin/ui/admin_doctor_leaves_screen.dart';
import '../../features/admin/widgets/qr_scanner_page.dart';

// Doctor
import '../../features/doctor/ui/doctor_dashboard.dart';
import '../../features/doctor/ui/examination_form_screen.dart';
import '../../features/doctor/ui/doctor_profile_screen.dart';
import '../../features/doctor/ui/doctor_edit_profile_screen.dart';

// Patient
import '../../features/patient/ui/patient_dashboard.dart';
import '../../features/patient/ui/booking_screen.dart';
import '../../features/patient/ui/profile_screen.dart';
import '../../features/patient/ui/patient_history_screen.dart';
import '../../features/patient/ui/notification_screen.dart';
import '../../features/patient/ui/edit_profile_screen.dart';

import '../../features/admin/ui/admin_payment_list_screen.dart';
import '../../features/patient/ui/patient_payment_list_screen.dart';
import '../../features/pharmacy/ui/pharmacy_dashboard_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String login = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Admin routes
  static const String adminHome = '/admin/home';
  static const String adminUsers = '/admin/users';
  static const String adminDoctors = '/admin/doctors';
  static const String adminPolyclinics = '/admin/polyclinics';
  static const String adminSchedules = '/admin/schedules';
  static const String adminQueues = '/admin/queues';
  static const String adminPatients = '/admin/patients';
  static const String adminHistory = '/admin/history';
  static const String adminSettings = '/admin/settings';
  static const String adminProfile = '/admin/profile';
  static const String adminEditProfile = '/admin/edit-profile';
  static const String adminHolidays = '/admin/holidays';
  static const String adminLeaves = '/admin/leaves';
  static const String adminScan = '/admin/scan';

  // Doctor routes
  static const String doctorHome = '/doctor/home';
  static const String doctorExamination = '/doctor/examination';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorEditProfile = '/doctor/edit-profile';

  // Patient routes
  static const String patientHome = '/patient/home';
  static const String patientBooking = '/patient/booking';
  static const String patientProfile = '/patient/profile';
  static const String patientEditProfile = '/patient/edit-profile';
  static const String patientHistory = '/patient/history';
  static const String patientNotifications = '/patient/notifications';

  // Pharmacist routes
  static const String pharmacyProfile = '/pharmacy/profile';
  static const String pharmacyEditProfile = '/pharmacy/edit-profile';

  // Other
  static const String tvMonitor = '/tv-monitor';

  // Payments & Pharmacy
  static const String paymentList = '/payment/list';
  static const String pharmacyHome = '/pharmacy/home';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    adminHome: (context) => const AdminDashboard(),
    adminUsers: (context) => const UserManagementScreen(),
    adminDoctors: (context) => const DoctorManagementScreen(),
    adminPolyclinics: (context) => const PolyclinicManagementScreen(),
    adminSchedules: (context) => const DoctorScheduleManagementScreen(),
    adminQueues: (context) => const QueueManagementScreen(),
    adminPatients: (context) => const PatientManagementScreen(),
    adminHistory: (context) => const ExaminationHistoryScreen(),
    adminSettings: (context) => const AdminSettingsScreen(),
    adminProfile: (context) => const ProfileScreen(),
    adminEditProfile: (context) => const EditProfileScreen(),
    adminHolidays: (context) => const AdminClinicHolidaysScreen(),
    adminLeaves: (context) => const AdminDoctorLeavesScreen(),
    adminScan: (context) => const QRScannerPage(),
    doctorHome: (context) => const DoctorDashboard(),
    doctorExamination: (context) => const ExaminationFormScreen(),
    doctorProfile: (context) => const DoctorProfileScreen(),
    doctorEditProfile: (context) => const DoctorEditProfileScreen(),
    patientHome: (context) => const PatientDashboard(),
    patientBooking: (context) => const BookingScreen(),
    patientProfile: (context) => const ProfileScreen(),
    patientEditProfile: (context) => const EditProfileScreen(),
    patientHistory: (context) => const PatientHistoryScreen(),
    patientNotifications: (context) => const NotificationScreen(),
    pharmacyProfile: (context) => const ProfileScreen(),
    pharmacyEditProfile: (context) => const EditProfileScreen(),
    tvMonitor: (context) => const QueueMonitorScreen(),
    paymentList: (context) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user?.role == 'admin') {
        return const AdminPaymentListScreen();
      }
      return const PatientPaymentListScreen();
    },
    pharmacyHome: (context) => const PharmacyDashboardScreen(),
  };

  static final Map<String, List<String>> _routePermissions = {
    login: [],
    register: [],
    forgotPassword: [],
    tvMonitor: ['admin'], // Khusus Admin

    // Admin routes
    adminHome: ['admin'],
    adminUsers: ['admin'],
    adminDoctors: ['admin'],
    adminPolyclinics: ['admin'],
    adminSchedules: ['admin'],
    adminQueues: ['admin'],
    adminPatients: ['admin'],
    adminHistory: ['admin'],
    adminSettings: ['admin'],
    adminProfile: ['admin'],
    adminEditProfile: ['admin'],
    adminHolidays: ['admin'],
    adminLeaves: ['admin'],
    adminScan: ['admin'],

    // Doctor routes
    doctorHome: ['doctor'],
    doctorExamination: ['doctor'],
    doctorProfile: ['doctor'],
    doctorEditProfile: ['doctor'],

    // Patient routes
    patientHome: ['patient'],
    patientBooking: ['patient'],
    patientProfile: ['patient'],
    patientEditProfile: ['patient'],
    patientHistory: ['patient'],
    patientNotifications: ['patient'],
    paymentList: ['patient', 'admin'],
    pharmacyHome: ['pharmacist', 'admin'],
    pharmacyProfile: ['pharmacist'],
    pharmacyEditProfile: ['pharmacist'],
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder == null) return null;

    return MaterialPageRoute(
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        final name = settings.name ?? '';

        final allowedRoles = _routePermissions[name];

        if (allowedRoles != null && allowedRoles.isNotEmpty) {
          // Proteksi Autentikasi: Belum Login -> Redirect ke Login
          if (user == null) {
            return const LoginScreen();
          }
          // Proteksi Otorisasi: Peran tidak sesuai -> Redirect ke Login
          if (!allowedRoles.contains(user.role)) {
            return const LoginScreen();
          }
        }

        return builder(context);
      },
      settings: settings,
    );
  }
}
