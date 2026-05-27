import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/date_time_parser.dart';
import '../logic/patient_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/info_row_item.dart';
import '../widgets/ticket_cutout.dart';
import '../widgets/ticket_stat_item.dart';
import '../../../core/utils/app_logger.dart';

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
        final match = RegExp(r'(\d+)\u0000?\$').firstMatch(queue.queueNumber);
        if (match != null) {
          final numVal = int.tryParse(match.group(1) ?? '');
          if (numVal != null) {
              queuePosition = numVal > 0 ? numVal - 1 : 0;
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
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                          text: 'Puskesmas Sehat Utama - Tiket Antrean NalaSeva\n'
                                                'Nomor Antrean: ${queue.queueNumber}\n'
                                                'Poliklinik: ${queue.polyclinic.name}\n'
                                                'Nama Pasien: ${queue.patient.name}\n'
                                                'Tanggal Kunjungan: ${queue.date}\n'
                                                'Estimasi Jam Pelayanan: ${queue.estimatedServiceTime ?? "-"}\n'
                                                'Pindai QR Kode Anda langsung dari detail aplikasi!'
                                        ));
                                        AppDialogs.showNotificationDialog(
                                          context,
                                          'Tiket Disalin',
                                          'Detail tiket antrean Anda berhasil disalin ke papan klip untuk dibagikan!',
                                        );
                                      },
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
                              InfoRowItem(
                                icon: Icons.person_rounded, 
                                label: 'Nama Pasien', 
                                value: queue.patient.name + (queue.patient.isElderly ? ' (Lansia - Prioritas)' : ''),
                              ),
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

                  // Priority Banner (Tugas 5)
                  if (queue.patient.isElderly) ...[
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LAYANAN JALUR PRIORITAS (LANSIA)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pasien diidentifikasi masuk kategori prioritas khusus (Lansia). Silakan hubungi loket pendaftaran Puskesmas untuk verifikasi jalur antrean prioritas.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.amber.shade800,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

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
                        TextButton.icon(
                          onPressed: () => _showCancelConfirmation(context),
                          style: TextButton.styleFrom(
                            foregroundColor: _isCancellationLocked(queue) ? Colors.grey.shade500 : Colors.red,
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          icon: Icon(
                            _isCancellationLocked(queue) ? Icons.lock_clock_rounded : Icons.cancel_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _isCancellationLocked(queue) ? 'Pembatalan Dikunci (< 2 Jam)' : 'Batalkan Antrean',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  bool _isCancellationLocked(QueueModel queue) {
    if (queue.status == QueueStatus.completed || queue.status == QueueStatus.cancelled) {
      return true;
    }
    
    try {
      final dateOnly = DateTimeParser.parseDateOnly(queue.date);
      final minutesOfDay = DateTimeParser.parseMinutesOfDay(queue.estimatedServiceTime ?? '23:59');

      if (dateOnly != null && minutesOfDay != null) {
        final estimatedTime = DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          minutesOfDay ~/ 60,
          minutesOfDay % 60,
        );
        final now = DateTime.now();
        
        final difference = estimatedTime.difference(now);
        if (difference.inMinutes <= 120) {
          return true;
        }
      }
    } catch (e, stack) {
      AppLogger.error('Gagal memeriksa status kunci pembatalan tiket antrean', error: e, stackTrace: stack, tag: 'BookingDetailScreen');
      return true;
    }
    
    return false;
  }

  void _showCancelConfirmation(BuildContext context) async {
    if (_isCancellationLocked(queue)) {
      AppDialogs.showNotificationDialog(
        context,
        'Pembatalan Ditutup',
        'Pembatalan mandiri tidak diizinkan kurang dari 2 jam sebelum estimasi waktu pelayanan. Silakan hubungi loket pelayanan Puskesmas.',
        isError: true,
      );
      return;
    }

    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Batalkan Antrean?',
      'Apakah Anda yakin ingin membatalkan antrean ini? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'YA, BATALKAN',
      isDestructive: true,
    );

    if ((confirm ?? false) && context.mounted) {
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
