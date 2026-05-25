import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/patient_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/doctor_model.dart';
import '../widgets/booking_dropdown_card.dart';
import '../widgets/booking_result_dialog.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int? selectedPolyId;
  int? selectedDoctorId;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PatientProvider>();
      provider.fetchPolyclinics();
      provider.fetchDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<PatientProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Header
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ambil Antrean',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: _buildSectionTitle('Pilih Layanan Poliklinik'),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: BookingDropdownCard(
                          hint: 'Pilih Poliklinik',
                          value: selectedPolyId,
                          items: provider.polyclinics.map((p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name, style: GoogleFonts.inter(fontSize: 14)),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedPolyId = val;
                              selectedDoctorId = null;
                            });
                            if (val != null) provider.fetchSchedulesForPoly(val);
                          },
                          icon: Icons.local_hospital_rounded,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: _buildSectionTitle('Pilih Dokter & Jadwal'),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: BookingDropdownCard(
                          hint: selectedPolyId == null 
                              ? 'Pilih Poliklinik Terlebih Dahulu' 
                              : (provider.availableSchedules.isEmpty 
                                  ? 'Tidak Ada Jadwal Dokter Tersedia' 
                                  : 'Pilih Dokter & Jadwal'),
                          value: selectedDoctorId,
                          enabled: selectedPolyId != null && provider.availableSchedules.isNotEmpty,
                           items: provider.availableSchedules.map((s) {
                             final startStr = s.startTime.length >= 5 ? s.startTime.substring(0, 5) : s.startTime;
                             final endStr = s.endTime.length >= 5 ? s.endTime.substring(0, 5) : s.endTime;
                             final quota = _calculateQuota(s.startTime, s.endTime);
                             final doc = provider.doctors.firstWhere(
                               (d) => d.id == s.doctorId,
                               orElse: () => s.doctor ?? DoctorModel(id: s.doctorId, userId: 0),
                             );
                             final doctorName = doc.user?.name ?? doc.name;
                             return DropdownMenuItem<int>(
                               value: s.id, // Using schedule ID for more precision
                               child: Text(
                                 "$doctorName (${s.dayOfWeek}, $startStr - $endStr | Kuota: $quota Pasien)",
                                 style: GoogleFonts.inter(fontSize: 12),
                               ),
                             );
                           }).toList(),
                          onChanged: (val) async {
                            setState(() {
                              selectedDoctorId = val;
                            });
                            if (val != null) {
                              final schedules = provider.availableSchedules.where((s) => s.id == val);
                              if (schedules.isEmpty) return;
                              final selectedSchedule = schedules.first;
                              final targetDayOfWeek = _getDayOfWeekInt(selectedSchedule.dayOfWeek);
                              
                              // Ambil data libur & cuti dokter asinkron
                              await provider.fetchHolidaysAndLeaves(selectedSchedule.doctorId);
                              
                              setState(() {
                                selectedDate = _getNearestDateForWeekday(targetDayOfWeek, provider);
                              });
                            }
                          },
                          icon: Icons.person_search_rounded,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: _buildSectionTitle('Pilih Tanggal Kunjungan'),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 550),
                        child: InkWell(
                          onTap: selectedDoctorId == null ? null : () async {
                             final schedules = provider.availableSchedules.where((s) => s.id == selectedDoctorId);
                             if (schedules.isEmpty) return;
                             final selectedSchedule = schedules.first;
                             final targetDayOfWeek = _getDayOfWeekInt(selectedSchedule.dayOfWeek);
                            final selDateStr = selectedDate.toIso8601String().split('T')[0];
                            final isSelHoliday = provider.clinicHolidays.contains(selDateStr);
                            final isSelLeave = provider.doctorLeaves.contains(selDateStr);
                            final initialDate = (selectedDate.weekday == targetDayOfWeek && !isSelHoliday && !isSelLeave)
                                ? selectedDate
                                : _getNearestDateForWeekday(targetDayOfWeek, provider);
                            final limitDate = DateTime.now().add(const Duration(days: 30));
                            final adjustedLastDate = initialDate.isAfter(limitDate) ? initialDate.add(const Duration(days: 7)) : limitDate;
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: adjustedLastDate,
                              selectableDayPredicate: (date) {
                                final dateStr = date.toIso8601String().split('T')[0];
                                final isHoliday = provider.clinicHolidays.contains(dateStr);
                                final isLeave = provider.doctorLeaves.contains(dateStr);
                                return date.weekday == targetDayOfWeek && !isHoliday && !isLeave;
                              },
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
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: selectedDoctorId == null ? Colors.grey.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: selectedDoctorId == null ? Colors.grey : AppTheme.primaryColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedDoctorId == null 
                                            ? 'Pilih Dokter Terlebih Dahulu'
                                            : _formatIndonesianDate(selectedDate),
                                        style: GoogleFonts.inter(
                                          color: selectedDoctorId == null ? Colors.grey.shade400 : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (selectedDoctorId != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Klik untuk mengganti tanggal kunjungan',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (selectedDoctorId != null)
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 600),
                        child: _buildSubmitButton(provider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubmitButton(PatientProvider provider) {
    bool canSubmit = selectedPolyId != null && selectedDoctorId != null;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: canSubmit ? AppTheme.primaryColor : Colors.grey.shade200,
      ),
      child: ElevatedButton(
        onPressed: (canSubmit && !provider.isLoading) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: provider.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              'KONFIRMASI PENDAFTARAN',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: canSubmit ? Colors.white : Colors.grey,
              ),
            ),
      ),
    );
  }

  void _showResultDialog(bool isSuccess, String message) {
    BookingResultDialog.show(
      context: context,
      isSuccess: isSuccess,
      message: message,
      onFinished: () {
        Navigator.pop(context); // Tutup dialog
        if (isSuccess) {
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        }
      },
    );
  }


  void _submit() async {
    final user = context.read<AuthProvider>().user;
    final patientId = user?.patientId ?? user?.id;
    if (patientId == null) {
       _showResultDialog(false, 'Data pasien tidak ditemukan');
      return;
    }

    final provider = context.read<PatientProvider>();
    
    // Ambil antrean terbaru milik pasien untuk divalidasi
    await provider.fetchMyQueues();
    
    // Cek apakah pasien sudah memiliki booking aktif di poliklinik yang sama
    final hasActiveBookingInSamePoly = provider.myQueues.any((q) => 
        q.polyclinic.id == selectedPolyId &&
        q.status != QueueStatus.completed &&
        q.status != QueueStatus.cancelled
    );

    if (hasActiveBookingInSamePoly) {
      _showResultDialog(
        false, 
        'Anda masih memiliki antrean aktif di poliklinik ini. Anda tidak diperbolehkan mendaftar lebih dari satu antrean aktif pada poliklinik yang sama.'
      );
      return;
    }

    final schedules = provider.availableSchedules.where((s) => s.id == selectedDoctorId);
    if (schedules.isEmpty) {
      _showResultDialog(false, 'Jadwal dokter tidak ditemukan');
      return;
    }
    final selectedSchedule = schedules.first;
    final doctorId = selectedSchedule.doctorId;

    await provider.createBooking({
      'patient_id': patientId,
      'polyclinic_id': selectedPolyId,
      'doctor_id': doctorId,
      'date': selectedDate.toIso8601String().split('T')[0],
    });
    
    if (mounted) {
      if (provider.error != null) {
        String errorMsg = provider.error!;
        if (errorMsg.contains('aktif di poliklinik')) {
          errorMsg = 'Anda sudah terdaftar pada poliklinik ini untuk tanggal terpilih. Silakan pilih tanggal lain atau cek riwayat antrean Anda.';
        }
        _showResultDialog(false, errorMsg);
      } else {
        _showResultDialog(true, 'Antrean Anda telah sukses terdaftar di poliklinik!');
      }
    }
  }

  int _getDayOfWeekInt(String indonesianDay) {
    switch (indonesianDay.toLowerCase()) {
      case 'senin': return DateTime.monday;
      case 'selasa': return DateTime.tuesday;
      case 'rabu': return DateTime.wednesday;
      case 'kamis': return DateTime.thursday;
      case 'jumat': return DateTime.friday;
      case 'sabtu': return DateTime.saturday;
      case 'minggu': return DateTime.sunday;
      default: return 1;
    }
  }

  DateTime _getNearestDateForWeekday(int targetWeekday, PatientProvider provider) {
    DateTime date = DateTime.now().add(const Duration(days: 1));
    final maxDate = DateTime.now().add(const Duration(days: 90)); // Batas pencarian 90 hari
    while (date.isBefore(maxDate)) {
      if (date.weekday == targetWeekday) {
        final dateStr = date.toIso8601String().split('T')[0];
        final isHoliday = provider.clinicHolidays.contains(dateStr);
        final isLeave = provider.doctorLeaves.contains(dateStr);
        if (!isHoliday && !isLeave) {
          return date;
        }
      }
      date = date.add(const Duration(days: 1));
    }
    // Fallback: kembalikan tanggal pertama yang sesuai hari tanpa cek libur
    date = DateTime.now().add(const Duration(days: 1));
    while (date.weekday != targetWeekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  String _formatIndonesianDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  int _calculateQuota(String startTime, String endTime) {
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      if (startParts.length >= 2 && endParts.length >= 2) {
        final startHour = int.parse(startParts[0]);
        final startMin = int.parse(startParts[1]);
        final endHour = int.parse(endParts[0]);
        final endMin = int.parse(endParts[1]);
        
        final startTotal = startHour * 60 + startMin;
        final endTotal = endHour * 60 + endMin;
        final duration = endTotal - startTotal;
        if (duration > 0) {
          return (duration / 15).floor();
        }
      }
    } catch (_) {}
    return 10; // default fallback quota
  }
}

