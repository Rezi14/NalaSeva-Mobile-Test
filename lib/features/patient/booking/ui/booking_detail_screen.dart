import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/date_time_parser.dart';
import '../../logic/patient_provider.dart';
import '../../history/widgets/status_badge.dart';
import '../../profile/widgets/info_row_item.dart';
import '../widgets/ticket_cutout.dart';
import '../widgets/ticket_stat_item.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/providers/puskesmas_profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailScreen extends StatefulWidget {
  final QueueModel queue;

  const BookingDetailScreen({super.key, required this.queue});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        if (mounted) {
          await context.read<PatientProvider>().fetchMyQueues();
        }
      } catch (e) {
        // Silent error for background network issues
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myQueues = context.watch<PatientProvider>().myQueues;
    final queue = myQueues.firstWhere(
      (q) => q.id == widget.queue.id,
      orElse: () => widget.queue,
    );
    final puskesmasProfileProvider = context.watch<PuskesmasProfileProvider>();
    final puskesmasProfile = puskesmasProfileProvider.profile;
    final puskesmasName = puskesmasProfile?.name ?? 'Puskesmas Sehat Utama';
    final puskesmasAddress = puskesmasProfile?.address ?? 'Jl. Raya Sehat No. 12';

    // Calculate dynamic queue position and estimation based on actual queue number from DB
    int queuePosition = 3;
    int avgTimeMultiplier = queue.avgWaitingTime ?? 15;
    int estimatedTime = 15;

    if (queue.status == QueueStatus.examining) {
      queuePosition = 0;
      estimatedTime = 0;
    } else if (queue.status.isTerminal) {
      queuePosition = 0;
      estimatedTime = 0;
    } else {
      if (queue.positionWaiting != null) {
        queuePosition = queue.positionWaiting!;
      } else {
        final match = RegExp(r'(\d+)\u0000?$').firstMatch(queue.queueNumber);
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
      backgroundColor: Colors.white,
      body: ResponsiveCenter(
        maxWidth: 700,
        child: Column(
          children: [
            // Premium Header with smooth bottom-up stagger
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
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
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tiket Antrean',
                                              style: GoogleFonts.poppins(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Detail dan kartu akses antrean Anda',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.white.withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                            text: '$puskesmasName - Tiket Antrean NalaSeva\n'
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
                                        icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
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
              child: RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: () async {
                  try {
                    await context.read<PatientProvider>().fetchMyQueues();
                  } catch (e) {
                    // Silent catch
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Digital Ticket Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.backgroundGradient,
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
                                            'Tiket Antrean',
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Detail dan kartu akses antrean Anda',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          if (puskesmasProfile?.latitude != null && puskesmasProfile?.longitude != null) ...[
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () async {
                                                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${puskesmasProfile!.latitude},${puskesmasProfile.longitude}');
                                                try {
                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                                  } else {
                                                    // Try direct launch in case package visibility check fails on some devices
                                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                                  }
                                                } catch (e, stack) {
                                                  AppLogger.error('Gagal membuka petunjuk rute', error: e, stackTrace: stack, tag: 'BookingDetailScreen');
                                                }
                                              },
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.directions_rounded, color: AppTheme.primaryColor, size: 16),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Petunjuk Rute',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
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
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          queue.queueNumber,
                                          style: GoogleFonts.poppins(
                                            fontSize: 64,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      queue.polyclinic.name,
                                      style: GoogleFonts.poppins(
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
                                      Text(
                                        puskesmasName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        puskesmasAddress,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                       if (puskesmasProfile?.latitude != null && puskesmasProfile?.longitude != null) ...[
                                         const SizedBox(height: 8),
                                         InkWell(
                                           onTap: () async {
                                             final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${puskesmasProfile!.latitude},${puskesmasProfile.longitude}');
                                             try {
                                               if (await canLaunchUrl(url)) {
                                                 await launchUrl(url, mode: LaunchMode.externalApplication);
                                               } else {
                                                 // Try direct launch in case package visibility check fails on some devices
                                                 await launchUrl(url, mode: LaunchMode.externalApplication);
                                               }
                                             } catch (e, stack) {
                                               AppLogger.error('Gagal membuka petunjuk rute', error: e, stackTrace: stack, tag: 'BookingDetailScreen');
                                             }
                                           },
                                           borderRadius: BorderRadius.circular(20),
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                             decoration: BoxDecoration(
                                               color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                               borderRadius: BorderRadius.circular(20),
                                             ),
                                             child: Row(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 const Icon(Icons.directions_rounded, color: AppTheme.primaryColor, size: 16),
                                                 const SizedBox(width: 6),
                                                 Text(
                                                   'Petunjuk Rute',
                                                   style: GoogleFonts.poppins(
                                                     fontSize: 12,
                                                     fontWeight: FontWeight.bold,
                                                     color: AppTheme.primaryColor,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                       ],
                                    ],
                                  ),
                                ),
                              ),

                          // Middle Part (Queue Info)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Text(
                                  'Nomor Antrean Anda',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      queue.queueNumber,
                                      style: GoogleFonts.poppins(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  queue.polyclinic.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
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
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppTheme.backgroundGradient,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade100),
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
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
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
                          duration: const Duration(milliseconds: 700),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFE8F5E9).withValues(alpha: 0.9), // Emerald Light
                                  const Color(0xFFF1F8E9).withValues(alpha: 0.8), // Soft Light Mint
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFC5E1A5), // Mint Green border
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.amber.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber.shade800,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'LAYANAN PRIORITAS LANSIA',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF2E7D32), // Deep Emerald Green
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade800,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'GOLD',
                                              style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Pasien berhak mendapatkan kemudahan jalur antrean khusus NalaSeva (Jalur Prioritas Lansia). Silakan langsung verifikasi kehadiran Anda ke loket prioritas Puskesmas.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF388E3C), // Emerald Medium Green
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                                  style: GoogleFonts.poppins(
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
                              onPressed: _isCancellationLocked(queue) ? null : () => _showCancelConfirmation(context, queue),
                              style: TextButton.styleFrom(
                                foregroundColor: _isCancellationLocked(queue) ? Colors.grey.shade500 : Colors.red,
                                minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                              ),
                              icon: Icon(
                                _isCancellationLocked(queue) ? Icons.lock_clock_rounded : Icons.cancel_rounded,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'LAYANAN PRIORITAS LANSIA',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF2E7D32), // Deep Emerald Green
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade800,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'GOLD',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Pasien berhak mendapatkan kemudahan jalur antrean khusus NalaSeva (Jalur Prioritas Lansia). Silakan langsung verifikasi kehadiran Anda ke loket prioritas Puskesmas.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF388E3C), // Emerald Medium Green
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
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
                              style: GoogleFonts.poppins(
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
                          onPressed: _isCancellationLocked(queue) ? null : () => _showCancelConfirmation(context, queue),
                          style: TextButton.styleFrom(
                            foregroundColor: _isCancellationLocked(queue) ? Colors.grey.shade500 : Colors.red,
                            minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                          ),
                          icon: Icon(
                            _isCancellationLocked(queue) ? Icons.lock_clock_rounded : Icons.cancel_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _isCancellationLocked(queue) ? 'Pembatalan Dikunci (< 2 Jam)' : 'Batalkan Antrean',
                            style: GoogleFonts.poppins(
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
          ],
        ),
      ),
    );
  }

  bool _isCancellationLocked(QueueModel queue) {
    if (queue.status != QueueStatus.booked && queue.status != QueueStatus.waiting) {
      return true;
    }

    final now = DateTime.now();
    bool isGracePeriod = false;

    if (queue.createdAt != null) {
      final diff = now.difference(queue.createdAt!);
      if (diff.inMinutes <= 15) {
        isGracePeriod = true;
      }
    }

    try {
      final dateOnly = DateTimeParser.parseDateOnly(queue.date);
      final scheduleStartTime = queue.doctorSchedule?.startTime;

      if (scheduleStartTime == null || scheduleStartTime.isEmpty) {
        return !isGracePeriod; // Jika jadwal kosong, izinkan jika grace period, tapi asumsikan terkunci di luar grace period (atau false seperti aslinya, kita ikuti aslinya false)
      }

      final minutesOfDay = DateTimeParser.parseMinutesOfDay(scheduleStartTime);

      if (dateOnly != null && minutesOfDay != null) {
        final serviceTime = DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          minutesOfDay ~/ 60,
          minutesOfDay % 60,
        );

        // Aturan Backend 1: Jika waktu pelayanan sudah dimulai/terlewat, pembatalan DIKUNCI mutlak
        if (now.isAfter(serviceTime) || now.isAtSameMomentAs(serviceTime)) {
          return true;
        }

        // Aturan Backend 2: Jika masih dalam grace period 15 menit, dan belum waktu praktik, DIBUKA
        if (isGracePeriod) {
          return false;
        }

        // Aturan Backend 3: Jika di luar grace period, cek apakah jaraknya kurang dari 2 jam
        final difference = serviceTime.difference(now);
        if (difference.inMinutes <= 120) {
          return true;
        }
      } else if (isGracePeriod) {
        return false;
      }
    } catch (e, stack) {
      AppLogger.error('Gagal memeriksa status kunci pembatalan tiket antrean', error: e, stackTrace: stack, tag: 'BookingDetailScreen');
      return true;
    }

    return false;
  }

  void _showCancelConfirmation(BuildContext context, QueueModel queue) async {
    if (_isCancellationLocked(queue)) {
      AppDialogs.showNotificationDialog(
        context,
        'Pembatalan Ditutup',
        'Pembatalan mandiri tidak diizinkan kurang dari 2 jam sebelum jam mulai pelayanan. Silakan hubungi loket pelayanan Puskesmas.',
        isError: true,
      );
      return;
    }

    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Batalkan Antrean?',
      'Apakah Anda yakin ingin membatalkan antrean ini? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Batalkan',
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
