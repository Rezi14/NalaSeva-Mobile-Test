import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../logic/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/date_time_parser.dart';
import '../../../shared/models/doctor_model.dart';

class AdminDoctorLeavesScreen extends StatefulWidget {
  const AdminDoctorLeavesScreen({super.key});

  @override
  State<AdminDoctorLeavesScreen> createState() => _AdminDoctorLeavesScreenState();
}

class _LoginInputDecoration {
  static InputDecoration get({required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }
}

class _AdminDoctorLeavesScreenState extends State<AdminDoctorLeavesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchDoctorLeaves();
      provider.fetchDoctors();
    });
  }

  void _showAddLeaveSheet(BuildContext context) {
    final provider = context.read<AdminProvider>();
    if (provider.doctors.isEmpty) {
      AppDialogs.showNotificationDialog(
        context,
        'Info',
        'Belum ada dokter terdaftar untuk diajukan cuti.',
        isError: true,
      );
      return;
    }

    DoctorModel selectedDoctor = provider.doctors.first;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jadwalkan Cuti Dokter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih Dokter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DoctorModel>(
                            value: selectedDoctor,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryColor, size: 30),
                            items: provider.doctors.map((doc) {
                              return DropdownMenuItem<DoctorModel>(
                                value: doc,
                                child: Text(
                                  doc.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (DoctorModel? val) {
                              if (val != null) {
                                  setModalState(() {
                                  selectedDoctor = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tanggal Mulai Cuti',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
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
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Alasan Cuti',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: reasonController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        decoration: _LoginInputDecoration.get(
                          hintText: 'Contoh: Menghadiri Seminar Medis',
                          icon: Icons.notes_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alasan cuti harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final hasValue = reasonController.text.trim().isNotEmpty;
                                if (hasValue) {
                                  final confirm = await AppDialogs.showConfirmationDialog(
                                    context,
                                    'Batalkan Cuti Dokter?',
                                    'Apakah Anda yakin ingin membatalkan pengisian jadwal cuti ini?',
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
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;
                                      
                                      final provider = context.read<AdminProvider>();
                                      final confirm = await AppDialogs.showConfirmationDialog(
                                        context,
                                        'Jadwal Cuti Dokter?',
                                        'Apakah Anda yakin ingin mendaftarkan cuti untuk dokter ini?',
                                        confirmText: 'YA, DAFTARKAN',
                                        cancelText: 'BATAL',
                                      );
                                      if (!(confirm ?? false)) return;

                                      setModalState(() => isSaving = true);
                                      try {
                                        final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                                        await provider.addDoctorLeave(
                                          selectedDoctor.id,
                                          formattedDate,
                                          reasonController.text.trim(),
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          AppDialogs.showSuccessDialog(
                                            context,
                                            'Berhasil Disimpan',
                                            'Cuti dokter telah berhasil didaftarkan.',
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppDialogs.showNotificationDialog(
                                            context,
                                            'Gagal',
                                            e.toString(),
                                            isError: true,
                                          );
                                        }
                                      } finally {
                                        if (context.mounted) {
                                          setModalState(() => isSaving = false);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Simpan',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cuti Dokter',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Kelola jadwal cuti dokter Puskesmas',
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
          ),

          // Main list
          Expanded(
            child: provider.isLoading && provider.doctorLeaves.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : provider.doctorLeaves.isEmpty
                    ? Center(
                        child: AnimationConfiguration.staggeredList(
                          position: 0,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_off_rounded,
                                      size: 72,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Tidak Ada Dokter Cuti',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Seluruh dokter aktif bertugas di poliklinik.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.primaryColor,
                        onRefresh: () => provider.fetchDoctorLeaves(),
                        child: AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: provider.doctorLeaves.length,
                            itemBuilder: (context, index) {
                              final leave = provider.doctorLeaves[index];
                              final doctorId = int.tryParse(leave['doctor_id']?.toString() ?? '') ?? 0;
                              final dateStr = leave['leave_date']?.toString() ?? '';
                              final reason = leave['reason']?.toString() ?? 'Cuti Tahunan';
                              
                              // Find doctor info
                              DoctorModel? matchedDoctor;
                              try {
                                matchedDoctor = provider.doctors.firstWhere((d) => d.id == doctorId);
                              } catch (e) {
                                debugPrint('AdminDoctorLeavesScreen: doctor dengan id $doctorId tidak ditemukan: $e');
                              }

                              final doctorName = matchedDoctor?.name ?? 'Dokter ID: $doctorId';
                              final polyclinicName = matchedDoctor?.polyclinic?.name ?? 'Poliklinik';

                              final parsedDate = DateTimeParser.parseDateOnly(dateStr);

                              final formattedDate = parsedDate != null
                                  ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(parsedDate)
                                  : dateStr;

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.person_off_rounded,
                                                color: AppTheme.primaryColor,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    doctorName,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '$polyclinicName • $reason',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      color: Colors.grey.shade600,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    formattedDate,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      color: AppTheme.primaryColor,
                                                      fontWeight: FontWeight.bold,
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
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeaveSheet(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'JADWALKAN CUTI',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
