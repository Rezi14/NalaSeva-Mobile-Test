import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../logic/patient_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/info_row_item.dart';
import '../widgets/ticket_cutout.dart';
import '../widgets/ticket_stat_item.dart';

class BookingDetailScreen extends StatelessWidget {
  final QueueModel queue;

  const BookingDetailScreen({
    super.key,
    required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic queue position and estimation based on actual queue number from DB
    int queuePosition = 3;
    int avgTimeMultiplier = queue.avgWaitingTime ?? 15;
    int estimatedTime = 15;
    
    if (queue.status == QueueStatus.examining) {
      queuePosition = 0;
      estimatedTime = 0;
    } else if (queue.status == QueueStatus.completed || queue.status == QueueStatus.cancelled) {
      queuePosition = 0;
      estimatedTime = 0;
    } else {
      if (queue.positionWaiting != null) {
        queuePosition = queue.positionWaiting!;
      } else {
        final match = RegExp(r'\d+').firstMatch(queue.queueNumber);
        if (match != null) {
          final numVal = int.tryParse(match.group(0) ?? '');
          if (numVal != null) {
            queuePosition = (numVal - 1).clamp(0, numVal);
          }
        }
      }
      estimatedTime = queuePosition * avgTimeMultiplier;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Premium Header with smooth bottom-up stagger
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tiket Antrean',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Detail dan kartu akses antrean Anda',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.share_rounded, color: AppTheme.primaryColor, size: 20),
                                    ),
                                  ),
                                ],
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Digital Ticket Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top Part (Hospital Info)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.05),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.local_hospital_rounded, color: AppTheme.primaryColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Puskesmas Sehat Utama',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Jl. Kesehatan No. 123',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: queue.status),
                              ],
                            ),
                          ),
                          const TicketCutout(),

                          // Middle Part (Queue Info)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Text(
                                  'Nomor Antrean Anda',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  queue.queueNumber,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  queue.polyclinic.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(2), // For solid border effect
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: AppTheme.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                children: [
                                  QrImageView(
                                    data: 'NALASEVA_QUEUE_${queue.id}',
                                    version: QrVersions.auto,
                                    size: 180.0,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: QrEyeShape.circle,
                                      color: AppTheme.primaryColor,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.circle,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tunjukkan QR ini pada petugas pendaftaran',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Wait Stats
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                TicketStatItem(
                                  label: 'Posisi Antrean', 
                                  value: queue.status == QueueStatus.examining
                                      ? 'Sekarang'
                                      : '$queuePosition', 
                                  unit: queue.status == QueueStatus.examining
                                      ? 'pemeriksaan'
                                      : 'orang lagi'
                                ),
                                Container(width: 1, height: 60, color: Colors.grey.shade200),
                                TicketStatItem(
                                  label: 'Estimasi Pelayanan', 
                                  value: queue.status == QueueStatus.examining
                                      ? 'Sekarang'
                                      : (queue.estimatedServiceTime != null && queue.estimatedServiceTime!.length >= 5
                                          ? queue.estimatedServiceTime!.substring(0, 5) 
                                          : (queue.estimatedServiceTime ?? '$estimatedTime')), 
                                  unit: queue.status == QueueStatus.examining
                                      ? 'pemeriksaan'
                                      : (queue.estimatedServiceTime != null ? 'WIB' : 'menit'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Detail Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Text(
                            'Detail Kunjungan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              InfoRowItem(icon: Icons.person_rounded, label: 'Nama Pasien', value: queue.patient.name),
                              const Divider(height: 24),
                              InfoRowItem(icon: Icons.badge_rounded, label: 'NIK', value: queue.patient.nationalId ?? '-'),
                              const Divider(height: 24),
                              InfoRowItem(icon: Icons.calendar_today_rounded, label: 'Tanggal', value: queue.date),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Warning Box
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_rounded, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Harap datang 15 menit sebelum waktu estimasi. Antrean dapat hangus jika nomor terlewat 3 kali panggilan.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.red.shade800,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      children: [

                        TextButton(
                          onPressed: () => _showCancelConfirmation(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Text('Batalkan Antrean'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Batalkan Antrean?',
      'Apakah Anda yakin ingin membatalkan antrean ini? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'YA, BATALKAN',
      isDestructive: true,
    );

    if (confirm == true && context.mounted) {
      final provider = context.read<PatientProvider>();
      await provider.cancelQueue(queue.id);
      
      if (!context.mounted) return;
      
      if (provider.error != null) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal',
          provider.error!,
          isError: true,
        );
      } else {
        Navigator.pop(context); // Go back to dashboard
        AppDialogs.showNotificationDialog(
          context,
          'Berhasil',
          'Antrean berhasil dibatalkan',
        );
      }
    }
  }

}
