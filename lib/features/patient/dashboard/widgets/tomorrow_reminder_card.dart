import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../logic/patient_provider.dart';

class TomorrowReminderCard extends StatelessWidget {
  final PatientProvider provider;

  const TomorrowReminderCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
    final activeQueues = provider.myQueues.where((q) => q.status.isActive).toList();
        
    final tomorrowQueues = activeQueues.where((q) => q.date == tomorrowStr).toList();
    tomorrowQueues.sort((a, b) {
      final timeA = a.estimatedServiceTime ?? '99:99';
      final timeB = b.estimatedServiceTime ?? '99:99';
      return timeA.compareTo(timeB);
    });
    if (tomorrowQueues.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final q = tomorrowQueues.first;
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
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
              child: const Icon(Icons.alarm_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PENGINGAT KUNJUNGAN BESOK',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Besok Anda dijadwalkan di ${q.polyclinic.name} pada jam ${q.estimatedServiceTime != null && q.estimatedServiceTime!.length >= 5 ? q.estimatedServiceTime!.substring(0, 5) : (q.estimatedServiceTime ?? "08:00")} WIB.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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