import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../shared/constants/app_constants.dart';
import '../logic/patient_provider.dart';

class TomorrowReminderCard extends StatelessWidget {
  final PatientProvider provider;

  const TomorrowReminderCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final tomorrowStr = DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0];
    final activeQueues = provider.myQueues.where((q) => 
        q.status != QueueStatus.completed && q.status != QueueStatus.cancelled).toList();
        
    final tomorrowQueues = activeQueues.where((q) => q.date == tomorrowStr).toList();
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
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D9488).withValues(alpha: 0.25),
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
                color: Colors.white.withValues(alpha: 0.15),
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Besok Anda dijadwalkan di ${q.polyclinic.name} pada jam ${q.estimatedServiceTime != null && q.estimatedServiceTime!.length >= 5 ? q.estimatedServiceTime!.substring(0, 5) : (q.estimatedServiceTime ?? "08:00")} WIB.',
                    style: GoogleFonts.inter(
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
