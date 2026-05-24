import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchQueues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Absensi Pasien')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScanner(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('SCAN QR', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          final pendingQueues = provider.queues.where((q) => q.status == QueueStatus.booked).toList();

          if (provider.isLoading && pendingQueues.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pendingQueues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.green[200]),
                  const SizedBox(height: 16),
                  const Text('Semua pasien sudah diabsen atau belum ada antrean.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchQueues,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: pendingQueues.length,
              itemBuilder: (context, index) {
                final q = pendingQueues[index];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: Text(q.queueNumber, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(q.patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(q.polyclinic.name),
                      trailing: ElevatedButton(
                        onPressed: () => _processCheckIn(q.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('CHECK-IN'),
                      ),
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

  void _openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    ).then((_) {
      if (!context.mounted) return;
      context.read<AdminProvider>().fetchQueues();
    });
  }

  Future<void> _processCheckIn(int queueId) async {
    final provider = context.read<AdminProvider>();
    try {
      await provider.checkInQueue(queueId);
      if (mounted) {
        if (provider.error == null) {
          AppDialogs.showNotificationDialog(
            context,
            'Berhasil',
            'Berhasil Check-in! Status pasien diubah menjadi MENUNGGU.',
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
      if (mounted) {
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
