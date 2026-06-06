import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/queue_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';

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
    final btnH  = ResponsiveHelper.buttonHeight(context);
    final btnR  = ResponsiveHelper.radiusButton(context);
    final btnFs = ResponsiveHelper.fontSizeButton(context);

    if (queue.status == QueueStatus.booked) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: onCheckIn,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text('ABSENKAN PASIEN (MANUAL)',
                style: TextStyle(fontSize: btnFs)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, btnH),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(btnR)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onMoveToBack,
            icon: const Icon(Icons.low_priority_rounded),
            label: Text('LEWATI & PINDAH KE BELAKANG',
                style: TextStyle(fontSize: btnFs)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, btnH),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(btnR)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          _cancelButton(context, btnH: btnH, btnR: btnR, btnFs: btnFs),
        ],
      );
    } else if (queue.status == QueueStatus.waiting) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: onCallPatient,
            icon: const Icon(Icons.volume_up_rounded),
            label: Text('PANGGIL PASIEN',
                style: TextStyle(fontSize: btnFs)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, btnH),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(btnR)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          _cancelButton(context, btnH: btnH, btnR: btnR, btnFs: btnFs),
        ],
      );
    } else if (queue.status == QueueStatus.examining) {
      return Column(
        children: [
          _statusBanner(
            context: context,
            icon: Icons.medical_services_rounded,
            label: 'PASIEN SEDANG DIPERIKSA DOKTER',
            color: AppTheme.warningColor,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRecallPatient,
            icon: const Icon(Icons.volume_up_rounded),
            label: Text('PANGGIL ULANG (RECALL)',
                style: TextStyle(fontSize: btnFs)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, btnH),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(btnR)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          _cancelButton(context, btnH: btnH, btnR: btnR, btnFs: btnFs),
        ],
      );
    } else if (queue.status == QueueStatus.completed) {
      return _statusBanner(
        context: context,
        icon: Icons.check_circle_rounded,
        label: 'PEMERIKSAAN SELESAI',
        color: AppTheme.successColor,
      );
    } else if (queue.status == QueueStatus.cancelled) {
      return _statusBanner(
        context: context,
        icon: Icons.cancel_outlined,
        label: 'ANTREAN TELAH DIBATALKAN',
        color: Colors.grey,
      );
    } else if (queue.status == QueueStatus.unknown) {
      return _statusBanner(
        context: context,
        icon: Icons.help_outline_rounded,
        label: 'STATUS ANTREAN TIDAK DIKENAL',
        color: Colors.grey,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _cancelButton(BuildContext context, {
    required double btnH,
    required double btnR,
    required double btnFs,
  }) {
    return OutlinedButton.icon(
      onPressed: onCancel,
      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
      label: Text('BATALKAN ANTREAN',
          style: TextStyle(color: Colors.red, fontSize: btnFs)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        minimumSize: Size(double.infinity, btnH),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(btnR)),
      ),
    );
  }

  Widget _statusBanner({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final radius = ResponsiveHelper.radiusCard(context);
    final fBody  = ResponsiveHelper.fontSizeBody(context);

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.paddingCard(context) * 0.8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
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
              fontSize: fBody,
            ),
          ),
        ],
      ),
    );
  }
}
