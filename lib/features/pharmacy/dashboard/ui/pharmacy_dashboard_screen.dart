import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../logic/pharmacy_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../prescription/ui/prescription_detail_screen.dart';
import '../../inventory/ui/medicine_inventory_screen.dart';
import '../../../auth/logic/auth_provider.dart';
import '../widgets/pharmacy_queue_card.dart';

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
            child: ResponsiveCenter(
              maxWidth: 950,
              child: Column(
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      color: Colors.white,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: ResponsiveCenter(
                            maxWidth: 950,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Navigator.pushNamed(context, '/pharmacy/profile'),
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
                                                  _getGreeting(),
                                                  style: GoogleFonts.inter(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  user?.name ?? 'Apoteker',
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
                                const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(ResponsiveHelper.radiusCard(context)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.radiusCard(context)),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -24,
                                  bottom: -24,
                                  child: Icon(
                                    Icons.local_pharmacy_rounded,
                                    size: 140,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(ResponsiveHelper.paddingCard(context)),
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
                                              fontSize: ResponsiveHelper.fontSizeCaption(context),
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(ResponsiveHelper.radiusSmall(context)),
                                            ),
                                            child: Text(
                                              'ONLINE',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: ResponsiveHelper.fontSizeCaption(context) - 2,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        provider.queues.isEmpty ? 'Semua Resep Selesai' : 'Antrean Resep Aktif',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: ResponsiveHelper.fontSizeHeading(context) + 4,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 60.0),
                                        child: Text(
                                          provider.queues.isEmpty
                                              ? 'Tidak ada antrean resep aktif saat ini. Semua obat telah berhasil diserahkan.'
                                              : 'Terdapat ${provider.queues.length} antrean resep terkonfirmasi lunas yang siap disiapkan untuk pasien hari ini.',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            fontSize: ResponsiveHelper.fontSizeBody(context),
                                            height: 1.5,
                                          ),
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

                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                        verticalOffset: 45.0,
                                        child: FadeInAnimation(
                                          child: PharmacyQueueCard(
                                            payment: payment,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PrescriptionDetailScreen(payment: payment),
                                                ),
                                              );
                                            },
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
      ),
        floatingActionButton: user?.role == 'pharmacist'
            ? FloatingActionButton.extended(
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
              )
            : null,
      ),
    );
  }
}
