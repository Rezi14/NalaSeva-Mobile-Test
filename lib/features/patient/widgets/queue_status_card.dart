import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/patient_provider.dart';
import 'stat_mini_item.dart';
import '../ui/booking_detail_screen.dart';

class QueueStatusCard extends StatelessWidget {
  final PatientProvider provider;

  const QueueStatusCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final activeQueues = provider.myQueues.where((q) => q.status.isActive).toList();

    if (activeQueues.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: AppTheme.accentColor),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Anda belum memiliki antrean aktif saat ini.',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final q = activeQueues.first;
    final isCalled = q.status == QueueStatus.examining;

    int queuePosition = 3;
    int avgTimeMultiplier = q.avgWaitingTime ?? 15;
    if (q.positionWaiting != null) {
      queuePosition = q.positionWaiting!;
    } else {
      final match = RegExp(r'(\d+)\u0000?$').firstMatch(q.queueNumber);
      if (match != null) {
        final numVal = int.tryParse(match.group(1) ?? '');
        if (numVal != null) {
          queuePosition = numVal > 0 ? numVal - 1 : 0;
        }
      }
    }
    final estimatedTime = queuePosition * avgTimeMultiplier;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(queue: q),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCalled
              ? const Color(0xFFDC2626) // Solid Premium Red
              : AppTheme.primaryColor,  // Solid Emerald Green
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isCalled ? AppTheme.errorColor : AppTheme.primaryColor).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            if (isCalled) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 1500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'PANGGILAN: MASUK RUANG PERIKSA!',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCalled ? 'Status Antrean: PEMERIKSAAN' : 'Antrean Anda',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: isCalled ? 0.95 : 0.8),
                        fontSize: 12,
                        fontWeight: isCalled ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.polyclinic.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCalled ? Icons.volume_up_rounded : Icons.qr_code_2_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatMiniItem(label: 'Nomor Antrean', value: q.queueNumber),
                StatMiniItem(
                  label: 'Sisa Antrean',
                  value: q.status == QueueStatus.booked
                      ? '$queuePosition Orang'
                      : isCalled
                          ? 'Giliran Anda!'
                          : '$queuePosition Orang',
                ),
                StatMiniItem(
                  label: 'Estimasi Pelayanan',
                  value: q.status == QueueStatus.examining
                      ? 'Sekarang'
                      : (q.estimatedServiceTime != null && q.estimatedServiceTime!.length >= 5
                          ? '${q.estimatedServiceTime!.substring(0, 5)} WIB' 
                          : (q.estimatedServiceTime != null ? '${q.estimatedServiceTime} WIB' : '$estimatedTime menit')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
