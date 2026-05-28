import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../logic/patient_provider.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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

    final activeQueues = provider.myQueues
      .where((q) => q.status.isActive)
      .toList();
    final completedQueues = provider.myQueues
        .where((q) => q.status == QueueStatus.completed)
        .toList();
    final cancelledQueues = provider.myQueues
        .where((q) => q.status == QueueStatus.cancelled)
        .toList();

    final hasAnyData = activeQueues.isNotEmpty ||
        completedQueues.isNotEmpty ||
        cancelledQueues.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
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
                                    icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Notifikasi',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Pantau status antrean Anda',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
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

          // ── Body ────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.fetchMyData,
              color: AppTheme.primaryColor,
              child: provider.isLoading && provider.myQueues.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : !hasAnyData
                      ? _emptyState()
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                          child: AnimationLimiter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 400),
                                childAnimationBuilder: (widget) =>
                                    SlideAnimation(
                                  verticalOffset: 40.0,
                                  child: FadeInAnimation(child: widget),
                                ),
                                children: [
                                  // ── Antrean Aktif ──────────────
                                  if (activeQueues.isNotEmpty) ...[
                                    _sectionHeader(
                                      'Antrean Aktif',
                                      Icons.radio_button_checked_rounded,
                                      AppTheme.primaryColor,
                                      badge: activeQueues.length,
                                    ),
                                    const SizedBox(height: 12),
                                    ...activeQueues.map((q) => _notifCard(
                                          icon: Icons.confirmation_number_rounded,
                                          iconColor: AppTheme.primaryColor,
                                          title: _statusLabel(q.status),
                                          subtitle:
                                              '${q.polyclinic.name} · No. Antrean ${q.queueNumber}',
                                          message: _statusMessage(q.status, q.polyclinic.name, q.queueNumber),
                                          badge: _statusBadge(q.status),
                                          badgeColor: _statusColor(q.status),
                                          onTap: () => Navigator.pushNamed(
                                              context, '/patient/home'),
                                          actionLabel: 'Lihat Tiket',
                                        )),
                                    const SizedBox(height: 24),
                                  ],

                                  // ── Layanan Selesai ───────────
                                  if (completedQueues.isNotEmpty) ...[
                                    _sectionHeader(
                                      'Layanan Selesai',
                                      Icons.check_circle_rounded,
                                      Colors.green,
                                    ),
                                    const SizedBox(height: 12),
                                    ...completedQueues.map((q) => _notifCard(
                                          icon: Icons.check_circle_rounded,
                                          iconColor: Colors.green,
                                          title: 'Pemeriksaan Selesai',
                                          subtitle: q.polyclinic.name,
                                          message:
                                              'Pemeriksaan Anda di ${q.polyclinic.name} telah selesai. Semoga lekas sembuh!',
                                          badge: 'SELESAI',
                                          badgeColor: Colors.green,
                                          onTap: () => Navigator.pushNamed(
                                              context, '/patient/history'),
                                          actionLabel: 'Lihat Rekam Medis',
                                        )),
                                    const SizedBox(height: 24),
                                  ],

                                  // ── Dibatalkan ────────────────
                                  if (cancelledQueues.isNotEmpty) ...[
                                    _sectionHeader(
                                      'Dibatalkan',
                                      Icons.cancel_rounded,
                                      Colors.red.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    ...cancelledQueues.map((q) => _notifCard(
                                          icon: Icons.cancel_rounded,
                                          iconColor: Colors.red.shade400,
                                          title: 'Antrean Dibatalkan',
                                          subtitle: q.polyclinic.name,
                                          message:
                                              'Antrean Anda di ${q.polyclinic.name} (No. ${q.queueNumber}) telah dibatalkan.',
                                          badge: 'BATAL',
                                          badgeColor: Colors.red.shade400,
                                        )),
                                    const SizedBox(height: 24),
                                  ],

                                  // ── Saran Kesehatan ───────────
                                  _sectionHeader(
                                    'Saran Kesehatan',
                                    Icons.favorite_rounded,
                                    Colors.pink.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  ..._healthTips.map((tip) => _notifCard(
                                        icon: tip['icon'] as IconData,
                                        iconColor:
                                            tip['color'] as Color,
                                        title: tip['title'] as String,
                                        message: tip['message'] as String,
                                        subtitle: 'Tips Kesehatan',
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.grey.shade100,
                child: Icon(Icons.notifications_none_rounded,
                    size: 44, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 20),
              Text(
                'Tidak ada notifikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notifikasi antrean Anda akan\nmuncul di sini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String label, IconData icon, Color color,
      {int? badge}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$badge',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _notifCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    String? subtitle,
    String? badge,
    Color? badgeColor,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (badge != null && badgeColor != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  if (actionLabel != null && onTap != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          actionLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 11, color: AppTheme.primaryColor),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(QueueStatus status) {
    switch (status) {
      case QueueStatus.booked:
        return 'Antrean Dikonfirmasi';
      case QueueStatus.waiting:
        return 'Sedang Menunggu';
      case QueueStatus.examining:
        return 'Giliran Anda!';
      default:
        return 'Antrean Aktif';
    }
  }

  String _statusMessage(
      QueueStatus status, String polyName, String queueNumber) {
    switch (status) {
      case QueueStatus.booked:
        return 'Pendaftaran Anda di $polyName dikonfirmasi. Nomor antrean: $queueNumber. Harap hadir tepat waktu.';
      case QueueStatus.waiting:
        return 'Anda sedang menunggu giliran di $polyName. No. Antrean: $queueNumber. Tetap standby ya!';
      case QueueStatus.examining:
        return 'Giliran Anda telah tiba! Silakan masuk ke ruangan dokter. No. Antrean: $queueNumber.';
      default:
        return 'Antrean Anda ($queueNumber) di $polyName sedang diproses.';
    }
  }

  String _statusBadge(QueueStatus status) {
    switch (status) {
      case QueueStatus.booked:
        return 'TERDAFTAR';
      case QueueStatus.waiting:
        return 'MENUNGGU';
      case QueueStatus.examining:
        return 'DIPANGGIL';
      default:
        return 'AKTIF';
    }
  }

  Color _statusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.booked:
        return AppTheme.secondaryColor;
      case QueueStatus.waiting:
        return Colors.orange;
      case QueueStatus.examining:
        return AppTheme.primaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  static final List<Map<String, dynamic>> _healthTips = [
    {
      'icon': Icons.water_drop_rounded,
      'color': Colors.blue.shade400,
      'title': 'Hidrasi Cukup',
      'message':
          'Minum air putih minimal 8 gelas sehari untuk menjaga hidrasi dan kesehatan tubuh Anda.',
    },
    {
      'icon': Icons.bedtime_rounded,
      'color': Colors.indigo.shade400,
      'title': 'Tidur Berkualitas',
      'message':
          'Pastikan tidur 7–8 jam per malam. Tidur cukup meningkatkan imunitas dan konsentrasi.',
    },
    {
      'icon': Icons.directions_run_rounded,
      'color': Colors.orange.shade400,
      'title': 'Aktif Bergerak',
      'message':
          'Lakukan aktivitas fisik ringan 30 menit sehari, seperti jalan kaki atau peregangan.',
    },
  ];
}
