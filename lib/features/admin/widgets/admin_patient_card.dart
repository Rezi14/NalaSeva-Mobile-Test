import 'package:flutter/material.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class AdminPatientCard extends StatelessWidget {
  final QueueModel queue;
  final VoidCallback onTap;

  const AdminPatientCard({
    super.key,
    required this.queue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = queue.patient.fullName.isNotEmpty
        ? queue.patient.fullName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    Color statusColor;
    Color statusBg;
    switch (queue.status) {
      case QueueStatus.booked:
        statusColor = AppTheme.warningColor;
        statusBg = AppTheme.warningColor.withValues(alpha: 0.1);
        break;
      case QueueStatus.waiting:
        statusColor = AppTheme.accentColor;
        statusBg = AppTheme.accentColor.withValues(alpha: 0.1);
        break;
      case QueueStatus.examining:
        statusColor = AppTheme.secondaryColor;
        statusBg = AppTheme.secondaryColor.withValues(alpha: 0.1);
        break;
      case QueueStatus.completed:
        statusColor = AppTheme.successColor;
        statusBg = AppTheme.successColor.withValues(alpha: 0.1);
        break;
      case QueueStatus.cancelled:
        statusColor = AppTheme.cancelColor;
        statusBg = AppTheme.cancelColor.withValues(alpha: 0.1);
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${queue.queueNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    queue.status.displayName.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '09:15 AM',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
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
