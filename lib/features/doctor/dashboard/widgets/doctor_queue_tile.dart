import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';

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
    Color badgeColor;
    Color textColor;
    final label = queue.status.displayName.toUpperCase();
    final isExamining = queue.status == QueueStatus.examining;

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
      default:
        badgeColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
    }

    final cardPadding = ResponsiveHelper.paddingCard(context);
    final cardRadius = ResponsiveHelper.radiusCard(context);
    final textHeadingSize = ResponsiveHelper.scale(context, 14, tablet: 16, tv: 18);
    final textBodySize = ResponsiveHelper.scale(context, 12, tablet: 13, tv: 14);
    final textCaptionSize = ResponsiveHelper.scale(context, 10, tablet: 11, tv: 12);
    final buttonRadius = ResponsiveHelper.radiusButton(context);

    // Mobile Layout (Stacked/Column Layout)
    if (ResponsiveHelper.isMobile(context)) {
      return Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isExamining
                ? AppTheme.secondaryColor.withValues(alpha: 0.3)
                : Colors.grey.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Queue Badge, Info, and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Queue Number Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.scale(context, 12, tablet: 14, tv: 16),
                    vertical: ResponsiveHelper.scale(context, 8, tablet: 10, tv: 12),
                  ),
                  decoration: BoxDecoration(
                    color: isExamining
                        ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 10, tablet: 12, tv: 14)),
                  ),
                  child: Text(
                    queue.queueNumber,
                    style: GoogleFonts.plusJakartaSans(
                      color: isExamining ? AppTheme.secondaryColor : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: textHeadingSize - 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Patient Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              queue.patient.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: textHeadingSize,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (queue.patient.isElderly) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                'LANSIA',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.warningColor,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        queue.polyclinic.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: textBodySize,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: textColor,
                      fontSize: textCaptionSize - 1,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Row: Action Buttons
            if (isExamining || onSkip != null || onCall != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isExamining)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onExamine,
                        icon: Icon(
                          Icons.medical_services_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: Text(
                          'PERIKSA PASIEN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: textBodySize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                        ),
                      ),
                    )
                  else ...[
                    if (onSkip != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSkip,
                          icon: Icon(
                            Icons.rotate_right_rounded,
                            color: AppTheme.cancelColor,
                            size: 16,
                          ),
                          label: Text(
                            'LEWATI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: textBodySize - 1,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.cancelColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.cancelColor),
                            foregroundColor: AppTheme.cancelColor,
                            backgroundColor: AppTheme.cancelColor.withValues(alpha: 0.05),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (onCall != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onCall,
                          icon: const Icon(Icons.campaign_rounded, size: 16, color: Colors.white),
                          label: Text(
                            'PANGGIL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: textBodySize - 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warningColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ],
        ),
      );
    }

    // Tablet/Desktop Layout (Row Layout)
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isExamining
              ? AppTheme.secondaryColor.withValues(alpha: 0.3)
              : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          // Queue Number Badge (Identical to Admin but responsive)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.scale(context, 14, tablet: 16, tv: 18),
              vertical: ResponsiveHelper.scale(context, 10, tablet: 12, tv: 14),
            ),
            decoration: BoxDecoration(
              color: isExamining
                  ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 12, tablet: 14, tv: 16)),
            ),
            child: Text(
              queue.queueNumber,
              style: GoogleFonts.plusJakartaSans(
                color: isExamining ? AppTheme.secondaryColor : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: textHeadingSize,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Patient Details (Identical to Admin layout but responsive)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        queue.patient.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: textHeadingSize,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (queue.patient.isElderly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'LANSIA',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.warningColor,
                            fontSize: ResponsiveHelper.scale(context, 8, tablet: 9, tv: 10),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  queue.polyclinic.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: textBodySize,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Status Badge (Identical to Admin but responsive)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.scale(context, 10, tablet: 12, tv: 14),
              vertical: ResponsiveHelper.scale(context, 6, tablet: 8, tv: 10),
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 8, tablet: 10, tv: 12)),
            ),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: textCaptionSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Actions
          if (isExamining) ...[
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: onExamine,
              icon: Icon(
                Icons.medical_services_rounded,
                size: ResponsiveHelper.iconSize(context, base: 14),
                color: Colors.white,
              ),
              label: Text(
                'PERIKSA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: textBodySize - 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.scale(context, 14, tablet: 16, tv: 18),
                  vertical: ResponsiveHelper.scale(context, 12, tablet: 14, tv: 16),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
              ),
            ),
          ] else ...[
            if (onSkip != null || onCall != null) const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onSkip != null) ...[
                  IconButton(
                    onPressed: onSkip,
                    icon: Icon(
                      Icons.rotate_right_rounded,
                      color: AppTheme.cancelColor,
                      size: ResponsiveHelper.iconSize(context, base: 20),
                    ),
                    tooltip: 'Lewati Antrean',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.cancelColor.withValues(alpha: 0.1),
                      padding: EdgeInsets.all(ResponsiveHelper.scale(context, 10, tablet: 12, tv: 14)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onCall != null)
                  OutlinedButton.icon(
                    onPressed: onCall,
                    icon: Icon(
                      Icons.campaign_rounded,
                      size: ResponsiveHelper.iconSize(context, base: 14),
                    ),
                    label: Text(
                      'PANGGIL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: textBodySize - 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.warningColor,
                      side: const BorderSide(color: AppTheme.warningColor),
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.scale(context, 14, tablet: 16, tv: 18),
                        vertical: ResponsiveHelper.scale(context, 12, tablet: 14, tv: 16),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
