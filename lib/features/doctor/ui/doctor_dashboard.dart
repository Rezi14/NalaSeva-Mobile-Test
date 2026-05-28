import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../auth/logic/auth_provider.dart';
import '../logic/doctor_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../widgets/doctor_stat_card.dart';
import '../widgets/doctor_welcome_card.dart';
import '../widgets/doctor_queue_tile.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  bool _statusSynced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DoctorProvider>();
      provider.fetchMyQueues();
      provider.fetchMedicalRecords();
      provider.addListener(_onProviderError);
      
      final authProvider = context.read<AuthProvider>();
      authProvider.checkAuth().then((_) {
        if (mounted) {
          final user = authProvider.user;
          if (user != null && user.role == 'doctor' && user.isOnline != null) {
            provider.setOnlineStatus(user.isOnline!);
            _statusSynced = true;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    context.read<DoctorProvider>().removeListener(_onProviderError);
    super.dispose();
  }

  void _onProviderError() {
    final error = context.read<DoctorProvider>().error;
    if (error != null && mounted) {
      AppDialogs.showNotificationDialog(
        context,
        'Terjadi Kesalahan',
        error,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<DoctorProvider>();

    if (user != null && user.role == 'doctor' && user.isOnline != null && !_statusSynced) {
      _statusSynced = true;
      final doctorProvider = context.read<DoctorProvider>();
      Future.microtask(() {
        if (mounted) {
          doctorProvider.setOnlineStatus(user.isOnline!);
        }
      });
    }

    final initials = (user?.name ?? '').isNotEmpty
      ? user!.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
      : 'DR';

    final myQueues = provider.queues.where((q) => q.doctorId == user?.doctorId).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Premium Header
          FadeIn(
            duration: const Duration(milliseconds: 500),
            child: Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, '/doctor/profile'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Portal Dokter',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey.shade500,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user?.name ?? 'Dokter',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pushNamed(context, '/doctor/profile'),
                          icon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryColor),
                          tooltip: 'Profil Saya',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const Divider(height: 1),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final authProvider = context.read<AuthProvider>();
                await Future.wait([
                  provider.fetchMyQueues(),
                  provider.fetchMedicalRecords(),
                  authProvider.checkAuth(),
                ]);
                final user = authProvider.user;
                if (user != null && user.role == 'doctor' && user.isOnline != null) {
                  provider.setOnlineStatus(user.isOnline!);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Active Toggle Status Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 100),
                      child: DoctorWelcomeCard(
                        doctorName: user?.name ?? 'Dokter',
                        isOnline: provider.isOnline,
                        onToggleOnline: provider.toggleOnlineStatus,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: _buildStatsRow(myQueues),
                    ),
                    const SizedBox(height: 24),

                    // Queue section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Antrean Aktif Saat Ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await Future.wait([
                              provider.fetchMyQueues(),
                              provider.fetchMedicalRecords(),
                            ]);
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.primaryColor),
                          label: Text(
                            'Refresh',
                            style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildQueueList(provider, myQueues),
                    const SizedBox(height: 32),

                    // Analytics Chart (Kunjungan Pasien)
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: _buildAnalyticsChart(provider.medicalRecords),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<QueueModel> myQueues) {
    final completedCount = myQueues.where((q) => q.status == QueueStatus.completed).length;
    final activeCount = myQueues.where((q) => q.status == QueueStatus.waiting || q.status == QueueStatus.examining).length;

    return Row(
      children: [
        Expanded(
          child: DoctorStatCard(
            label: 'Aktif',
            value: '$activeCount',
            icon: Icons.people_outline_rounded,
            color: AppTheme.primaryColor,
            bgColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DoctorStatCard(
            label: 'Selesai',
            value: '$completedCount',
            icon: Icons.task_alt_rounded,
            color: AppTheme.successColor,
            bgColor: AppTheme.successColor.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DoctorStatCard(
            label: 'Total',
            value: '${myQueues.length}',
            icon: Icons.analytics_outlined,
            color: AppTheme.accentColor,
            bgColor: AppTheme.accentColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsChart(List<ExaminationModel> medicalRecords) {
    final List<double> weekdayCounts = List.filled(7, 0.0);
    final now = DateTime.now();
    // Monday of the current week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    // Sunday of the current week (inclusive)
    final endOfWeekOnly = startOfWeekOnly.add(const Duration(days: 7));

    for (var exam in medicalRecords) {
      final parsedDate = exam.createdAt;
      if (parsedDate != null) {
        final dateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        if (dateOnly.isAtSameMomentAs(startOfWeekOnly) || 
            (dateOnly.isAfter(startOfWeekOnly) && dateOnly.isBefore(endOfWeekOnly))) {
          final weekdayIndex = parsedDate.weekday - 1; // 0 (Mon) to 6 (Sun)
          if (weekdayIndex >= 0 && weekdayIndex < 7) {
            weekdayCounts[weekdayIndex] += 1.0;
          }
        }
      }
    }
    final List<double> finalCounts = weekdayCounts;
    final double maxVal = finalCounts.reduce((a, b) => a > b ? a : b);
    final double dynamicMaxY = maxVal > 5 ? (maxVal * 1.25).ceilToDouble() : 10.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kunjungan Pasien',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Mingguan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.assessment_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: dynamicMaxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.primaryColor.withValues(alpha: 0.95),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} Pasien',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, finalCounts[0]),
                  _makeGroupData(1, finalCounts[1]),
                  _makeGroupData(2, finalCounts[2]),
                  _makeGroupData(3, finalCounts[3]),
                  _makeGroupData(4, finalCounts[4]),
                  _makeGroupData(5, finalCounts[5]),
                  _makeGroupData(6, finalCounts[6]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryColor,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildQueueList(DoctorProvider provider, List<QueueModel> myQueues) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final queues = myQueues.where((q) => q.status == QueueStatus.examining).toList();
    
    if (queues.isEmpty) {
      return FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade100,
                child: Icon(Icons.people_alt_rounded, size: 40, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada antrean aktif saat ini',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Semua pasien hari ini telah selesai dilayani.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: queues.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final q = queues[index];

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: DoctorQueueTile(
                  queue: q,
                  onExamine: () => _navigateToExamination(q),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToExamination(QueueModel queue) {
    Navigator.pushNamed(context, '/doctor/examination', arguments: queue);
  }
}
