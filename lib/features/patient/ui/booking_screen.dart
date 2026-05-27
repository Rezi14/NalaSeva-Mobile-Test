import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../logic/patient_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../widgets/booking_dropdown_card.dart';
import '../widgets/booking_result_dialog.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/date_time_parser.dart';

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
              // Premium Header with smooth bottom-up stagger
              FadeIn(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: AnimationLimiter(
                        child: Column(
                          children: [
                            AnimationConfiguration.staggeredList(
                              position: 0,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 30.0,
                                child: FadeInAnimation(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ambil Antrean',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Daftar antrean poliklinik secara online',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                           items: provider.availableSchedules.where((s) {
                             final doc = _resolveDoctor(provider, s);
                             return doc.isOnline;
                           }).map((s) {
                             final startStr = s.startTime.length >= 5 ? s.startTime.substring(0, 5) : s.startTime;
                             final endStr = s.endTime.length >= 5 ? s.endTime.substring(0, 5) : s.endTime;
                             final quota = _calculateQuota(s.startTime, s.endTime);
                             final doc = _resolveDoctor(provider, s);
                             final doctorName = doc.user?.name ?? doc.name;
                             return DropdownMenuItem<int>(
                               value: s.id, // Using schedule ID for more precision
                               child: Text(
                                 "$doctorName (${s.dayOfWeek}, $startStr - $endStr | Kuota: ${quota != null ? '$quota Pasien' : 'tidak tersedia'})",
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
                              final nearestDate = _getNearestDateForWeekday(targetDayOfWeek, provider);
                              if (nearestDate == null) {
                                if (!mounted) return;
                                _showResultDialog(false, 'Tidak ada tanggal kunjungan yang tersedia dalam 90 hari ke depan untuk jadwal ini.');
                                return;
                              }
                              
                              setState(() {
                                selectedDate = nearestDate;
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
                            if (initialDate == null) {
                              _showResultDialog(false, 'Tidak ada tanggal kunjungan yang valid dalam 90 hari ke depan.');
                              return;
                            }
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

    // Cek apakah pasien sudah memiliki antrean aktif pada tanggal kunjungan yang sama lintas poliklinik (Tugas 1)
    final selectedDateStr = selectedDate.toIso8601String().split('T')[0];
    final hasActiveBookingOnSameDate = provider.myQueues.any((q) => 
        q.date == selectedDateStr &&
        q.status != QueueStatus.completed &&
        q.status != QueueStatus.cancelled
    );

    if (hasActiveBookingOnSameDate) {
      _showResultDialog(
        false, 
        'Anda sudah memiliki antrean aktif pada tanggal kunjungan tersebut di poliklinik lain. Anda hanya diperbolehkan mendaftar maksimal 1 antrean aktif per hari.'
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

    // Validasi kuota maksimal per jadwal sebelum booking
    final quota = _calculateQuota(selectedSchedule.startTime, selectedSchedule.endTime);
    if (quota != null && quota > 0) {
      // Hitung jumlah antrean aktif yang sudah ada pada dokter+tanggal yang sama
      final existingBookingsForSchedule = provider.myQueues.where((q) =>
          q.doctorId == doctorId &&
          q.date == selectedDateStr &&
          q.status != QueueStatus.completed &&
          q.status != QueueStatus.cancelled
      ).length;

      if (existingBookingsForSchedule >= quota) {
        _showResultDialog(
          false,
          'Kuota jadwal dokter ini sudah penuh ($quota pasien). Silakan pilih jadwal atau tanggal lain.',
        );
        return;
      }
    }

    // Proteksi tanggal di masa lalu atau jam praktik hari ini yang sudah terlewat (Tugas 2)
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    
    if (selectedDateOnly.isBefore(todayOnly)) {
      _showResultDialog(false, 'Tanggal kunjungan tidak boleh di masa lalu.');
      return;
    }

    if (selectedDateStr == todayStr) {
      try {
        final endMinutes = DateTimeParser.parseMinutesOfDay(selectedSchedule.endTime);
        if (endMinutes == null) {
          _showResultDialog(false, 'Format jam praktik dokter tidak valid. Silakan pilih jadwal lain.');
          return;
        }
        final limitTime = DateTime(now.year, now.month, now.day, endMinutes ~/ 60, endMinutes % 60);
        if (now.isAfter(limitTime)) {
          _showResultDialog(
            false,
            'Jam praktik dokter untuk hari ini sudah selesai. Silakan pilih tanggal lain.'
          );
          return;
        }
      } catch (e, stack) {
        AppLogger.error('Gagal memvalidasi jam selesai praktik dokter', error: e, stackTrace: stack, tag: 'BookingScreen');
        _showResultDialog(false, 'Format jam praktik dokter tidak valid. Silakan pilih jadwal lain.');
        return;
      }
    }

    // Kirim schedule_id dan max_quota agar backend dapat memvalidasi ulang
    // (pertahanan berlapis: client + server)
    await provider.createBooking({
      'patient_id': patientId,
      'polyclinic_id': selectedPolyId,
      'doctor_id': doctorId,
      'doctor_schedule_id': selectedSchedule.id,
      'date': selectedDateStr,
      if (quota != null) 'max_quota': quota,
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

  DoctorModel _resolveDoctor(PatientProvider provider, ScheduleModel schedule) {
    return provider.doctors.firstWhere(
      (d) => d.id == schedule.doctorId,
      orElse: () => schedule.doctor ?? DoctorModel(id: schedule.doctorId, userId: 0, isOnline: false),
    );
  }

  DateTime? _getNearestDateForWeekday(int targetWeekday, PatientProvider provider) {
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
    return null;
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

  int? _calculateQuota(String startTime, String endTime) {
    try {
      final startTotal = DateTimeParser.parseMinutesOfDay(startTime);
      final endTotal = DateTimeParser.parseMinutesOfDay(endTime);
      if (startTotal != null && endTotal != null) {
        final duration = endTotal - startTotal;
        if (duration > 0) {
          return (duration / 15).floor();
        }
      }
    } catch (e, stack) {
      AppLogger.error('Gagal menghitung kuota dari jam kerja', error: e, stackTrace: stack, tag: 'BookingScreen');
    }
    return null;
  }
}

