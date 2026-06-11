import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/utils/responsive_helper.dart';
import '../logic/patient_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../shared/providers/payment_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../widgets/booking_dropdown_card.dart';
import '../widgets/booking_result_dialog.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/date_time_parser.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/app_constants.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int? selectedPolyId;
  int? selectedDoctorId;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

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
          return ResponsiveCenter(
            maxWidth: 700,
            child: Column(
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
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                          items: provider.polyclinics
                              .map(
                                (p) => DropdownMenuItem<int>(
                                  value: p.id,
                                  child: Text(
                                    p.name,
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedPolyId = val;
                              selectedDoctorId = null;
                            });
                            if (val != null) {
                              provider.fetchSchedulesForPoly(val);
                            }
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
                          enabled:
                              selectedPolyId != null &&
                              provider.availableSchedules.isNotEmpty,
                          items: provider.availableSchedules.map((s) {
                            final startStr = s.startTime.length >= 5
                                ? s.startTime.substring(0, 5)
                                : s.startTime;
                            final endStr = s.endTime.length >= 5
                                ? s.endTime.substring(0, 5)
                                : s.endTime;
                            final quota = _calculateQuota(
                              s.startTime,
                              s.endTime,
                            );
                            final doc = _resolveDoctor(provider, s);
                            final doctorName = doc.user?.name ?? doc.name;
                            final quotaText = quota != null ? '$quota Kapasitas' : 'tidak tersedia';
                            return DropdownMenuItem<int>(
                              value:
                                  s.id, // Using schedule ID for more precision
                              child: Text(
                                "$doctorName (${s.dayOfWeek}, $startStr - $endStr | $quotaText)",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            setState(() {
                              selectedDoctorId = val;
                            });
                            if (val != null) {
                              final schedules = provider.availableSchedules
                                  .where((s) => s.id == val);
                              if (schedules.isEmpty) return;
                              final selectedSchedule = schedules.first;

                              // Ambil data libur & cuti dokter asinkron
                              await provider.fetchHolidaysAndLeaves(
                                selectedSchedule.doctorId,
                              );
                              final nearestDate = _getNearestDateForWeekday(
                                selectedSchedule,
                                provider,
                              );
                              if (nearestDate == null) {
                                if (!mounted) return;
                                setState(() {
                                  selectedDoctorId = null;
                                });
                                _showResultDialog(
                                  false,
                                  'Tidak ada tanggal kunjungan yang tersedia dalam 7 hari ke depan untuk jadwal ini.',
                                );
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
                          onTap: selectedDoctorId == null
                              ? null
                              : () async {
                                  final schedules = provider.availableSchedules
                                      .where((s) => s.id == selectedDoctorId);
                                  if (schedules.isEmpty) return;
                                  final selectedSchedule = schedules.first;
                                  final initialDate = _getNearestDateForWeekday(
                                    selectedSchedule,
                                    provider,
                                  );
                                  if (initialDate == null) {
                                    _showResultDialog(
                                      false,
                                      'Tidak ada tanggal kunjungan yang valid dalam 7 hari ke depan.',
                                    );
                                    return;
                                  }
                                  final adjustedLastDate = DateTime.now().add(
                                    const Duration(days: 7),
                                  );
                                  final now = DateTime.now();
                                  final todayStart = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: todayStart,
                                    lastDate: adjustedLastDate,
                                    selectableDayPredicate: (date) {
                                      return _isBookableDate(
                                        date,
                                        selectedSchedule,
                                        provider,
                                      );
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
                              color: selectedDoctorId == null
                                  ? Colors.grey.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: selectedDoctorId == null
                                      ? Colors.grey
                                      : AppTheme.primaryColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedDoctorId == null
                                            ? 'Pilih Dokter Terlebih Dahulu'
                                            : _formatIndonesianDate(
                                                selectedDate,
                                              ),
                                        style: GoogleFonts.inter(
                                          color: selectedDoctorId == null
                                              ? Colors.grey.shade400
                                              : Colors.black87,
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
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isPriorityPatient()) ...[
                        const SizedBox(height: 24),
                        FadeIn(
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.elderly_rounded,
                                  color: Colors.amber.shade700,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Layanan Antrean Prioritas',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Anda terdeteksi sebagai lansia (usia >= 60 tahun). Antrean Anda akan secara otomatis didahulukan oleh sistem.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
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
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
    final patientId = user?.patientId;
    if (patientId == null) {
      _showResultDialog(
        false,
        'Data pasien tidak ditemukan. Akun Anda tidak terdaftar sebagai pasien.',
      );
      return;
    }

    final provider = context.read<PatientProvider>();
    final paymentProvider = context.read<PaymentProvider>();

    // Pengecekan tagihan tertunggak > 24 jam
    try {
      await paymentProvider.fetchMyPayments();
      final hasOutstanding = paymentProvider.payments.any((p) {
        if (p.status != 'pending') return false;
        final created = p.createdAt ?? p.queue?.createdAt;
        if (created == null) return false;
        final diff = DateTime.now().difference(created);
        return diff.inHours > 24;
      });

      if (hasOutstanding) {
        _showResultDialog(
          false,
          'Harap lunasi tagihan Anda sebelumnya untuk dapat membuat antrean baru.',
        );
        return;
      }
    } catch (e) {
      AppLogger.error('Gagal memvalidasi tagihan tertunggak', error: e, tag: 'BookingScreen');
    }

    // Ambil antrean terbaru milik pasien untuk divalidasi
    await provider.fetchMyQueues();

    // Cek apakah pasien sudah memiliki booking aktif di poliklinik yang sama pada tanggal yang sama
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final hasActiveBookingInSamePoly = provider.myQueues.any(
      (q) =>
          q.polyclinic.id == selectedPolyId &&
          q.date == selectedDateStr &&
          q.status != QueueStatus.cancelled,
    );

    if (hasActiveBookingInSamePoly) {
      _showResultDialog(
        false,
        'Anda masih memiliki antrean aktif di poliklinik ini pada tanggal tersebut. Anda tidak diperbolehkan mendaftar lebih dari satu antrean aktif pada poliklinik yang sama di hari yang sama.',
      );
      return;
    }

    final schedules = provider.availableSchedules.where(
      (s) => s.id == selectedDoctorId,
    );
    if (schedules.isEmpty) {
      _showResultDialog(false, 'Jadwal dokter tidak ditemukan');
      return;
    }
    final selectedSchedule = schedules.first;
    final doctorId = selectedSchedule.doctorId;

    // Cek apakah pasien sudah memiliki antrean aktif pada tanggal kunjungan yang sama dengan jadwal yang bertabrakan (Tugas 1 - Refined)
    final activeQueuesSameDate = provider.myQueues
        .where((q) => q.date == selectedDateStr && q.status != QueueStatus.cancelled)
        .toList();

    for (var existingQueue in activeQueuesSameDate) {
      var existingSchedule = existingQueue.doctorSchedule;
      if (existingSchedule == null && existingQueue.doctorScheduleId != null) {
        try {
          final schedulesOfPoly = await provider.getSchedulesDirectly(
            existingQueue.polyclinic.id,
          );
          final matched = schedulesOfPoly.where(
            (s) => s.id == existingQueue.doctorScheduleId,
          );
          if (matched.isNotEmpty) {
            existingSchedule = matched.first;
          }
        } catch (e, stack) {
          AppLogger.error(
            'Gagal mengambil jadwal cadangan secara dinamis',
            error: e,
            stackTrace: stack,
            tag: 'BookingScreen',
          );
        }
      }

      if (existingSchedule != null) {
        final startNew =
            DateTimeParser.parseMinutesOfDay(selectedSchedule.startTime) ?? 0;
        final endNew =
            DateTimeParser.parseMinutesOfDay(selectedSchedule.endTime) ?? 0;
        final startExist =
            DateTimeParser.parseMinutesOfDay(existingSchedule.startTime) ?? 0;
        final endExist =
            DateTimeParser.parseMinutesOfDay(existingSchedule.endTime) ?? 0;

        if (startNew < endExist && startExist < endNew) {
          final timeExistStr =
              "${existingSchedule.startTime.substring(0, 5)} - ${existingSchedule.endTime.substring(0, 5)}";
          _showResultDialog(
            false,
            'Pendaftaran gagal. Jam pelayanan dokter bentrok dengan antrean aktif Anda yang lain pada hari tersebut ($timeExistStr WIB).',
          );
          return;
        }
      }
    }



    // Proteksi tanggal di masa lalu atau jam praktik hari ini yang sudah terlewat (Tugas 2)
    final now = DateTime.now();
    final selectedDateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selectedDateOnly.isBefore(DateTime(now.year, now.month, now.day))) {
      _showResultDialog(false, 'Tanggal kunjungan tidak boleh di masa lalu.');
      return;
    }

    if (selectedDateStr == DateFormat('yyyy-MM-dd').format(now)) {
      final startMinutes = DateTimeParser.parseMinutesOfDay(
        selectedSchedule.startTime,
      );
      if (startMinutes == null) {
        _showResultDialog(
          false,
          'Format jam praktik dokter tidak valid. Silakan pilih jadwal lain.',
        );
        return;
      }
      final serviceStart = DateTime(
        now.year,
        now.month,
        now.day,
        startMinutes ~/ 60,
        startMinutes % 60,
      );
      if (!now.isBefore(serviceStart)) {
        _showResultDialog(
          false,
          'Pendaftaran untuk hari ini hanya bisa dilakukan sebelum jam mulai praktik dokter.',
        );
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
    });

    if (mounted) {
      if (provider.error != null) {
        String errorMsg = provider.error!;
        if (errorMsg.contains('aktif di poliklinik')) {
          errorMsg =
              'Anda sudah terdaftar pada poliklinik ini untuk tanggal terpilih. Silakan pilih tanggal lain atau cek riwayat antrean Anda.';
        }
        _showResultDialog(false, errorMsg);
      } else {
        _showResultDialog(
          true,
          'Antrean Anda telah sukses terdaftar di poliklinik!',
        );
      }
    }
  }

  int _getDayOfWeekInt(String indonesianDay) {
    switch (indonesianDay.toLowerCase()) {
      case 'senin':
        return DateTime.monday;
      case 'selasa':
        return DateTime.tuesday;
      case 'rabu':
        return DateTime.wednesday;
      case 'kamis':
        return DateTime.thursday;
      case 'jumat':
        return DateTime.friday;
      case 'sabtu':
        return DateTime.saturday;
      case 'minggu':
        return DateTime.sunday;
      default:
        return 1;
    }
  }

  DoctorModel _resolveDoctor(PatientProvider provider, ScheduleModel schedule) {
    return provider.doctors.firstWhere(
      (d) => d.id == schedule.doctorId,
      orElse: () =>
          schedule.doctor ?? DoctorModel(id: schedule.doctorId, userId: 0),
    );
  }

  bool _isBookableDate(
    DateTime date,
    ScheduleModel schedule,
    PatientProvider provider,
  ) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final isHoliday = provider.clinicHolidays.contains(dateStr);
    final isLeave = provider.doctorLeaves.contains(dateStr);
    if (isHoliday || isLeave) {
      return false;
    }

    if (date.weekday != _getDayOfWeekInt(schedule.dayOfWeek)) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      final startMinutes = DateTimeParser.parseMinutesOfDay(schedule.startTime);
      if (startMinutes == null) {
        return false;
      }
      final serviceStart = DateTime(
        today.year,
        today.month,
        today.day,
        startMinutes ~/ 60,
        startMinutes % 60,
      );
      return now.isBefore(serviceStart);
    }

    return date.isAfter(today);
  }

  DateTime? _getNearestDateForWeekday(
    ScheduleModel schedule,
    PatientProvider provider,
  ) {
    final now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    final maxDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 7));
    while (date.isBefore(maxDate) || date.isAtSameMomentAs(maxDate)) {
      if (_isBookableDate(date, schedule, provider)) {
        return date;
      }
      date = date.add(const Duration(days: 1));
    }
    return null;
  }

  String _formatIndonesianDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
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
        return duration > 0 ? (duration / 15).floor() : 10;
      }
    } catch (e, stack) {
      AppLogger.error(
        'Gagal menghitung kuota dari jam kerja',
        error: e,
        stackTrace: stack,
        tag: 'BookingScreen',
      );
    }
    return 10; // Fallback to 10 matching backend
  }

  bool _isPriorityPatient() {
    final user = context.read<AuthProvider>().user;
    if (user != null && user.birthDate != null) {
      final age = DateTime.now().difference(user.birthDate!).inDays ~/ 365.25;
      return age >= 60;
    }
    return false;
  }
}
