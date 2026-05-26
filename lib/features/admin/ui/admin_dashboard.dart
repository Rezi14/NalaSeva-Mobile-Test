import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/queue_model.dart';
import 'admin_booking_detail_screen.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/clinic_stat_card.dart';
import '../widgets/admin_queue_tile.dart';
import '../widgets/admin_weekly_chart.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/admin_voice_call_dialog.dart';
import '../widgets/qr_scanner_page.dart';

extension ListDivide on List<Widget> {
  List<Widget> divide(Widget separator) {
    if (isEmpty) return this;
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i != length - 1) result.add(separator);
    }
    return result;
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchUsers();
      provider.fetchPatients();
      provider.fetchDoctors();
      provider.fetchQueues();
      provider.fetchPolyclinics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    final List<double> weeklyCounts = List.filled(7, 0.0);
    for (var q in provider.queues) {
      final parsedDate = DateTime.tryParse(q.date);
      if (parsedDate != null) {
        final weekdayIndex = parsedDate.weekday - 1;
        if (weekdayIndex >= 0 && weekdayIndex < 7) {
          weeklyCounts[weekdayIndex] += 1.0;
        }
      }
    }
    final List<double> finalCounts = weeklyCounts;
    final double maxVal = finalCounts.reduce((a, b) => a > b ? a : b);
    final double dynamicMaxY = maxVal > 5 ? (maxVal * 1.25).ceilToDouble() : 10.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Header Section
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: AnimationLimiter(
                      child: Column(
                        children: [
                          AnimationConfiguration.staggeredList(
                            position: 0,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 30.0,
                              child: FadeInAnimation(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NalaSeva Admin',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Puskesmas Central Hub',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ].divide(const SizedBox(height: 4)),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          '/patient/profile',
                                        ),
                                        icon: const Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AnimationConfiguration.staggeredList(
                            position: 1,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 30.0,
                              child: FadeInAnimation(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AdminStatCard(
                                            label: 'Total Pasien',
                                            value: provider.queues.where((q) => 
                                              q.status == QueueStatus.booked || 
                                              q.status == QueueStatus.waiting || 
                                              q.status == QueueStatus.examining
                                            ).length.toString(),
                                            icon: Icons.people_alt_rounded,
                                            onTap: () => Navigator.pushNamed(context, '/admin/patients'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: AdminStatCard(
                                            label: 'Total Antrean',
                                            value: provider.queues.where((q) => 
                                              q.status == QueueStatus.booked || 
                                              q.status == QueueStatus.waiting || 
                                              q.status == QueueStatus.examining
                                            ).length.toString(),
                                            icon: Icons.format_list_numbered_rounded,
                                            onTap: () => Navigator.pushNamed(context, '/admin/queues'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: () => Navigator.pushNamed(context, '/tv-monitor'),
                                      icon: const Icon(Icons.tv_rounded, size: 18, color: Colors.white),
                                      label: Text(
                                        'TV Monitor',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white, width: 1.5),
                                        minimumSize: const Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16)),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Clinic Live Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 200),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status Langsung Klinik',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/admin/polyclinics',
                                ),
                                child: const Text('Lihat Semua'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.polyclinics.isEmpty)
                          FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 250),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Belum ada poliklinik yang aktif',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: provider.polyclinics.take(4).length,
                            itemBuilder: (context, index) {
                              final poly = provider.polyclinics[index];
                              final colors = [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                                AppTheme.accentColor,
                                const Color(0xFF64748B),
                              ];
                              return FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(milliseconds: 250 + (index * 80)),
                                child: ClinicStatCard(
                                  name: poly.name,
                                  counter:
                                      'Pasien: ${provider.queues.where((q) => q.polyclinic.id == poly.id && (q.status == QueueStatus.booked || q.status == QueueStatus.waiting || q.status == QueueStatus.examining)).length}',
                                  wait:
                                      'Menunggu: ${provider.queues.where((q) => q.polyclinic.id == poly.id && q.status == QueueStatus.waiting).length}',
                                  color: colors[index % colors.length],
                                ),
                              );
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Active Queues
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 350),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Antrean Aktif',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/admin/queues'),
                                child: const Text('Lihat Semua'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final activeQList = provider.queues
                                .where(
                                  (q) =>
                                      q.status == QueueStatus.booked ||
                                      q.status == QueueStatus.waiting ||
                                      q.status == QueueStatus.examining,
                                )
                                .take(3)
                                .toList();
                            if (activeQList.isEmpty) {
                              return FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: const Duration(milliseconds: 400),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      'Tidak ada antrean aktif',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: activeQList.asMap().entries.map((entry) {
                                final index = entry.key;
                                final q = entry.value;
                                return FadeInUp(
                                  duration: const Duration(milliseconds: 500),
                                  delay: Duration(milliseconds: 400 + (index * 80)),
                                  child: AdminQueueTile(
                                    queue: q,
                                    onTap: () {
                                      final provider = context.read<AdminProvider>();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminBookingDetailScreen(queue: q),
                                        ),
                                      ).then((_) {
                                        if (mounted) {
                                          provider.fetchQueues();
                                        }
                                      });
                                    },
                                    onCall: () => AdminVoiceCallDialog.show(context, q),
                                    onSkip: () => _confirmMoveToBack(context, q),
                                  ),
                                );
                              }).toList().divide(const SizedBox(height: 12)),
                            );
                          }
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const SizedBox(height: 10),

                    const SizedBox(height: 30),

                    // Weekly Traffic Chart
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 500),
                      child: AdminWeeklyChart(
                        weeklyCounts: finalCounts,
                        dynamicMaxY: dynamicMaxY,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: const AdminBottomNav(activeIndex: 0),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 76),
          child: FadeInRight(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 400),
            child: FloatingActionButton.extended(
              onPressed: () => _openScanner(context),
              backgroundColor: AppTheme.primaryColor,
              elevation: 4,
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              label: Text(
                'SCAN ABSENSI',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmMoveToBack(BuildContext context, QueueModel queue) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Lewati & Pindah ke Belakang',
      'Pasien ${queue.patient.fullName} belum check-in/absen. Apakah Anda yakin ingin memindahkan nomor antrean ${queue.queueNumber} ke posisi paling belakang?',
      confirmText: 'PINDAHKAN',
    );

    if (confirm == true && context.mounted) {
      final provider = context.read<AdminProvider>();
      await provider.moveQueueToBack(queue);
      if (context.mounted) {
        if (provider.error != null) {
          AppDialogs.showNotificationDialog(
            context,
            'Gagal',
            provider.error!,
            isError: true,
          );
        }
      }
    }
  }

  void _openScanner(BuildContext context) {
    final provider = context.read<AdminProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    ).then((_) {
      if (!mounted) return;
      provider.fetchQueues();
    });
  }
}
