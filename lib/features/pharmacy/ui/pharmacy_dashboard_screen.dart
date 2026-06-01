import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../logic/pharmacy_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'prescription_detail_screen.dart';
import 'medicine_inventory_screen.dart';
import '../../auth/logic/auth_provider.dart';

class PharmacyDashboardScreen extends StatefulWidget {
  const PharmacyDashboardScreen({super.key});

  @override
  State<PharmacyDashboardScreen> createState() => _PharmacyDashboardScreenState();
}

class _PharmacyDashboardScreenState extends State<PharmacyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmacyProvider>().fetchPharmacyQueues();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  LinearGradient _getPolyGradient(String code) {
    switch (code) {
      case 'POL-UMM':
        return const LinearGradient(
          colors: [Color(0xFF0F9B8E), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'POL-GIG':
        return const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'POL-KIA':
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'POL-ANK':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'POL-LNS':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF6B7280), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<PharmacyProvider>();
    
    final initials = (user?.name ?? '').isNotEmpty
        ? user!.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
        : 'AP';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: RefreshIndicator(
          onRefresh: () => context.read<PharmacyProvider>().fetchPharmacyQueues(),
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header Section - EXACTLY matching Patient Dashboard
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    color: Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, '/pharmacy/profile'),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: GoogleFonts.inter(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          user?.name ?? 'Apoteker',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Active Duty Info Card (Matching QueueStatusCard layout of patient)
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F9B8E), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F9B8E).withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'INFORMASI TUGAS',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'ONLINE',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Apotek Siaga',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Terdapat ${provider.queues.length} antrean resep terkonfirmasi lunas yang siap disiapkan untuk pasien hari ini.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Prescription List Section (Matching Active List style)
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Antrean Resep Hari Ini',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (provider.queues.isNotEmpty)
                                  Text(
                                    '${provider.queues.length} Antrean',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (provider.queues.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.checklist_rtl_rounded, size: 64, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Semua Resep Selesai!',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Tidak ada antrean resep obat aktif hari ini.',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              AnimationLimiter(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.queues.length,
                                  itemBuilder: (context, index) {
                                    final payment = provider.queues[index];
                                    final patientName = payment.queue?.patient.name ?? 'Pasien';
                                    final polyCode = payment.queue?.polyclinic.code ?? 'UMM';
                                    final polyName = payment.queue?.polyclinic.name ?? 'Poliklinik';
                                    final isPriority = payment.queue?.patient.isElderly ?? false;
                                    final itemsCount = payment.examination?.prescriptionItems.length ?? 0;

                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                        verticalOffset: 45.0,
                                        child: FadeInAnimation(
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.03),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                )
                                              ],
                                              border: Border.all(
                                                color: isPriority 
                                                    ? Colors.orange.withValues(alpha: 0.4) 
                                                    : Colors.grey.shade100,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(24),
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(24),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PrescriptionDetailScreen(payment: payment),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(18.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 56,
                                                        height: 56,
                                                        decoration: BoxDecoration(
                                                          gradient: _getPolyGradient(polyCode),
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          polyCode.split('-').last,
                                                          style: GoogleFonts.outfit(
                                                            fontWeight: FontWeight.w900,
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    patientName,
                                                                    style: GoogleFonts.outfit(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 16,
                                                                      color: Colors.black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (isPriority) ...[
                                                                  const SizedBox(width: 6),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.orange.withValues(alpha: 0.1),
                                                                      borderRadius: BorderRadius.circular(8),
                                                                    ),
                                                                    child: Text(
                                                                      'Lansia',
                                                                      style: GoogleFonts.plusJakartaSans(
                                                                        color: Colors.orange.shade700,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              polyName,
                                                              style: GoogleFonts.plusJakartaSans(
                                                                color: Colors.grey[600],
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Wrap(
                                                              spacing: 8,
                                                              runSpacing: 4,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                  decoration: BoxDecoration(
                                                                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Text(
                                                                    'Siap Disiapkan',
                                                                    style: GoogleFonts.plusJakartaSans(
                                                                      color: AppTheme.primaryColor,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 10,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.blue.withValues(alpha: 0.08),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Text(
                                                                    itemsCount > 0 ? '$itemsCount Resep' : 'Tanpa Obat',
                                                                    style: GoogleFonts.plusJakartaSans(
                                                                      color: Colors.blue.shade700,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade50,
                                                          shape: BoxShape.circle,
                                                          border: Border.all(color: Colors.grey.shade100),
                                                        ),
                                                        child: Icon(
                                                          Icons.chevron_right_rounded,
                                                          size: 20,
                                                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MedicineInventoryScreen()),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
          icon: const Icon(Icons.inventory_2_rounded, color: Colors.white),
          label: Text(
            'Kelola Obat',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
