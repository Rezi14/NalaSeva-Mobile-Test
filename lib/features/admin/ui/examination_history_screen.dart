import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../logic/admin_provider.dart';
import '../../../core/theme/app_theme.dart';

class ExaminationHistoryScreen extends StatefulWidget {
  const ExaminationHistoryScreen({super.key});

  @override
  State<ExaminationHistoryScreen> createState() => _ExaminationHistoryScreenState();
}

class _ExaminationHistoryScreenState extends State<ExaminationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchExaminations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Riwayat Pemeriksaan')),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.examinations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.examinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Belum ada riwayat pemeriksaan', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchExaminations,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.examinations.length,
              itemBuilder: (context, index) {
                final examination = provider.examinations[index];
                final date = DateFormat('dd MMM yyyy, HH:mm').format(examination.createdAt?.toLocal() ?? DateTime.now());

                return FadeInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Selesai',
                                style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Pasien: ${examination.patientName}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.medical_services_outlined, size: 16, color: AppTheme.secondaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Dokter: ${examination.doctorName}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Diagnosis:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(examination.diagnosis),
                        const SizedBox(height: 8),
                        const Text(
                          'Tindakan:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(examination.treatment),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
