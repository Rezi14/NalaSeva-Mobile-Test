import 'package:intl/intl.dart';
import '../../shared/models/queue_model.dart';

class ServiceTimeValidator {
  /// Validates if the admin can perform status changes based on queue date and estimated service time.
  /// Enforces:
  /// 1. Must be on the exact scheduled date.
  /// 2. Must be within the allowed time window:
  ///    Starting from 30 minutes before [estimatedServiceTime] up to 2 hours after [estimatedServiceTime].
  /// Returns null if valid, or a descriptive error message if invalid.
  static String? validateAdminAction(QueueModel queue) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // 1. Check Date
    if (queue.date != todayStr) {
      return 'Antrean ini dijadwalkan untuk tanggal ${queue.date}. Perubahan status hanya diijinkan pada hari kunjungan.';
    }

    // 2. Check Service Time
    if (queue.estimatedServiceTime == null || queue.estimatedServiceTime!.isEmpty) {
      return null; // Allow if not specified
    }

    try {
      final timeParts = queue.estimatedServiceTime!.split(':');
      final startHour = int.parse(timeParts[0]);
      final startMinute = int.parse(timeParts[1]);

      final startMinutes = startHour * 60 + startMinute;

      final nowMinutes = now.hour * 60 + now.minute;

      if (nowMinutes < (startMinutes - 30)) {
        return 'Antrean ini dijadwalkan pada jam ${queue.estimatedServiceTime}. Absensi & perubahan status hanya diijinkan maksimal 30 menit sebelum jam pelayanan.';
      }
    } catch (_) {}

    return null;
  }
}
