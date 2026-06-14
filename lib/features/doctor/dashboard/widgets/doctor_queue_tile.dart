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
        badgeColor = const Color(0xFFFEF3C7).withValues(alpha: 0.25); 
        textColor = const Color(0xFFFBBF24); 
        break;
      case QueueStatus.waiting:
        badgeColor = const Color(0xFFE0F2FE).withValues(alpha: 0.25); 
        textColor = const Color(0xFF38BDF8);
        break;
      case QueueStatus.examining:
        badgeColor = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        break;
      case QueueStatus.completed:
        badgeColor = const Color(0xFFD1FAE5).withValues(alpha: 0.25); 
        textColor = const Color(0xFF34D399);
        break;
      case QueueStatus.cancelled:
        badgeColor = const Color(0xFFFEE2E2).withValues(alpha: 0.25); 
        textColor = const Color(0xFFFB7185);
        break;
      default:
        badgeColor = Colors.white.withValues(alpha: 0.2);
        textColor = Colors.white70;
        break;
    }

    final cardPadding = ResponsiveHelper.paddingCard(context);
    final cardRadius = ResponsiveHelper.radiusCard(context);
    final textHeadingSize =
        ResponsiveHelper.scale(context, 14, tablet: 16, tv: 18);
    final textBodySize =
        ResponsiveHelper.scale(context, 12, tablet: 13, tv: 14);
    final textCaptionSize =
        ResponsiveHelper.scale(context, 10, tablet: 11, tv: 12);
    final buttonRadius = ResponsiveHelper.radiusButton(context);

    final cardDecoration = BoxDecoration(
      gradient: AppTheme.backgroundGradient,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    );

    if (ResponsiveHelper.isMobile(context)) {
      return Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.scale(context, 12,
                        tablet: 14, tv: 16),
                    vertical: ResponsiveHelper.scale(context, 8,
                        tablet: 10, tv: 12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.scale(context, 10,
                            tablet: 12, tv: 14)),
                  ),
                  child: Text(
                    queue.queueNumber,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: textHeadingSize - 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: textHeadingSize,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (queue.patient.isElderly) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                'LANSIA',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
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
                        style: GoogleFonts.poppins(
                          fontSize: textBodySize,
                          color: Colors.white.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: textColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: textCaptionSize - 1,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            if (isExamining || onSkip != null || onCall != null) ...[
              const SizedBox(height: 12),
              Divider(
                  height: 1, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isExamining)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onExamine,
                        icon: const Icon(Icons.medical_services_rounded,
                            size: 14, color: AppTheme.primaryColor),
                        label: Text(
                          'PERIKSA PASIEN',
                          style: GoogleFonts.poppins(
                            fontSize: textBodySize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius)),
                        ),
                      ),
                    )
                  else ...[
                    if (onSkip != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSkip,
                          icon: const Icon(Icons.rotate_right_rounded,
                              color: Colors.white, size: 16),
                          label: Text(
                            'LEWATI',
                            style: GoogleFonts.poppins(
                              fontSize: textBodySize - 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5)),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(buttonRadius)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (onCall != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onCall,
                          icon: const Icon(Icons.campaign_rounded,
                              size: 16, color: AppTheme.primaryColor),
                          label: Text(
                            'PANGGIL',
                            style: GoogleFonts.poppins(
                              fontSize: textBodySize - 1,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 0,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(buttonRadius)),
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

    // Tablet/Desktop Layout
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: cardDecoration,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.scale(context, 14,
                  tablet: 16, tv: 18),
              vertical: ResponsiveHelper.scale(context, 10,
                  tablet: 12, tv: 14),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.scale(context, 12, tablet: 14, tv: 16)),
            ),
            child: Text(
              queue.queueNumber,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: textHeadingSize,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: textHeadingSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (queue.patient.isElderly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'LANSIA',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.scale(context, 8,
                                tablet: 9, tv: 10),
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
                  style: GoogleFonts.poppins(
                    fontSize: textBodySize,
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.scale(context, 10,
                  tablet: 12, tv: 14),
              vertical: ResponsiveHelper.scale(context, 6,
                  tablet: 8, tv: 10),
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.scale(context, 8, tablet: 10, tv: 12)),
              border:
                  Border.all(color: textColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: textCaptionSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (isExamining) ...[
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: onExamine,
              icon: Icon(
                Icons.medical_services_rounded,
                size: ResponsiveHelper.iconSize(context, base: 14),
                color: AppTheme.primaryColor,
              ),
              label: Text(
                'PERIKSA',
                style: GoogleFonts.poppins(
                  fontSize: textBodySize - 1,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.scale(context, 14,
                      tablet: 16, tv: 18),
                  vertical: ResponsiveHelper.scale(context, 12,
                      tablet: 14, tv: 16),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius)),
              ),
            ),
          ] else ...[
            if (onSkip != null || onCall != null)
              const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onSkip != null) ...[
                  IconButton(
                    onPressed: onSkip,
                    icon: Icon(
                      Icons.rotate_right_rounded,
                      color: Colors.white,
                      size: ResponsiveHelper.iconSize(context, base: 20),
                    ),
                    tooltip: 'Lewati Antrean',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.2),
                      padding: EdgeInsets.all(ResponsiveHelper.scale(
                          context, 10,
                          tablet: 12, tv: 14)),
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
                      color: Colors.white,
                    ),
                    label: Text(
                      'PANGGIL',
                      style: GoogleFonts.poppins(
                        fontSize: textBodySize - 1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.5)),
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.scale(context, 14,
                            tablet: 16, tv: 18),
                        vertical: ResponsiveHelper.scale(context, 12,
                            tablet: 14, tv: 16),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(buttonRadius)),
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