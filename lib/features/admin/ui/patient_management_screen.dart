import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../widgets/admin_patient_card.dart';
import 'admin_booking_detail_screen.dart';
import '../widgets/qr_scanner_page.dart';
import 'package:animate_do/animate_do.dart';
import '../../../shared/widgets/staggered_list_animator.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
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

    // Filter booked/waiting queues based on status
    final bookedQueues = provider.queues.where((q) {
      final isBooked = q.status == QueueStatus.booked;
      final matchesSearch = q.patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.queueNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      return isBooked && matchesSearch;
    }).toList();

    final waitingQueues = provider.queues.where((q) {
      final isWaiting = q.status == QueueStatus.waiting;
      final matchesSearch = q.patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.queueNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      return isWaiting && matchesSearch;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openScanner(context),
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
            ),
            label: Text(
              'SCAN ABSENSI',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: Column(
            children: [
              // Safe Native Premium Header
              Container(
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
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                 Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Manajemen Pasien',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Kelola kehadiran dan verifikasi antrean loket',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 100),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari nama pasien atau nomor antrean...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Premium Custom TabBar
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 200),
                          child: TabBar(
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey.shade500,
                            indicatorColor: AppTheme.primaryColor,
                            indicatorWeight: 3,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Dipesan'),
                                    if (bookedQueues.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          bookedQueues.length.toString(),
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppTheme.primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Menunggu'),
                                    if (waitingQueues.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          waitingQueues.length.toString(),
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.green.shade700,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
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

              const Divider(height: 1),

              // TabBarView content lists
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Booked/Dipesan Queues List
                    RefreshIndicator(
                      onRefresh: provider.fetchQueues,
                      child: provider.isLoading && provider.queues.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                if (provider.error != null) _errorCard(provider.error!),
                                const SizedBox(height: 12),
                                bookedQueues.isEmpty
                                    ? _emptyState(
                                        title: 'Semua Pasien Sudah Absen',
                                        description: _searchQuery.isNotEmpty
                                            ? 'Tidak ada antrean terbooking yang cocok dengan pencarian Anda.'
                                            : 'Tidak ada data pendaftaran dengan status dipesan yang tersedia.',
                                      )
                                    : StaggeredListAnimator(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        itemCount: bookedQueues.length,
                                        itemBuilder: (context, index) {
                                          try {
                                            final q = bookedQueues[index];
                                            return AdminPatientCard(
                                              queue: q,
                                              showCheckIn: false,
                                              onTap: () => _goToDetail(context, q),
                                            );
                                          } catch (e, stack) {
                                            return _renderErrorCard(e, stack);
                                          }
                                        },
                                      ),
                              ],
                            ),
                    ),

                    // Tab 2: Waiting/Menunggu (Checked-In) Queues List
                    RefreshIndicator(
                      onRefresh: provider.fetchQueues,
                      child: provider.isLoading && provider.queues.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                if (provider.error != null) _errorCard(provider.error!),
                                const SizedBox(height: 12),
                                waitingQueues.isEmpty
                                    ? _emptyState(
                                        title: 'Belum Ada Pasien Check-In',
                                        description: _searchQuery.isNotEmpty
                                            ? 'Tidak ada pasien yang cocok dengan pencarian Anda.'
                                            : 'Belum ada pasien yang melakukan absensi / check-in saat ini.',
                                      )
                                    : StaggeredListAnimator(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        itemCount: waitingQueues.length,
                                        itemBuilder: (context, index) {
                                          try {
                                            final q = waitingQueues[index];
                                            return AdminPatientCard(
                                              queue: q,
                                              showCheckIn: false,
                                              onTap: () => _goToDetail(context, q),
                                            );
                                          } catch (e, stack) {
                                            return _renderErrorCard(e, stack);
                                          }
                                        },
                                      ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) {
    final provider = context.read<AdminProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    ).then((_) {
      if (!context.mounted) return;
      provider.fetchQueues();
    });
  }

  void _goToDetail(BuildContext context, dynamic q) {
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
  }



  Widget _errorCard(String error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderErrorCard(dynamic e, dynamic stack) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        'Error rendering item: $e\n$stack',
        style: const TextStyle(color: Colors.red, fontSize: 11),
      ),
    );
  }

  Widget _emptyState({required String title, required String description}) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 72,
                color: Colors.green.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
