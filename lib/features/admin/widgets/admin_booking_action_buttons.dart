import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/queue_model.dart';
import '../../../core/theme/app_theme.dart';

class AdminBookingActionButtons extends StatelessWidget {
  final QueueModel queue;
  final VoidCallback onCheckIn;
  final VoidCallback onMoveToBack;
  final VoidCallback onCancel;
  final VoidCallback onCallPatient;
  final VoidCallback onRecallPatient;

  const AdminBookingActionButtons({
    super.key,
    required this.queue,
    required this.onCheckIn,
    required this.onMoveToBack,
    required this.onCancel,
    required this.onCallPatient,
    required this.onRecallPatient,
  });

  @override
  Widget build(BuildContext context) {
    if (queue.status == QueueStatus.booked) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: onCheckIn,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('ABSENKAN PASIEN (MANUAL)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onMoveToBack,
            icon: const Icon(Icons.low_priority_rounded),
            label: const Text('LEWATI & PINDAH KE BELAKANG'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          _cancelButton(),
        ],
      );
    } else if (queue.status == QueueStatus.waiting) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: onCallPatient,
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('PANGGIL PASIEN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          _cancelButton(),
        ],
      );
    } else if (queue.status == QueueStatus.examining) {
      return Column(
        children: [
          _statusBanner(
            icon: Icons.medical_services_rounded,
            label: 'PASIEN SEDANG DIPERIKSA DOKTER',
            color: AppTheme.warningColor,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRecallPatient,
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('PANGGIL ULANG (RECALL)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          _cancelButton(),
        ],
      );
    } else if (queue.status == QueueStatus.completed) {
      return _statusBanner(
        icon: Icons.check_circle_rounded,
        label: 'PEMERIKSAAN SELESAI',
        color: AppTheme.successColor,
      );
    } else if (queue.status == QueueStatus.cancelled) {
      return _statusBanner(
        icon: Icons.cancel_outlined,
        label: 'ANTREAN TELAH DIBATALKAN',
        color: Colors.grey,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _cancelButton() {
    return OutlinedButton.icon(
      onPressed: onCancel,
      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
      label: const Text('BATALKAN ANTREAN', style: TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _statusBanner({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: color == Colors.grey ? Colors.grey.shade600 : color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
