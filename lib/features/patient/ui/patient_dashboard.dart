import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../auth/logic/auth_provider.dart';
import '../logic/patient_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../widgets/tomorrow_reminder_card.dart';
import '../widgets/turn_is_near_alert_card.dart';
import '../widgets/queue_status_card.dart';
import '../widgets/service_card.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchMyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<PatientProvider>();
    final initials = (user?.name ?? '').isNotEmpty
      ? user!.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
      : 'PS';

    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 800,
            child: Column(
              children: [
              // Header Section
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  color: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, '/patient/profile'),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initials,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: GoogleFonts.inter(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        user?.name ?? 'Pasien',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryColor),
                              onPressed: () => Navigator.pushNamed(context, '/patient/notifications'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
 
              TomorrowReminderCard(provider: provider),
              TurnIsNearAlertCard(provider: provider),
 
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Active Queue Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: QueueStatusCard(provider: provider),
                    ),
 
                    const SizedBox(height: 32),
 
                    // Health Services Section
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Layanan Kesehatan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Lihat Semua',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: screenWidth >= 600 ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: screenWidth >= 600 ? 1.8 : 1.5,
                            children: [
                              ServiceCard(
                                label: 'Ambil Antrean',
                                icon: Icons.confirmation_number_rounded,
                                color: AppTheme.secondaryColor,
                                bgColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                onTap: () => Navigator.pushNamed(context, '/patient/booking'),
                              ),
                              ServiceCard(
                                label: 'Riwayat',
                                icon: Icons.history_rounded,
                                color: AppTheme.accentColor,
                                bgColor: AppTheme.accentColor.withValues(alpha: 0.1),
                                onTap: () => Navigator.pushNamed(context, '/patient/history'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
 
                    const SizedBox(height: 40),
 
                    // Emergency Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await AppDialogs.showConfirmationDialog(
                            context,
                            'Panggilan Darurat',
                            'Apakah Anda ingin menghubungi saluran darurat Puskesmas Nalaseva? (119 / 021-555-1234)',
                            confirmText: 'HUBUNGI',
                            isDestructive: true,
                          );
 
                          if ((confirm ?? false) && context.mounted) {
                            AppDialogs.showNotificationDialog(
                              context,
                              'Memanggil Darurat',
                              'Menghubungi nomor darurat Puskesmas Nalaseva...',
                            );
                          }
                        },
                        icon: const Icon(Icons.call_rounded, color: Colors.white),
                        label: const Text('Panggilan Darurat'),
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.red,
                           foregroundColor: Colors.white,
                           minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context))),
                           elevation: 0,
                         ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }
}

