import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../../../shared/models/schedule_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/date_time_parser.dart';

import '../../../shared/models/doctor_model.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../widgets/admin_schedule_card.dart';
import '../widgets/admin_bottom_nav.dart';

class DoctorScheduleManagementScreen extends StatefulWidget {
  const DoctorScheduleManagementScreen({super.key});

  @override
  State<DoctorScheduleManagementScreen> createState() => _DoctorScheduleManagementScreenState();
}

class _DoctorScheduleManagementScreenState extends State<DoctorScheduleManagementScreen> {
  String? _selectedDay;
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

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
      : provider.schedules.where((s) => s.dayOfWeek == _selectedDay).toList();

    // Grouping schedules by doctorId
    final Map<int, List<ScheduleModel>> groupedSchedules = {};
    for (var schedule in schedules) {
      final docId = schedule.doctorId;
      if (!groupedSchedules.containsKey(docId)) {
        groupedSchedules[docId] = [];
      }
      groupedSchedules[docId]!.add(schedule);
    }
    final groupedKeys = groupedSchedules.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jadwal Dokter',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '${provider.schedules.length} jadwal rutin',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Day Filter Chips
                          AnimationConfiguration.staggeredList(
                            position: 1,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 30.0,
                              child: FadeInAnimation(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _filterChip(null, 'Semua Hari'),
                                      ..._days.map((day) => _filterChip(day, day)),
                                    ],
                                  ),
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
            
            const Divider(height: 1),

            // Schedule List
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.fetchSchedules,
                child: provider.isLoading && provider.schedules.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : groupedKeys.isEmpty
                        ? const Center(child: Text('Tidak ada jadwal untuk filter ini'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: groupedKeys.length,
                            itemBuilder: (context, index) {
                              final docId = groupedKeys[index];
                              final doctorSchedules = groupedSchedules[docId]!;
                              final firstSchedule = doctorSchedules.first;
                              final doctor = (firstSchedule.doctor != null && firstSchedule.doctor!.user != null)
                                  ? firstSchedule.doctor!
                                  : provider.doctors.firstWhere(
                                      (d) => d.id == firstSchedule.doctorId || d.userId == firstSchedule.doctorId,
                                      orElse: () => firstSchedule.doctor ?? DoctorModel(id: firstSchedule.doctorId, userId: 0),
                                    );
                              final name = doctor.user?.name ?? (doctor.name != 'Dokter' ? doctor.name : 'Unknown Doctor');
                              final polyName = doctor.polyclinic?.name ?? 
                                provider.polyclinics.firstWhere(
                                  (p) => p.id == doctor.polyclinicId,
                                  orElse: () => PolyclinicModel(id: 0, name: 'Tidak Ada Klinik', code: '', description: ''),
                                ).name;

                              return FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(milliseconds: 200 + (index * 80)),
                                child: AdminScheduleCard(
                                  doctorName: name,
                                  polyclinicName: polyName,
                                  schedules: doctorSchedules,
                                  onEdit: (sched) => _showScheduleForm(context, schedule: sched),
                                  onDelete: (sched) => _confirmDeleteSchedule(context, sched),
                                ),
                              );
                            },
                          ),
              ),
            ),

            // Navigation
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: const AdminBottomNav(activeIndex: 2),
            ),
          ],
        ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton(
          onPressed: () => _showScheduleForm(context),
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _filterChip(String? day, String label) {
    final isSelected = _selectedDay == day;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        )),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedDay = val ? day : null),
        selectedColor: AppTheme.primaryColor,
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }



  void _confirmDeleteSchedule(BuildContext context, ScheduleModel schedule) async {
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
    List<String> selectedDays = schedule != null ? [schedule.dayOfWeek] : [];
    TimeOfDay? startTime = schedule != null ? DateTimeParser.parseTimeOfDay(schedule.startTime) : null;
    TimeOfDay? endTime = schedule != null ? DateTimeParser.parseTimeOfDay(schedule.endTime) : null;
    bool isSaving = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = context.watch<AdminProvider>();
          return Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Doctor Selector
                  Text('Dokter', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: doctorId,
                    decoration: InputDecoration(
                      hintText: 'Pilih Dokter',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    items: provider.doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.user?.name ?? 'No Name'))).toList(),
                    onChanged: isSaving ? null : (v) => setModalState(() => doctorId = v),
                    validator: (v) => v == null ? 'Pilih dokter terlebih dahulu' : null,
                  ),
                  const SizedBox(height: 20),

                  // Day Selector
                  Text('Hari Praktik', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  FormField<List<String>>(
                    validator: (value) => selectedDays.isEmpty ? 'Pilih setidaknya satu hari' : null,
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _days.map((day) {
                              final isSelected = selectedDays.contains(day);
                              return FilterChip(
                                label: Text(day, style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                )),
                                selected: isSelected,
                                onSelected: isSaving ? null : (selected) {
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                showCheckmark: false,
                              );
                            }).toList(),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Time Slots
                  FormField<bool>(
                    validator: (value) => (startTime == null || endTime == null) ? 'Pilih waktu praktik' : null,
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Waktu Mulai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: isSaving ? null : () async {
                                        final picked = await showTimePicker(context: context, initialTime: startTime ?? TimeOfDay.now());
                                        if (picked != null) {
                                          setModalState(() => startTime = picked);
                                          state.didChange(true);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: state.hasError ? AppTheme.errorColor : Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(startTime == null ? '00:00' : startTime!.format(context), style: TextStyle(color: startTime == null ? Colors.grey : Colors.black87)),
                                            const Icon(Icons.access_time_rounded, size: 18, color: AppTheme.primaryColor),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Waktu Selesai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: isSaving ? null : () async {
                                        final picked = await showTimePicker(context: context, initialTime: endTime ?? TimeOfDay.now());
                                        if (picked != null) {
                                          setModalState(() => endTime = picked);
                                          state.didChange(true);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: state.hasError ? AppTheme.errorColor : Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(endTime == null ? '00:00' : endTime!.format(context), style: TextStyle(color: endTime == null ? Colors.grey : Colors.black87)),
                                            const Icon(Icons.access_time_rounded, size: 18, color: AppTheme.primaryColor),
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
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            if (isEdit) {
                              final confirm = await AppDialogs.showConfirmationDialog(
                                context,
                                'Batalkan Perubahan?',
                                'Apakah Anda yakin ingin membatalkan perubahan data jadwal dokter ini?',
                                confirmText: 'YA, BATALKAN',
                                cancelText: 'TETAP EDIT',
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'BATAL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : () async {
                            if (!(formKey.currentState?.validate() ?? false)) return;

                            final adminProvider = context.read<AdminProvider>();
                            
                            // 1. Validasi Durasi Positif (Tugas 4)
                            if (startTime == null || endTime == null) {
                              AppDialogs.showNotificationDialog(
                                context,
                                'Waktu Tidak Lengkap',
                                'Harap pilih waktu mulai dan selesai jadwal.',
                                isError: true,
                              );
                              return;
                            }

                            final sTime = startTime!;
                            final eTime = endTime!;
                            final startMinutes = sTime.hour * 60 + sTime.minute;
                            final endMinutes = eTime.hour * 60 + eTime.minute;
                            if (startMinutes >= endMinutes) {
                              AppDialogs.showNotificationDialog(
                                context,
                                'Jadwal Tidak Valid',
                                'Waktu mulai harus secara kronologis sebelum waktu selesai.',
                                isError: true,
                              );
                              return;
                            }

                            // 2. Validasi Tabrakan Jadwal Aktif Dokter (Tugas 5)
                            bool hasOverlap(String day, int startMin, int endMin, int? excludeId) {
                              for (var s in adminProvider.schedules) {
                                if (s.doctorId != doctorId) continue;
                                if (excludeId != null && s.id == excludeId) continue;
                                if (s.dayOfWeek.toLowerCase() == day.toLowerCase()) {
                                  try {
                                    final sStartMin = DateTimeParser.parseMinutesOfDay(s.startTime);
                                    final sEndMin = DateTimeParser.parseMinutesOfDay(s.endTime);
                                    if (sStartMin != null && sEndMin != null) {
                                      final maxStart = startMin > sStartMin ? startMin : sStartMin;
                                      final minEnd = endMin < sEndMin ? endMin : sEndMin;
                                      if (maxStart < minEnd) {
                                        return true;
                                      }
                                    }
                                  } catch (e) {
                                    debugPrint('DoctorScheduleManagementScreen: gagal cek overlap jadwal dokter: $e');
                                  }
                                }
                              }
                              return false;
                            }

                            for (var day in selectedDays) {
                              if (hasOverlap(day, startMinutes, endMinutes, isEdit ? schedule.id : null)) {
                                AppDialogs.showNotificationDialog(
                                  context,
                                  'Jadwal Bentrok',
                                  'Dokter ini sudah memiliki jadwal aktif pada hari $day di jam yang bertabrakan.',
                                  isError: true,
                                );
                                return;
                              }
                            }

                            final confirm = await AppDialogs.showConfirmationDialog(
                              context,
                              isEdit ? 'Perbarui Jadwal?' : 'Buat Jadwal Baru?',
                              isEdit 
                                  ? 'Apakah Anda yakin ingin menyimpan perubahan jadwal dokter ini?'
                                  : 'Apakah Anda yakin ingin menambahkan jadwal dokter baru ini?',
                              confirmText: isEdit ? 'YA, UPDATE' : 'YA, SIMPAN',
                              cancelText: 'BATAL',
                            );
                            if (!context.mounted) return;
                            if (!(confirm ?? false)) return;

                            setModalState(() => isSaving = true);
                            try {
                              if (startTime == null || endTime == null) {
                                if (context.mounted) {
                                  AppDialogs.showNotificationDialog(
                                    context,
                                    'Waktu Tidak Lengkap',
                                    'Waktu jadwal tidak tersedia. Silakan pilih kembali.',
                                    isError: true,
                                  );
                                }
                                return;
                              }

                              final startTimeStr = '${sTime.hour.toString().padLeft(2, '0')}:${sTime.minute.toString().padLeft(2, '0')}';
                              final endTimeStr = '${eTime.hour.toString().padLeft(2, '0')}:${eTime.minute.toString().padLeft(2, '0')}';

                              if (isEdit) {
                                if (selectedDays.isEmpty) {
                                  AppDialogs.showNotificationDialog(
                                    context,
                                    'Hari Tidak Dipilih',
                                    'Harap pilih setidaknya satu hari untuk jadwal.',
                                    isError: true,
                                  );
                                  return;
                                }

                                // Update the original schedule with the first selected day
                                final firstDay = selectedDays.first;
                                final data = {
                                  'doctor_id': doctorId,
                                  'day_of_week': firstDay,
                                  'start_time': startTimeStr,
                                  'end_time': endTimeStr,
                                };
                                await adminProvider.updateSchedule(schedule.id, data);

                                // If additional days selected, create new schedules for them
                                for (int i = 1; i < selectedDays.length; i++) {
                                  final extraDay = selectedDays[i];
                                  final extraData = {
                                    'doctor_id': doctorId,
                                    'day_of_week': extraDay,
                                    'start_time': startTimeStr,
                                    'end_time': endTimeStr,
                                  };
                                  await adminProvider.createSchedule(extraData);
                                }
                              } else {
                                // Create new schedules for each selected day
                                for (var day in selectedDays) {
                                  final data = {
                                    'doctor_id': doctorId,
                                    'day_of_week': day,
                                    'start_time': startTimeStr,
                                    'end_time': endTimeStr,
                                  };
                                  await adminProvider.createSchedule(data);
                                }
                              }

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              AppDialogs.showSuccessDialog(
                                context,
                                'Berhasil Disimpan',
                                isEdit ? 'Jadwal dokter telah berhasil diperbarui.' : 'Jadwal dokter telah berhasil dibuat.',
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(isEdit ? 'UPDATE' : 'SIMPAN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
