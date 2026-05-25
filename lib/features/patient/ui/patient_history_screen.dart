import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../logic/patient_provider.dart';
import 'medical_record_detail_screen.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchMyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();
    final allHistory = provider.myQueues.where((q) => 
      q.status == QueueStatus.completed || q.status == QueueStatus.cancelled
    ).toList();

    // Grouping by Month (Simple logic for demonstration)
    final totalVisits = allHistory.length;
    final thisMonthVisits = allHistory.where((q) {
      // In real app, check created_at. For now, assume some are this month.
      return q.status == QueueStatus.completed; 
    }).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header Section
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Riwayat Antrean',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Daftar kunjungan puskesmas Anda',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primaryColor),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
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
                    // Stats Cards
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            _statCard('Total Kunjungan', totalVisits.toString(), 'kali'),
                            const SizedBox(width: 16),
                            _statCard('Bulan Ini', thisMonthVisits.toString(), 'kali'),
                          ],
                        ),
                      ),
                    ),

                    // History List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInLeft(
                            duration: const Duration(milliseconds: 500),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Aktivitas Terbaru',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Lihat Semua',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (provider.isLoading && allHistory.isEmpty)
                            const Center(child: CircularProgressIndicator())
                          else if (allHistory.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text('Belum ada riwayat antrean.', 
                                  style: TextStyle(color: Colors.grey.shade400)),
                              ),
                            )
                          else
                            ...allHistory.asMap().entries.map((entry) {
                              final index = entry.key;
                              final q = entry.value;
                              return FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(milliseconds: 100 * index),
                                child: _historyItem(q, provider.myExaminations),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(width: 4),
                Text(unit, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(QueueModel q, List<ExaminationModel> exams) {
    final dateStr = DateFormat('dd MMM yyyy • HH:mm').format(DateTime.now()); 
    
    // Find matching examination for this queue
    final examination = exams.cast<ExaminationModel?>().firstWhere(
      (e) => e?.queueId == q.id,
      orElse: () => null,
    );

    Color statusColor;
    Color statusBg;
    String statusLabel = q.status.value.toUpperCase();

    if (q.status == QueueStatus.completed) {
      statusColor = Colors.green;
      statusBg = Colors.green.withValues(alpha: 0.1);
      statusLabel = 'SELESAI';
    } else {
      statusColor = Colors.red;
      statusBg = Colors.red.withValues(alpha: 0.1);
      statusLabel = 'DIBATALKAN';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalRecordDetailScreen(
              queue: q,
              examination: examination,
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
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history_rounded, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text(q.polyclinic.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('No. Antrean: ${q.queueNumber}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
