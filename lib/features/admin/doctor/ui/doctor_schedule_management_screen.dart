import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/admin_provider.dart';
import '../../../../shared/models/schedule_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/date_time_parser.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../shared/models/doctor_model.dart';
import '../../../../shared/models/polyclinic_model.dart';
import '../widgets/admin_schedule_card.dart';

class DoctorScheduleManagementScreen extends StatefulWidget {
  const DoctorScheduleManagementScreen({super.key});

  @override
  State<DoctorScheduleManagementScreen> createState() =>
      _DoctorScheduleManagementScreenState();
}

class _DoctorScheduleManagementScreenState
    extends State<DoctorScheduleManagementScreen> {
  String? _selectedDay;
  final List<String> _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchSchedules();
      context.read<AdminProvider>().fetchDoctors();
      context.read<AdminProvider>().fetchPolyclinics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final schedules = _selectedDay == null
        ? provider.schedules
        : provider.schedules
            .where((s) => s.dayOfWeek == _selectedDay)
            .toList();

    final Map<int, List<ScheduleModel>> groupedSchedules = {};
    for (var schedule in schedules) {
      final docId = schedule.doctorId;
      groupedSchedules.putIfAbsent(docId, () => []).add(schedule);
    }
    final groupedKeys = groupedSchedules.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: ResponsiveCenter(
        maxWidth: 950,
        child: Column(
          children: [
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacementNamed(
                                        context, '/admin/home');
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jadwal Dokter',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kelola jadwal praktik dokter',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filterChip(null, 'Semua'),
                              ..._days.map((day) => _filterChip(day, day)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.fetchSchedules,
                child: provider.isLoading && provider.schedules.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : groupedKeys.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.5,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32),
                              child: FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _selectedDay != null
                                            ? Icons.search_off_rounded
                                            : Icons.calendar_month_outlined,
                                        size: 64,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _selectedDay != null
                                          ? 'Jadwal Tidak Ditemukan'
                                          : 'Tidak Ada Jadwal Dokter',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _selectedDay != null
                                          ? 'Belum ada jadwal dokter pada hari $_selectedDay.'
                                          : 'Belum ada jadwal dokter yang terdaftar.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (_selectedDay != null) ...[
                                      const SizedBox(height: 24),
                                      OutlinedButton.icon(
                                        onPressed: () => setState(
                                            () => _selectedDay = null),
                                        icon: const Icon(
                                            Icons.refresh_rounded,
                                            size: 18),
                                        label: Text(
                                          'Reset Filter',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppTheme.primaryColor,
                                          side: BorderSide(
                                              color: AppTheme.primaryColor
                                                  .withValues(alpha: 0.5)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: groupedKeys.length,
                            itemBuilder: (context, index) {
                              final docId = groupedKeys[index];
                              final doctorSchedules =
                                  groupedSchedules[docId]!;
                              final firstSchedule = doctorSchedules.first;
                              final doctor = (firstSchedule.doctor != null &&
                                      firstSchedule.doctor!.user != null)
                                  ? firstSchedule.doctor!
                                  : provider.doctors.firstWhere(
                                      (d) =>
                                          d.id == firstSchedule.doctorId ||
                                          d.userId == firstSchedule.doctorId,
                                      orElse: () =>
                                          firstSchedule.doctor ??
                                          DoctorModel(
                                              id: firstSchedule.doctorId,
                                              userId: 0),
                                    );
                              final name = doctor.user?.name ??
                                  (doctor.name != 'Dokter'
                                      ? doctor.name
                                      : 'Unknown Doctor');
                              final polyName = doctor.polyclinic?.name ??
                                  provider.polyclinics
                                      .firstWhere(
                                        (p) => p.id == doctor.polyclinicId,
                                        orElse: () => PolyclinicModel(
                                            id: 0,
                                            name: 'Tidak Ada Klinik',
                                            code: '',
                                            description: ''),
                                      )
                                      .name;

                              return FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(
                                    milliseconds: 200 + (index * 80)),
                                child: AdminScheduleCard(
                                  doctorName: name,
                                  polyclinicName: polyName,
                                  schedules: doctorSchedules,
                                  onEdit: (sched) => _showScheduleForm(
                                      context,
                                      schedule: sched),
                                  onDelete: (sched) =>
                                      _confirmDeleteSchedule(context, sched),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleForm(context),
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.more_time_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Buat Jadwal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String? day, String label) {
    final isSelected = _selectedDay == day;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(
            () => _selectedDay = isSelected ? null : day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppTheme.primaryColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSchedule(
      BuildContext context, ScheduleModel schedule) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Hapus Jadwal',
      'Hapus jadwal untuk ${schedule.doctor?.user?.name} pada hari ${schedule.dayOfWeek}?',
      confirmText: 'HAPUS',
      isDestructive: true,
    );
    if (!context.mounted) return;
    if ((confirm ?? false) && context.mounted) {
      await context.read<AdminProvider>().deleteSchedule(schedule.id);
    }
  }

  void _showScheduleForm(BuildContext context, {ScheduleModel? schedule}) {
    final isEdit = schedule != null;
    int? doctorId = schedule?.doctorId;
    List<String> selectedDays =
        schedule != null ? [schedule.dayOfWeek] : [];
    TimeOfDay? startTime = schedule != null
        ? DateTimeParser.parseTimeOfDay(schedule.startTime)
        : null;
    TimeOfDay? endTime = schedule != null
        ? DateTimeParser.parseTimeOfDay(schedule.endTime)
        : null;
    bool isSaving = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = context.watch<AdminProvider>();
          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEdit ? 'Edit Jadwal Dokter' : 'Buat Jadwal Dokter',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Dokter',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: doctorId,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppTheme.primaryColor),
                      decoration: InputDecoration(
                        hintText: 'Pilih Dokter',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                      ),
                      items: provider.doctors
                          .map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.user?.name ?? 'No Name',
                                  style: GoogleFonts.poppins(fontSize: 14))))
                          .toList(),
                      onChanged:
                          isSaving ? null : (v) => setModalState(() => doctorId = v),
                      validator: (v) =>
                          v == null ? 'Pilih dokter terlebih dahulu' : null,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Hari Praktik',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    FormField<List<String>>(
                      validator: (value) => selectedDays.isEmpty
                          ? 'Pilih setidaknya satu hari'
                          : null,
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _days.map((day) {
                              final isSelected = selectedDays.contains(day);
                              return FilterChip(
                                label: Text(
                                  day,
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: isSaving
                                    ? null
                                    : (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            selectedDays.add(day);
                                          } else {
                                            selectedDays.remove(day);
                                          }
                                        });
                                        state.didChange(selectedDays);
                                      },
                                selectedColor: AppTheme.primaryColor,
                                backgroundColor: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                showCheckmark: false,
                              );
                            }).toList(),
                          ),
                          if (state.hasError)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                state.errorText!,
                                style: GoogleFonts.poppins(
                                    color: AppTheme.errorColor, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    FormField<bool>(
                      validator: (value) =>
                          (startTime == null || endTime == null)
                              ? 'Pilih waktu praktik'
                              : null,
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Waktu Mulai',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: isSaving
                                          ? null
                                          : () async {
                                              final picked =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: startTime ??
                                                    TimeOfDay.now(),
                                              );
                                              if (picked != null) {
                                                setModalState(
                                                    () => startTime = picked);
                                                state.didChange(true);
                                              }
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: state.hasError
                                                  ? AppTheme.errorColor
                                                  : Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              startTime == null
                                                  ? '00:00'
                                                  : startTime!
                                                      .format(context),
                                              style: GoogleFonts.poppins(
                                                color: startTime == null
                                                    ? Colors.grey
                                                    : AppTheme.primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Icon(
                                                Icons.access_time_rounded,
                                                size: 18,
                                                color: AppTheme.primaryColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Waktu Selesai',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: isSaving
                                          ? null
                                          : () async {
                                              final picked =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: endTime ??
                                                    TimeOfDay.now(),
                                              );
                                              if (picked != null) {
                                                setModalState(
                                                    () => endTime = picked);
                                                state.didChange(true);
                                              }
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: state.hasError
                                                  ? AppTheme.errorColor
                                                  : Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              endTime == null
                                                  ? '00:00'
                                                  : endTime!.format(context),
                                              style: GoogleFonts.poppins(
                                                color: endTime == null
                                                    ? Colors.grey
                                                    : AppTheme.primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Icon(
                                                Icons.access_time_rounded,
                                                size: 18,
                                                color: AppTheme.primaryColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (state.hasError)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                state.errorText!,
                                style: GoogleFonts.poppins(
                                    color: AppTheme.errorColor, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              bool shouldShowConfirm = false;
                              if (isEdit) {
                                shouldShowConfirm =
                                    doctorId != schedule.doctorId ||
                                        selectedDays.length != 1 ||
                                        !selectedDays
                                            .contains(schedule.dayOfWeek) ||
                                        startTime !=
                                            DateTimeParser.parseTimeOfDay(
                                                schedule.startTime) ||
                                        endTime !=
                                            DateTimeParser.parseTimeOfDay(
                                                schedule.endTime);
                              } else {
                                shouldShowConfirm = doctorId != null ||
                                    selectedDays.isNotEmpty ||
                                    startTime != null ||
                                    endTime != null;
                              }
                              if (shouldShowConfirm) {
                                final confirm =
                                    await AppDialogs.showConfirmationDialog(
                                  context,
                                  'Batalkan Perubahan?',
                                  'Apakah Anda yakin ingin membatalkan perubahan?',
                                  confirmText: 'Batalkan',
                                  cancelText: 'Tetap Edit',
                                  isDestructive: true,
                                );
                                if (!context.mounted) return;
                                if ((confirm ?? false) && context.mounted) {
                                  Navigator.pop(context);
                                }
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (!(formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    final adminProvider =
                                        context.read<AdminProvider>();

                                    if (startTime == null ||
                                        endTime == null) {
                                      AppDialogs.showNotificationDialog(
                                        context,
                                        'Waktu Tidak Lengkap',
                                        'Harap pilih waktu mulai dan selesai.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    final sTime = startTime!;
                                    final eTime = endTime!;
                                    final startMinutes =
                                        sTime.hour * 60 + sTime.minute;
                                    final endMinutes =
                                        eTime.hour * 60 + eTime.minute;

                                    if (startMinutes >= endMinutes) {
                                      AppDialogs.showNotificationDialog(
                                        context,
                                        'Jadwal Tidak Valid',
                                        'Waktu mulai harus sebelum waktu selesai.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    bool hasOverlap(String day, int startMin,
                                        int endMin, int? excludeId) {
                                      for (var s
                                          in adminProvider.schedules) {
                                        if (s.doctorId != doctorId) continue;
                                        if (excludeId != null &&
                                            s.id == excludeId) {
                                          continue;
                                        }
                                        if (s.dayOfWeek.toLowerCase() ==
                                            day.toLowerCase()) {
                                          try {
                                            final sStartMin =
                                                DateTimeParser.parseMinutesOfDay(
                                                    s.startTime);
                                            final sEndMin =
                                                DateTimeParser.parseMinutesOfDay(
                                                    s.endTime);
                                            if (sStartMin != null &&
                                                sEndMin != null) {
                                              final maxStart =
                                                  startMin > sStartMin
                                                      ? startMin
                                                      : sStartMin;
                                              final minEnd = endMin < sEndMin
                                                  ? endMin
                                                  : sEndMin;
                                              if (maxStart < minEnd) {
                                                return true;
                                              }
                                            }
                                          } catch (e) {
                                            debugPrint(
                                                'Overlap check error: $e');
                                          }
                                        }
                                      }
                                      return false;
                                    }

                                    for (var day in selectedDays) {
                                      if (hasOverlap(
                                          day,
                                          startMinutes,
                                          endMinutes,
                                          isEdit ? schedule.id : null)) {
                                        AppDialogs.showNotificationDialog(
                                          context,
                                          'Jadwal Bentrok',
                                          'Dokter ini sudah memiliki jadwal pada hari $day di jam yang bertabrakan.',
                                          isError: true,
                                        );
                                        return;
                                      }
                                    }

                                    final confirm =
                                        await AppDialogs.showConfirmationDialog(
                                      context,
                                      isEdit
                                          ? 'Perbarui Jadwal?'
                                          : 'Buat Jadwal Baru?',
                                      isEdit
                                          ? 'Simpan perubahan jadwal dokter ini?'
                                          : 'Tambahkan jadwal dokter baru ini?',
                                      confirmText:
                                          isEdit ? 'Ya, Perbarui' : 'Ya, Simpan',
                                      cancelText: 'Batal',
                                    );
                                    if (!context.mounted) return;
                                    if (!(confirm ?? false)) return;

                                    setModalState(() => isSaving = true);
                                    try {
                                      final startTimeStr =
                                          '${sTime.hour.toString().padLeft(2, '0')}:${sTime.minute.toString().padLeft(2, '0')}';
                                      final endTimeStr =
                                          '${eTime.hour.toString().padLeft(2, '0')}:${eTime.minute.toString().padLeft(2, '0')}';

                                      if (isEdit) {
                                        final firstDay = selectedDays.first;
                                        await adminProvider.updateSchedule(
                                            schedule.id, {
                                          'doctor_id': doctorId,
                                          'day_of_week': firstDay,
                                          'start_time': startTimeStr,
                                          'end_time': endTimeStr,
                                        });
                                        for (int i = 1;
                                            i < selectedDays.length;
                                            i++) {
                                          await adminProvider.createSchedule({
                                            'doctor_id': doctorId,
                                            'day_of_week': selectedDays[i],
                                            'start_time': startTimeStr,
                                            'end_time': endTimeStr,
                                          });
                                        }
                                      } else {
                                        for (var day in selectedDays) {
                                          await adminProvider.createSchedule({
                                            'doctor_id': doctorId,
                                            'day_of_week': day,
                                            'start_time': startTimeStr,
                                            'end_time': endTimeStr,
                                          });
                                        }
                                      }

                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                      AppDialogs.showSuccessDialog(
                                        context,
                                        'Berhasil Disimpan',
                                        isEdit
                                            ? 'Jadwal dokter telah berhasil diperbarui.'
                                            : 'Jadwal dokter telah berhasil dibuat.',
                                      );
                                    } catch (e) {
                                      if (context.mounted) {
                                        AppDialogs.showNotificationDialog(
                                          context,
                                          'Gagal',
                                          'Error: $e',
                                          isError: true,
                                        );
                                      }
                                    } finally {
                                      setModalState(() => isSaving = false);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)),
                                    ),
                                  ),
                                  child: provider.isLoading 
                                      ? const SizedBox(
                                        height: 20, 
                                        width: 20, 
                                        child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                      : Text(
                                        isEdit ? 'Perbarui' : 'Simpan', 
                                        style: GoogleFonts.poppins(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}