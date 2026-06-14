import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../../../shared/models/doctor_model.dart';
import '../../../../shared/models/schedule_model.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_parser.dart';

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
    final todayDateStr = DateFormat('yyyy-MM-dd').format(now);
    final hasLeaveToday = doctorLeaves.any((leave) =>
        leave['doctor_id']?.toString() == doctor.id.toString() &&
        leave['leave_date']?.toString() == todayDateStr);

    if (hasLeaveToday) {
      return {
        'label': 'Dokter Cuti Hari Ini',
        'color': AppTheme.errorColor,
        'bgColor': Colors.white.withValues(alpha: 0.2),
      };
    }

    final todayName = DateFormat('EEEE', 'id_ID').format(now).toLowerCase();
    final doctorSchedulesToday = schedules.where((s) =>
        s.doctorId == doctor.id &&
        s.dayOfWeek.toLowerCase() == todayName).toList();

    if (doctorSchedulesToday.isEmpty) {
      return {
        'label': 'Tidak Aktif Hari Ini',
        'color': Colors.white,
        'bgColor': Colors.white.withValues(alpha: 0.15),
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

    if (!inSchedule) {
      return {
        'label': 'Tidak Aktif Hari Ini',
        'color': Colors.white,
        'bgColor': Colors.white.withValues(alpha: 0.15),
      };
    }

    if (doctor.isOnline == null) {
      return {
        'label': 'Status Tidak Diketahui',
        'color': Colors.white,
        'bgColor': Colors.white.withValues(alpha: 0.15),
      };
    }

    if (!doctor.isOnline!) {
      return {
        'label': 'Dokter Istirahat',
        'color': AppTheme.warningColor,
        'bgColor': Colors.white.withValues(alpha: 0.2),
      };
    }

    return {
      'label': 'Aktif Hari Ini',
      'color': AppTheme.successColor,
      'bgColor': Colors.white.withValues(alpha: 0.2),
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
        gradient: AppTheme.backgroundGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
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
                  name,
                  style: GoogleFonts.poppins( 
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.medical_services_rounded, size: 12, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$polyName - ${doctor.specialization ?? "-"}',
                        style: GoogleFonts.poppins( 
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                      style: GoogleFonts.poppins( 
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
                    icon: Icon(Icons.edit_rounded, size: 18, color: Colors.white.withValues(alpha: 0.9)),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white.withValues(alpha: 0.75)),
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
