import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../logic/admin_provider.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';

class AdminQueueBookingSheet extends StatefulWidget {
  final PatientModel patient;

  const AdminQueueBookingSheet({super.key, required this.patient});

  static void show(BuildContext context, PatientModel patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AdminQueueBookingSheet(patient: patient),
    );
  }

  @override
  State<AdminQueueBookingSheet> createState() => _AdminQueueBookingSheetState();
}

class _AdminQueueBookingSheetState extends State<AdminQueueBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedPolyId;
  DateTime? _selectedDate;
  ScheduleModel? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchPolyclinics();
      provider.fetchSchedules();
      provider.fetchDoctors();
      provider.fetchClinicHolidays();
      provider.fetchDoctorLeaves();
    });
  }

  String _getIndonesianDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday: return 'Senin';
      case DateTime.tuesday: return 'Selasa';
      case DateTime.wednesday: return 'Rabu';
      case DateTime.thursday: return 'Kamis';
      case DateTime.friday: return 'Jumat';
      case DateTime.saturday: return 'Sabtu';
      case DateTime.sunday: return 'Minggu';
      default: return '';
    }
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  bool _isBlockedByClinicHoliday(List<Map<String, dynamic>> holidays, DateTime date) {
    final targetDate = _dateKey(date);
    return holidays.any((holiday) => _dateKey(DateTime.parse(holiday['holiday_date'].toString())).compareTo(targetDate) == 0);
  }

  bool _isBlockedByDoctorLeave(List<Map<String, dynamic>> leaves, int doctorId, DateTime date) {
    final targetDate = _dateKey(date);
    return leaves.any((leave) {
      final leaveDoctorId = int.tryParse(leave['doctor_id']?.toString() ?? '') ?? 0;
      if (leaveDoctorId != doctorId) return false;
      final leaveDateRaw = leave['leave_date']?.toString() ?? '';
      if (leaveDateRaw.isEmpty) return false;
      final leaveDate = DateTime.tryParse(leaveDateRaw.replaceAll(' ', 'T'));
      final normalized = leaveDate != null ? _dateKey(leaveDate) : leaveDateRaw.split('T').first.split(' ').first;
      return normalized == targetDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final polyclinics = provider.polyclinics;
    
    // Filter schedules based on polyclinic and selected date's day of week
    List<ScheduleModel> availableSchedules = [];
    if (_selectedPolyId != null && _selectedDate != null) {
      final dayStr = _getIndonesianDay(_selectedDate!);
      availableSchedules = provider.schedules.where((s) {
        // Find doctor to check polyclinic
        final doc = provider.doctors.firstWhere(
          (d) => d.id == s.doctorId,
          orElse: () => s.doctor ?? DoctorModel(id: s.doctorId, userId: 0),
        );
        return doc.polyclinicId == _selectedPolyId && s.dayOfWeek == dayStr;
      }).toList();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Daftar Antrean Manual',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Patient Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'NIK: ${widget.patient.nationalId ?? "-"}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Polyclinic Dropdown
                Text(
                  'Poliklinik Tujuan',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedPolyId,
                  decoration: InputDecoration(
                    hintText: 'Pilih Poliklinik',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: polyclinics.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedPolyId = v;
                      _selectedSchedule = null; // Reset schedule
                    });
                  },
                  validator: (v) => v == null ? 'Poliklinik wajib dipilih' : null,
                ),
                const SizedBox(height: 20),

                // Date Picker
                Text(
                  'Tanggal Kunjungan',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppTheme.primaryColor,
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _selectedSchedule = null; // Reset schedule
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Pilih Tanggal Kunjungan'
                              : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate!),
                          style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black87),
                        ),
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Schedule Selection (Dropdown)
                if (_selectedPolyId != null && _selectedDate != null) ...[
                  Text(
                    'Jadwal Dokter',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ScheduleModel>(
                    initialValue: _selectedSchedule,
                    decoration: InputDecoration(
                      hintText: availableSchedules.isEmpty ? 'Tidak ada jadwal pada hari ini' : 'Pilih Dokter & Jam',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    items: availableSchedules.map((s) {
                      final doc = provider.doctors.firstWhere((d) => d.id == s.doctorId, orElse: () => s.doctor!);
                      final startLabel = s.startTime.length >= 5 ? s.startTime.substring(0,5) : s.startTime;
                      final endLabel = s.endTime.length >= 5 ? s.endTime.substring(0,5) : s.endTime;
                      return DropdownMenuItem(
                        value: s,
                        child: Text('${doc.name} ($startLabel - $endLabel)'),
                      );
                    }).toList(),
                    onChanged: availableSchedules.isEmpty ? null : (v) {
                      setState(() {
                        _selectedSchedule = v;
                      });
                    },
                    validator: (v) => v == null ? 'Jadwal dokter wajib dipilih' : null,
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final hasValue = _selectedPolyId != null || _selectedDate != null || _selectedSchedule != null;
                          if (hasValue) {
                            final confirm = await AppDialogs.showConfirmationDialog(
                              context,
                              'Batalkan Pendaftaran?',
                              'Apakah Anda yakin ingin membatalkan pengisian data antrean manual ini?',
                              confirmText: 'YA, BATALKAN',
                              cancelText: 'KEMBALI',
                              isDestructive: true,
                            );
                            if ((confirm ?? false) && context.mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isLoading || _selectedSchedule == null ? null : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) return;

                          final confirm = await AppDialogs.showConfirmationDialog(
                            context,
                            'Daftarkan Antrean?',
                            'Apakah Anda yakin ingin mendaftarkan pasien ke antrean ini?',
                            confirmText: 'YA, DAFTAR',
                            cancelText: 'BATAL',
                          );
                          if (!(confirm ?? false)) return;
                          if (!context.mounted) return;

                          final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                          final doc = provider.doctors.firstWhere(
                            (d) => d.id == _selectedSchedule!.doctorId,
                            orElse: () => _selectedSchedule?.doctor ?? DoctorModel(id: _selectedSchedule?.doctorId ?? 0, userId: 0),
                          );

                          if (_isBlockedByClinicHoliday(provider.clinicHolidays, _selectedDate!)) {
                            if (context.mounted) {
                              AppDialogs.showNotificationDialog(
                                context,
                                'Tanggal Tidak Tersedia',
                                'Tanggal kunjungan tersebut merupakan hari libur puskesmas.',
                                isError: true,
                              );
                            }
                            return;
                          }

                          if (_isBlockedByDoctorLeave(provider.doctorLeaves, doc.id, _selectedDate!)) {
                            if (context.mounted) {
                              AppDialogs.showNotificationDialog(
                                context,
                                'Tanggal Tidak Tersedia',
                                'Dokter yang dipilih sedang cuti pada tanggal tersebut.',
                                isError: true,
                              );
                            }
                            return;
                          }

                          final data = {
                            'patient_id': widget.patient.id,
                            'polyclinic_id': _selectedPolyId,
                            'doctor_id': doc.id,
                            'doctor_schedule_id': _selectedSchedule!.id,
                            'date': dateStr,
                          };

                          await provider.bookQueueForPatient(data);

                          if (context.mounted) {
                            if (provider.error != null) {
                              AppDialogs.showNotificationDialog(
                                context,
                                'Gagal Booking',
                                provider.error!,
                                isError: true,
                                                    );
                            } else {
                              Navigator.pop(context);
                              AppDialogs.showSuccessDialog(
                                context,
                                'Pendaftaran Sukses',
                                'Antrean untuk pasien ${widget.patient.name} telah berhasil terdaftar secara manual.',
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Daftar',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
