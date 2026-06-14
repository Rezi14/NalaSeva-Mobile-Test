import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../logic/patient_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
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
        ? user!.name
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'PS';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 800,
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.backgroundGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Navigator.pushNamed(
                                  context, '/patient/profile'),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          user?.name ?? 'Pasien',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white),
                                onPressed: () => Navigator.pushNamed(
                                    context, '/patient/notifications'),
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
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: QueueStatusCard(provider: provider),
                      ),

                      const SizedBox(height: 32),

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
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Lihat Semua',
                                  style: GoogleFonts.poppins(
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
                              crossAxisCount:
                                  !ResponsiveHelper.isMobile(context) ? 4 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio:
                                  !ResponsiveHelper.isMobile(context) ? 1.8 : 1.5,
                              children: [
                                ServiceCard(
                                  label: 'Ambil Antrean',
                                  icon: Icons.confirmation_number_rounded,
                                  color: AppTheme.secondaryColor,
                                  bgColor: AppTheme.secondaryColor
                                      .withValues(alpha: 0.1),
                                  onTap: () => Navigator.pushNamed(
                                      context, '/patient/booking'),
                                ),
                                ServiceCard(
                                  label: 'Riwayat',
                                  icon: Icons.history_rounded,
                                  color: AppTheme.accentColor,
                                  bgColor:
                                      AppTheme.accentColor.withValues(alpha: 0.1),
                                  onTap: () => Navigator.pushNamed(
                                      context, '/patient/history'),
                                ),
                                ServiceCard(
                                  label: 'Pembayaran',
                                  icon: Icons.receipt_long_rounded,
                                  color: AppTheme.successColor,
                                  bgColor: AppTheme.successColor
                                      .withValues(alpha: 0.1),
                                  onTap: () => Navigator.pushNamed(
                                      context, '/payment/list'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm =
                                await AppDialogs.showConfirmationDialog(
                              context,
                              'Panggilan Darurat',
                              'Apakah Anda ingin menghubungi saluran darurat Puskesmas Nalaseva? (119 / 021-555-1234)',
                              confirmText: 'Hubungi',
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
                            minimumSize: Size(double.infinity,
                                ResponsiveHelper.buttonHeight(context)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.radiusButton(context))),
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
    if (hour >= 4 && hour < 11) return 'Selamat Pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat Siang,';
    if (hour >= 15 && hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }
}