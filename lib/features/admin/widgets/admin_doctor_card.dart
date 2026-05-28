import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_parser.dart';

class AdminDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final List<ScheduleModel> schedules;
  final List<Map<String, dynamic>> doctorLeaves;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminDoctorCard({
    super.key,
    required this.doctor,
    required this.schedules,
    required this.doctorLeaves,
    required this.onEdit,
    required this.onDelete,
  });

  Map<String, dynamic> _getDoctorStatusDetails() {
    final now = DateTime.now();

    // 1. Dokter Cuti Hari Ini
    final todayDateStr = DateFormat('yyyy-MM-dd').format(now);
    final hasLeaveToday = doctorLeaves.any((leave) =>
        leave['doctor_id']?.toString() == doctor.id.toString() &&
        leave['leave_date']?.toString() == todayDateStr);
    
    if (hasLeaveToday) {
      return {
        'label': 'Dokter Cuti Hari Ini',
        'color': AppTheme.errorColor,
        'bgColor': AppTheme.errorColor.withValues(alpha: 0.1),
      };
    }

    // 2. Pengecekan Jadwal Praktik (Prioritas Utama untuk menentukan Keaktifan Tugas hari ini)
    final todayName = DateFormat('EEEE', 'id_ID').format(now).toLowerCase();
    final doctorSchedulesToday = schedules.where((s) =>
        s.doctorId == doctor.id &&
        s.dayOfWeek.toLowerCase() == todayName).toList();

    if (doctorSchedulesToday.isEmpty) {
      return {
        'label': 'Tidak Aktif Hari Ini',
        'color': Colors.grey.shade600,
        'bgColor': Colors.grey.shade100,
      };
    }

    final nowMin = now.hour * 60 + now.minute;
    bool inSchedule = false;
    for (var s in doctorSchedulesToday) {
      final startMin = DateTimeParser.parseMinutesOfDay(s.startTime) ?? 0;
      final endMin = DateTimeParser.parseMinutesOfDay(s.endTime) ?? 0;
      if (nowMin >= startMin && nowMin <= endMin) {
        inSchedule = true;
        break;
      }
    }

    // Jika sedang di luar jam praktik aktif hari ini, status langsung "Tidak Aktif Hari Ini"
    if (!inSchedule) {
      return {
        'label': 'Tidak Aktif Hari Ini',
        'color': Colors.grey.shade600,
        'bgColor': Colors.grey.shade100,
      };
    }

    // 3. Dokter Istirahat (Hanya bisa istirahat jika sedang di dalam jadwal praktik aktif)
    if (!doctor.isOnline) {
      return {
        'label': 'Dokter Istirahat',
        'color': AppTheme.warningColor,
        'bgColor': AppTheme.warningColor.withValues(alpha: 0.1),
      };
    }

    // 4. Aktif Hari Ini
    return {
      'label': 'Aktif Hari Ini',
      'color': AppTheme.successColor,
      'bgColor': AppTheme.successColor.withValues(alpha: 0.1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final name = doctor.user?.name ?? 'Unknown Doctor';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();
    final polyName = doctor.polyclinic?.name ?? 'No Clinic';
    final status = _getDoctorStatusDetails();
    final String statusLabel = status['label'];
    final Color statusColor = status['color'];
    final Color statusBgColor = status['bgColor'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.medical_services_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$polyName - ${doctor.specialization ?? "-"}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
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
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.editColor),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.deleteColor),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
