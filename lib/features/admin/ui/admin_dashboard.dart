import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
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
import '../../../core/utils/date_time_parser.dart';

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

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _menuAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _menuAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutBack,
    );
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
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  Widget _buildFabMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _menuAnimation,
      child: FadeTransition(
        opacity: _menuAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: 'fab_${label.toLowerCase().replaceAll(' ', '_')}',
                onPressed: () {
                  _toggleFabMenu();
                  onTap();
                },
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                child: Icon(icon, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final List<double> weeklyCounts = List.filled(7, 0.0);
    final now = DateTime.now();
    // Monday of the current week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    // Sunday of the current week (inclusive)
    final endOfWeekOnly = startOfWeekOnly.add(const Duration(days: 7));

    for (var q in provider.queues) {
      if (q.status == QueueStatus.completed) {
        final parsedDate = DateTimeParser.parseDateOnly(q.date);
        if (parsedDate != null) {
          if (parsedDate.isAtSameMomentAs(startOfWeekOnly) || 
              (parsedDate.isAfter(startOfWeekOnly) && parsedDate.isBefore(endOfWeekOnly))) {
            final weekdayIndex = parsedDate.weekday - 1;
            if (weekdayIndex >= 0 && weekdayIndex < 7) {
              weeklyCounts[weekdayIndex] += 1.0;
            }
          }
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
        body: Stack(
          children: [
            ResponsiveCenter(
              maxWidth: 950,
              child: Column(
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
                                              '/admin/profile',
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
                                                value: provider.patients.length.toString(),
                                                icon: Icons.people_alt_rounded,
                                                onTap: () => Navigator.pushNamed(context, '/admin/patients'),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: AdminStatCard(
                                                label: 'Total Antrean',
                                                value: provider.queues.where((q) => 
                                                  q.date == todayStr && (
                                                    q.status == QueueStatus.booked || 
                                                    q.status == QueueStatus.waiting || 
                                                    q.status == QueueStatus.examining
                                                  )
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
                                            minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: screenWidth >= 1024 ? 4 : (screenWidth >= 600 ? 3 : 2),
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: screenWidth >= 1024 ? 1.7 : 1.5,
                                ),
                                itemCount: provider.polyclinics.take(4).length,
                                itemBuilder: (context, index) {
                                  final poly = provider.polyclinics[index];
                                  final colors = [
                                    AppTheme.primaryColor, // Emerald Green
                                    AppTheme.successColor, // Mint Success Green
                                    const Color(0xFF0D9488), // Teal Green
                                    const Color(0xFF047857), // Forest Green
                                  ];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 500),
                                    delay: Duration(milliseconds: 250 + (index * 80)),
                                    child: ClinicStatCard(
                                      name: poly.name,
                                      counter:
                                          'Pasien: ${provider.queues.where((q) => q.polyclinic.id == poly.id && q.date == todayStr && (q.status == QueueStatus.booked || q.status == QueueStatus.waiting || q.status == QueueStatus.examining)).length}',
                                      wait:
                                          'Menunggu: ${provider.queues.where((q) => q.polyclinic.id == poly.id && q.date == todayStr && q.status == QueueStatus.waiting).length}',
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
                                    'Pendaftaran Aktif Hari Ini',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/admin/queues',
                                    ),
                                    child: const Text('Lihat Semua'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (provider.isLoading && provider.queues.isEmpty)
                              const Center(child: CircularProgressIndicator())
                            else if (provider.queues.where((q) => q.date == todayStr && q.status.isActive).isEmpty)
                              FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: const Duration(milliseconds: 400),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      'Tidak ada antrean aktif hari ini',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.queues.where((q) => q.date == todayStr && q.status.isActive).take(5).length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final activeQueues = provider.queues.where((q) => q.date == todayStr && q.status.isActive).toList();
                                  final queue = activeQueues[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 500),
                                    delay: Duration(milliseconds: 400 + (index * 80)),
                                    child: AdminQueueTile(
                                      queue: queue,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AdminBookingDetailScreen(queue: queue),
                                          ),
                                        ).then((_) {
                                          if (mounted) {
                                            provider.fetchQueues();
                                          }
                                        });
                                      },
                                      onSkip: () => _confirmMoveToBack(context, queue),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),

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
          ),
            if (_isFabOpen)
              Positioned.fill(
                child: FadeTransition(
                  opacity: _fabAnimationController,
                  child: GestureDetector(
                    onTap: _toggleFabMenu,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: ResponsiveCenter(
          maxWidth: 950,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildFabMenuItem(
                    icon: Icons.local_hospital_rounded,
                    label: 'Manajemen Poliklinik',
                    onTap: () => Navigator.pushNamed(context, '/admin/polyclinics'),
                  ),
                  _buildFabMenuItem(
                    icon: Icons.people_rounded,
                    label: 'Manajemen Dokter',
                    onTap: () => Navigator.pushNamed(context, '/admin/doctors'),
                  ),
                  _buildFabMenuItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'Manajemen Jadwal Dokter',
                    onTap: () => Navigator.pushNamed(context, '/admin/schedules'),
                  ),
                  _buildFabMenuItem(
                    icon: Icons.person_search_rounded,
                    label: 'Manajemen Pasien',
                    onTap: () => Navigator.pushNamed(context, '/admin/patients'),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'main_admin_fab',
                    onPressed: _toggleFabMenu,
                    backgroundColor: AppTheme.primaryColor,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        _isFabOpen ? Icons.close_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
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

    if ((confirm ?? false) && context.mounted) {
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
}
