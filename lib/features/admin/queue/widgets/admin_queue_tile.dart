import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class AdminQueueTile extends StatelessWidget {
  final QueueModel queue;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final VoidCallback? onSkip;

  const AdminQueueTile({
    super.key,
    required this.queue,
    required this.onTap,
    this.onCall,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;
    final label = queue.status.displayName.toUpperCase();

    switch (queue.status) {
      case QueueStatus.booked:
        badgeColor = AppTheme.warningColor.withValues(alpha: 0.25);
        textColor = AppTheme.warningColor;
        break;
      case QueueStatus.waiting:
        badgeColor = AppTheme.accentColor.withValues(alpha: 0.25);
        textColor = AppTheme.accentColor;
        break;
      case QueueStatus.examining:
        badgeColor = AppTheme.secondaryColor.withValues(alpha: 0.25);
        textColor = AppTheme.secondaryColor;
        break;
      case QueueStatus.completed:
        badgeColor = AppTheme.successColor.withValues(alpha: 0.25);
        textColor = AppTheme.successColor;
        break;
      case QueueStatus.cancelled:
        badgeColor = AppTheme.cancelColor.withValues(alpha: 0.25);
        textColor = AppTheme.cancelColor;
        break;
      case QueueStatus.unknown:
        badgeColor = Colors.white.withValues(alpha: 0.2);
        textColor = Colors.white70;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                queue.queueNumber,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    queue.patient.fullName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    queue.polyclinic.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: textColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (queue.status == QueueStatus.waiting && onCall != null) ...[
              const SizedBox(width: 10),
              IconButton(
                onPressed: onCall,
                icon: const Icon(Icons.volume_up_rounded,
                    color: Colors.white, size: 20),
                tooltip: 'Panggil Pasien',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
            if (queue.status == QueueStatus.booked && onSkip != null) ...[
              const SizedBox(width: 10),
              IconButton(
                onPressed: onSkip,
                icon: Icon(Icons.low_priority_rounded,
                    color: AppTheme.warningColor, size: 20),
                tooltip: 'Lewati & Pindah ke Belakang',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}