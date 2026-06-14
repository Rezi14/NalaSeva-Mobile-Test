import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class AdminPatientCard extends StatelessWidget {
  final QueueModel queue;
  final VoidCallback onTap;
  final VoidCallback? onCheckIn;
  final bool showCheckIn;

  const AdminPatientCard({
    super.key,
    required this.queue,
    required this.onTap,
    this.onCheckIn,
    this.showCheckIn = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = queue.patient.fullName.isNotEmpty
        ? queue.patient.fullName
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    Color statusColor;
    Color statusBg;
    switch (queue.status) {
      case QueueStatus.booked:
        statusColor = AppTheme.warningColor;
        statusBg = Colors.white.withValues(alpha: 0.2);
        break;
      case QueueStatus.waiting:
        statusColor = Colors.white;
        statusBg = Colors.white.withValues(alpha: 0.2);
        break;
      case QueueStatus.examining:
        statusColor = AppTheme.secondaryColor;
        statusBg = Colors.white.withValues(alpha: 0.2);
        break;
      case QueueStatus.completed:
        statusColor = AppTheme.successColor;
        statusBg = Colors.white.withValues(alpha: 0.2);
        break;
      case QueueStatus.cancelled:
        statusColor = AppTheme.cancelColor;
        statusBg = Colors.white.withValues(alpha: 0.2);
        break;
      case QueueStatus.unknown:
        statusColor = Colors.white70;
        statusBg = Colors.white.withValues(alpha: 0.15);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                initials,
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
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No: ${queue.queueNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            showCheckIn
                ? ElevatedButton(
                    onPressed: onCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      minimumSize: const Size(80, 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'ABSEN',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              queue.status.displayName.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        queue.date,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}