import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard Apotek Puskesmas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            tooltip: 'Kelola Stok & Harga Obat',
            icon: const Icon(Icons.inventory_2_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicineInventoryScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'TV Monitor Antrean',
            icon: const Icon(Icons.tv_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/tv-monitor');
            },
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PharmacyProvider>().fetchPharmacyQueues(),
        child: Consumer<PharmacyProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.queues.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.fetchPharmacyQueues(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.queues.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty_rounded, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada antrean resep obat aktif hari ini',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Info Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Bekerja, ${user?.name ?? "Apoteker"}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Terdapat ${provider.queues.length} antrean resep obat terkonfirmasi lunas yang siap disiapkan.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daftar Antrean Resep',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Lists of Active Prescription Queues
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: provider.queues.length,
                        itemBuilder: (context, index) {
                          final payment = provider.queues[index];
                          final patientName = payment.queue?.patient.name ?? 'Pasien';
                          final polyCode = payment.queue?.polyclinic.code ?? 'UMM';
                          final polyName = payment.queue?.polyclinic.name ?? 'Poli';
                          final isPriority = payment.queue?.patient.isElderly ?? false;

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 450),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                    border: isPriority
                                        ? Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1.5)
                                        : null,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: isPriority
                                          ? Colors.orange.withValues(alpha: 0.1)
                                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                                      radius: 26,
                                      child: Text(
                                        polyCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isPriority ? Colors.orange : AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            patientName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (isPriority)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Lansia',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Pemeriksaan di: $polyName'),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Tagihan: ${payment.transactionNumber}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
