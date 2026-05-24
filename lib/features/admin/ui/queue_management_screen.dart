import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import 'admin_booking_detail_screen.dart';
import '../widgets/admin_mini_stat_card.dart';
import '../widgets/admin_patient_card.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchQueues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    
    final filteredQueues = provider.queues.where((q) => 
      q.patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      q.queueNumber.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    final total = provider.queues.length;
    final served = provider.queues.where((q) => q.status == QueueStatus.completed).length;
    final waiting = provider.queues.where((q) => q.status == QueueStatus.waiting).length;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Header
            FadeInDown(
              duration: const Duration(milliseconds: 600),
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Patient Directory',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "Manage today's registered patients",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.filter_list_rounded, color: AppTheme.primaryColor, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) => setState(() => _searchQuery = val),
                                    decoration: const InputDecoration(
                                      hintText: 'Search name or ID...',
                                      border: InputBorder.none,
                                      icon: Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Icon(Icons.tune_rounded, color: Colors.black87, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1),

            // Stats row
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    AdminMiniStatCard(label: 'Total', value: total.toString(), bgColor: Colors.white, textColor: Colors.black87, border: true),
                    const SizedBox(width: 12),
                    AdminMiniStatCard(label: 'Served', value: served.toString(), bgColor: Colors.green.withValues(alpha: 0.1), textColor: Colors.green),
                    const SizedBox(width: 12),
                    AdminMiniStatCard(label: 'Waiting', value: waiting.toString(), bgColor: Colors.orange.withValues(alpha: 0.1), textColor: Colors.orange),
                  ],
                ),
              ),
            ),

            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.fetchQueues,
                child: provider.isLoading && provider.queues.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInLeft(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 600),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                              child: Text(
                                'Recent Registrations',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: filteredQueues.length,
                              itemBuilder: (context, index) {
                                final q = filteredQueues[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 500),
                                    delay: Duration(milliseconds: 100 * index),
                                    child: AdminPatientCard(
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
                                    ),
                                  );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Export Button
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppDialogs.showNotificationDialog(
                      context,
                      'Berhasil',
                      'Laporan pasien hari ini berhasil diekspor (PDF/CSV)',
                    );
                  },
                  icon: const Icon(Icons.description_rounded, size: 18),
                  label: const Text('Export Patient Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
