import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final QueueStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    final label = status.displayName.toUpperCase();

    switch (status) {
      case QueueStatus.booked:
        color = AppTheme.warningColor;
        break;
      case QueueStatus.waiting:
        color = AppTheme.accentColor;
        break;
      case QueueStatus.examining:
        color = AppTheme.secondaryColor;
        break;
      case QueueStatus.completed:
        color = AppTheme.successColor;
        break;
      case QueueStatus.cancelled:
        color = AppTheme.cancelColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
