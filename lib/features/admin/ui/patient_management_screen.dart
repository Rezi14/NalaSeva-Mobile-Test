import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../logic/admin_provider.dart';
import '../widgets/qr_scanner_page.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';

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
    
    // Filter pending/booked queues that need check-in
    final pendingQueues = provider.queues.where((q) {
      final isBooked = q.status == QueueStatus.booked;
      final matchesSearch = q.patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.queueNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      return isBooked && matchesSearch;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        floatingActionButton: FadeInRight(
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
        body: Column(
          children: [
            // Premium Integrated Header with staggered entrance
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
                                            'Kelola kehadiran dan verifikasi antrean',
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
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimationConfiguration.staggeredList(
                            position: 1,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 30.0,
                              child: FadeInAnimation(
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
                                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
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

            const Divider(height: 1),

            // Content List or Empty State with waterfall stagger
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.fetchQueues,
                child: provider.isLoading && pendingQueues.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 200),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                              child: Text(
                                'Menunggu Check-In',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          if (pendingQueues.isEmpty)
                            Expanded(
                              child: FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: const Duration(milliseconds: 300),
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 40),
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
                                          'Semua Pasien Sudah Absen',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _searchQuery.isNotEmpty
                                              ? 'Tidak ada antrean terbooking yang cocok dengan pencarian Anda.'
                                              : 'Seluruh antrean hari ini telah berhasil check-in atau tidak ada pendaftaran baru.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: pendingQueues.length,
                                itemBuilder: (context, index) {
                                  final q = pendingQueues[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 500),
                                    delay: Duration(milliseconds: 300 + (index * 80)),
                                    child: Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      color: Colors.white,
                                      elevation: 0,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(16),
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                          child: Text(
                                            q.queueNumber,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          q.patient.fullName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 15,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              q.polyclinic.name,
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () => _processCheckIn(context, q.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            'ABSEN',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
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
          ],
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

  Future<void> _processCheckIn(BuildContext context, int queueId) async {
    final provider = context.read<AdminProvider>();
    try {
      await provider.checkInQueue(queueId);
      if (context.mounted) {
        if (provider.error == null) {
          AppDialogs.showNotificationDialog(
            context,
            'Berhasil',
            'Berhasil melakukan check-in! Status antrean pasien telah diubah menjadi MENUNGGU.',
          );
        } else {
          AppDialogs.showNotificationDialog(
            context,
            'Gagal',
            provider.error!,
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal',
          e.toString(),
          isError: true,
        );
      }
    }
  }
}
