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
        badgeColor = AppTheme.warningColor.withValues(alpha: 0.1);
        textColor = AppTheme.warningColor;
        break;
      case QueueStatus.waiting:
        badgeColor = AppTheme.accentColor.withValues(alpha: 0.1);
        textColor = AppTheme.accentColor;
        break;
      case QueueStatus.examining:
        badgeColor = AppTheme.secondaryColor.withValues(alpha: 0.1);
        textColor = AppTheme.secondaryColor;
        break;
      case QueueStatus.completed:
        badgeColor = AppTheme.successColor.withValues(alpha: 0.1);
        textColor = AppTheme.successColor;
        break;
      case QueueStatus.cancelled:
        badgeColor = AppTheme.cancelColor.withValues(alpha: 0.1);
        textColor = AppTheme.cancelColor;
        break;
      case QueueStatus.unknown:
        badgeColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                queue.queueNumber,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryColor,
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
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    queue.polyclinic.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
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
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryColor, size: 20),
                tooltip: 'Panggil Pasien',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
            if (queue.status == QueueStatus.booked && onSkip != null) ...[
              const SizedBox(width: 10),
              IconButton(
                onPressed: onSkip,
                icon: const Icon(Icons.low_priority_rounded, color: AppTheme.warningColor, size: 20),
                tooltip: 'Lewati & Pindah ke Belakang',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
