import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../logic/patient_provider.dart';
import 'medical_record_detail_screen.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../shared/models/examination_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../payment/ui/patient_payment_list_screen.dart';
import '../widgets/patient_history_card.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Bulan Ini', '3 Bulan', '6 Bulan'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchMyData();
    });
  }

  List<ExaminationModel> _applyFilter(List<ExaminationModel> exams) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Bulan Ini':
        return exams
            .where((e) =>
                e.createdAt != null &&
                e.createdAt!.year == now.year &&
                e.createdAt!.month == now.month)
            .toList();
      case '3 Bulan':
        final cutoff = now.subtract(const Duration(days: 90));
        return exams
            .where((e) => e.createdAt != null && e.createdAt!.isAfter(cutoff))
            .toList();
      case '6 Bulan':
        final cutoff = now.subtract(const Duration(days: 180));
        return exams
            .where((e) => e.createdAt != null && e.createdAt!.isAfter(cutoff))
            .toList();
      default:
        return exams;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();
    final allExams = _applyFilter(provider.medicalRecords);
    final thisMonthCount = provider.medicalRecords.where((e) {
      final d = e.createdAt;
      final now = DateTime.now();
      return d != null && d.year == now.year && d.month == now.month;
    }).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            FadeIn(
              duration: const Duration(milliseconds: 400),
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
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Riwayat Rekam Medis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Daftar rekam medis Anda',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final f = _filters[i];
                              final isActive = _selectedFilter == f;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedFilter = f),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    f,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? AppTheme.primaryColor
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.fetchMyData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Row(
                            children: [
                              _statCard(
                                'Total Rekam Medis',
                                provider.medicalRecords.length.toString(),
                                'kali',
                                Icons.medical_information_rounded,
                                AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 16),
                              _statCard(
                                'Bulan Ini',
                                thisMonthCount.toString(),
                                'kali',
                                Icons.calendar_month_rounded,
                                AppTheme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                'Rekam Medis',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                '${allExams.length} catatan',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Records list
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: provider.isLoading && allExams.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(top: 60),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              )
                            : allExams.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.05),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.medical_information_rounded,
                                            size: 48,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Belum ada rekam medis',
                                          style: GoogleFonts.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Rekam medis akan muncul setelah\nAnda selesai menjalani pemeriksaan.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : AnimationLimiter(
                                    child: Column(
                                      children: AnimationConfiguration
                                          .toStaggeredList(
                                        duration: const Duration(
                                            milliseconds: 450),
                                        childAnimationBuilder: (widget) =>
                                            SlideAnimation(
                                          verticalOffset: 40.0,
                                          child: FadeInAnimation(
                                              child: widget),
                                        ),
                                        children: allExams
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final exam = entry.value;
                                          final queue = provider.myQueues
                                              .cast<QueueModel?>()
                                              .firstWhere(
                                                (q) => q?.id == exam.queueId,
                                                orElse: () => null,
                                              );
                                          return PatientHistoryCard(
                                            examination: exam,
                                            queues: provider.myQueues,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MedicalRecordDetailScreen(
                                                    queue: queue,
                                                    examination: exam,
                                                  ),
                                                ),
                                              );
                                            },
                                            onViewBills: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PatientPaymentListScreen(),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
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
    );
  }

  Widget _statCard(String label, String value, String unit, IconData icon,
      Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDCEEE7)),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}