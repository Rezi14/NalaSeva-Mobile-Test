import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../logic/patient_provider.dart';
import 'medical_record_detail_screen.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../core/theme/app_theme.dart';

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
        return exams.where((e) {
          final d = e.createdAt;
          return d != null && d.year == now.year && d.month == now.month;
        }).toList();
      case '3 Bulan':
        final cutoff = now.subtract(const Duration(days: 90));
        return exams.where((e) => e.createdAt != null && e.createdAt!.isAfter(cutoff)).toList();
      case '6 Bulan':
        final cutoff = now.subtract(const Duration(days: 180));
        return exams.where((e) => e.createdAt != null && e.createdAt!.isAfter(cutoff)).toList();
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
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Premium Header — single-line, no filter button
          FadeIn(
            duration: const Duration(milliseconds: 400),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Riwayat Rekam Medis',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Daftar rekam medis Anda',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
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

          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.fetchMyData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Stat cards
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

                    // Filter chips — below header, not in header
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final f = _filters[i];
                              final isActive = _selectedFilter == f;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedFilter = f),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade200,
                                    ),
                                    boxShadow: isActive
                                        ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))]
                                        : [],
                                  ),
                                  child: Text(
                                    f,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? Colors.white : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // List header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Rekam Medis',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              '${allExams.length} catatan',
                              style: GoogleFonts.inter(
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
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : allExams.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.grey.shade100,
                                        child: Icon(Icons.medical_information_rounded, size: 40, color: Colors.grey.shade400),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada rekam medis',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rekam medis akan muncul setelah\nAnda selesai menjalani pemeriksaan.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey.shade400,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : AnimationLimiter(
                                  child: Column(
                                    children: AnimationConfiguration.toStaggeredList(
                                      duration: const Duration(milliseconds: 450),
                                      childAnimationBuilder: (widget) => SlideAnimation(
                                        verticalOffset: 40.0,
                                        child: FadeInAnimation(child: widget),
                                      ),
                                      children: allExams.asMap().entries.map((entry) {
                                        return _recordCard(entry.value, provider.myQueues);
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
    );
  }

  Widget _statCard(String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
                    style: GoogleFonts.plusJakartaSans(
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: GoogleFonts.plusJakartaSans(
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

  Widget _recordCard(ExaminationModel exam, List<QueueModel> queues) {
    final queue = queues.cast<QueueModel?>().firstWhere(
      (q) => q?.id == exam.queueId,
      orElse: () => null,
    );
    final dateStr = exam.createdAt != null
        ? DateFormat('dd MMM yyyy').format(exam.createdAt!.toLocal())
        : '-';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalRecordDetailScreen(
              queue: queue,
              examination: exam,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.medical_information_rounded, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exam.diagnosis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dr. ${exam.doctorName}',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
