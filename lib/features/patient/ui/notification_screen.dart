import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../logic/patient_provider.dart';
// import '../../../shared/models/queue_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _activeFilter = 'Semua';

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
    final activeQueues = provider.myQueues.where((q) => 
        q.status != QueueStatus.completed && q.status != QueueStatus.cancelled).toList();
    final completedQueues = provider.myQueues.where((q) => 
        q.status == QueueStatus.completed).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => provider.fetchMyData(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
        elevation: 4,
        label: Text(
          'Refresh',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notifikasi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Pantau antrean & jadwal Anda',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.done_all_rounded, color: AppTheme.primaryColor),
                            onPressed: () {},
                            tooltip: 'Tandai semua dibaca',
                          ),
                        ],
                      ),
                    ),
                    
                    // Filter Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Row(
                        children: [
                          _filterChip('Semua', Icons.check_rounded),
                          _filterChip('Antrean', null),
                          _filterChip('Poli Umum', null),
                          _filterChip('Informasi', null),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child: provider.isLoading && provider.myQueues.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (activeQueues.isEmpty && completedQueues.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text('Tidak ada notifikasi baru.', 
                              style: TextStyle(color: Colors.grey.shade400)),
                          ),
                        ),

                      // Active Queues Notifications
                      ...activeQueues.asMap().entries.map((entry) {
                        final index = entry.key;
                        final q = entry.value;
                        return FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: Duration(milliseconds: 100 * index),
                          child: _notificationItem(
                            title: 'Antrean Aktif',
                            message: 'Pendaftaran Anda di ${q.polyclinic.name} telah dikonfirmasi. Nomor antrean: ${q.queueNumber}.',
                            time: 'Baru saja',
                            type: 'update',
                            actionLabel: 'Lihat Tiket',
                            onAction: () => Navigator.pushNamed(context, '/patient/home'),
                          ),
                        );
                      }),

                      // Completed Queues Notifications
                      ...completedQueues.asMap().entries.map((entry) {
                        final index = entry.key;
                        final q = entry.value;
                        return FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: Duration(milliseconds: 100 * (activeQueues.length + index)),
                          child: _notificationItem(
                            title: 'Layanan Selesai',
                            message: 'Pemeriksaan Anda di ${q.polyclinic.name} telah selesai. Semoga lekas sembuh!',
                            time: 'Hari ini',
                            type: 'success',
                            actionLabel: 'Lihat Detail',
                            onAction: () => Navigator.pushNamed(context, '/patient/history'),
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      FadeInLeft(
                        child: Text(
                          'Saran Kesehatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: _notificationItem(
                          title: 'Tips Kesehatan',
                          message: 'Jangan lupa minum air putih minimal 8 gelas sehari untuk menjaga hidrasi tubuh.',
                          time: '1 hari lalu',
                          type: 'update',
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData? icon) {
    bool isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isActive ? Colors.white : Colors.black87),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem({
    required String title,
    required String message,
    required String time,
    required String type,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    IconData icon;
    Color color;
    switch (type) {
      case 'success':
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'alert':
        icon = Icons.error_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppTheme.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onAction ?? () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

