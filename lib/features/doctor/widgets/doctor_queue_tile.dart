import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class DoctorQueueTile extends StatelessWidget {
  final QueueModel queue;
  final VoidCallback? onExamine;
  final VoidCallback? onCall;
  final VoidCallback? onSkip;

  const DoctorQueueTile({
    super.key,
    required this.queue,
    this.onExamine,
    this.onCall,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isExamining = queue.status == QueueStatus.examining;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExamining
              ? AppTheme.secondaryColor.withValues(alpha: 0.3)
              : Colors.grey.shade100,
        ),
        boxShadow: isExamining
            ? [
                BoxShadow(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isExamining
                  ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              queue.queueNumber,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isExamining ? AppTheme.secondaryColor : Colors.grey.shade700,
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
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isExamining ? Icons.hourglass_top_rounded : Icons.hourglass_empty_rounded,
                      size: 12,
                      color: isExamining ? AppTheme.secondaryColor : AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExamining ? 'Sedang Diperiksa' : 'Menunggu Panggilan',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isExamining ? AppTheme.secondaryColor : AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExamining)
            ElevatedButton.icon(
              onPressed: onExamine,
              icon: const Icon(Icons.medical_services_rounded, size: 14, color: Colors.white),
              label: const Text('PERIKSA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onSkip != null) ...[
                  IconButton(
                    onPressed: onSkip,
                    icon: const Icon(Icons.rotate_right_rounded, color: AppTheme.cancelColor),
                    tooltip: 'Lewati Antrean',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.cancelColor.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onCall != null)
                  OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.campaign_rounded, size: 14),
                    label: const Text('PANGGIL'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.warningColor,
                      side: const BorderSide(color: AppTheme.warningColor),
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
