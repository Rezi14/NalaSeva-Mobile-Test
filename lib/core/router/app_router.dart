import 'package:flutter/material.dart';

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
  static const String adminHolidays = '/admin/holidays';
  static const String adminLeaves = '/admin/leaves';

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

  // Other
  static const String tvMonitor = '/tv-monitor';

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
    adminHolidays: (context) => const AdminClinicHolidaysScreen(),
    adminLeaves: (context) => const AdminDoctorLeavesScreen(),
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
    tvMonitor: (context) => const QueueMonitorScreen(),
  };
}
