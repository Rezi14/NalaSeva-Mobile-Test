import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/patient_provider.dart';

class TurnIsNearAlertCard extends StatelessWidget {
  final PatientProvider provider;

  const TurnIsNearAlertCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final activeQueues = provider.myQueues.where((q) => 
        q.date == todayStr &&
        (q.status == QueueStatus.booked || q.status == QueueStatus.waiting)).toList();
        
    if (activeQueues.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final q = activeQueues.first;
    
    // Hitung posisi antrean di depan pasien
    int queuePosition = 3;
    if (q.positionWaiting != null) {
      queuePosition = q.positionWaiting!;
    } else {
      final match = RegExp(r'\d+').firstMatch(q.queueNumber);
      if (match != null) {
        final numVal = int.tryParse(match.group(0) ?? '');
        if (numVal != null) {
          queuePosition = numVal > 0 ? numVal - 1 : 0;
        }
      }
    }
    
    // Hanya tampilkan jika posisi antrean <= 2
    if (queuePosition > 2) {
      return const SizedBox.shrink();
    }
    
    String message = queuePosition == 0 
        ? 'Giliran Anda berikutnya! Silakan bersiap di depan pintu masuk ruangan.'
        : 'Giliran Anda tinggal $queuePosition orang lagi! Silakan bersiap-siap di dekat ruang tunggu poliklinik.';

    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.warningColor, Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warningColor.withValues(alpha: 0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'PERSIAPAN GILIRAN DEKAT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
