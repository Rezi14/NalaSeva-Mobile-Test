import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../logic/admin_provider.dart';
import '../../polyclinic/widgets/admin_clinic_holiday_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/date_time_parser.dart';
import '../../../../core/utils/responsive_helper.dart';

class AdminClinicHolidaysScreen extends StatefulWidget {
  const AdminClinicHolidaysScreen({super.key});

  @override
  State<AdminClinicHolidaysScreen> createState() => _AdminClinicHolidaysScreenState();
}

class _LoginInputDecoration {
  static InputDecoration get({required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
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

class _AdminClinicHolidaysScreenState extends State<AdminClinicHolidaysScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchClinicHolidays();
    });
  }

  void _showAddHolidaySheet(BuildContext context) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final descriptionController = TextEditingController();
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
                left: ResponsiveHelper.paddingDialog(context),
                right: ResponsiveHelper.paddingDialog(context),
                top: ResponsiveHelper.paddingDialog(context),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tambah Hari Libur',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih Tanggal Libur',
                        style: GoogleFonts.poppins(
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
                                style: GoogleFonts.poppins(
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
                        'Deskripsi / Keterangan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descriptionController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: _LoginInputDecoration.get(
                          hintText: 'Contoh: Libur Nasional Idul Fitri',
                          icon: Icons.description_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Keterangan libur harus diisi';
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
                                final hasValue = descriptionController.text.trim().isNotEmpty;
                                if (hasValue) {
                                  final confirm = await AppDialogs.showConfirmationDialog(
                                    context,
                                    'Batalkan Hari Libur?',
                                    'Apakah Anda yakin ingin membatalkan pengisian data hari libur ini?',
                                    confirmText: 'Batalkan',
                                    cancelText: 'Kembali',
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
                                minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: GoogleFonts.poppins(
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
                                        'Tambah Hari Libur?',
                                        'Apakah Anda yakin ingin menyimpan hari libur operasional klinik ini?',
                                        confirmText: 'Simpan',
                                        cancelText: 'Batal',
                                      );
                                      if (!(confirm ?? false)) return;

                                      setModalState(() => isSaving = true);
                                      try {
                                        final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
                                        await provider.addClinicHoliday(
                                          formattedDate,
                                          descriptionController.text.trim(),
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          AppDialogs.showSuccessDialog(
                                            context,
                                            'Berhasil Disimpan',
                                            'Hari libur operasional klinik telah berhasil ditambahkan.',
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
                                minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context))),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Simpan',
                                      style: GoogleFonts.poppins(
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

  Future<void> _deleteHoliday(BuildContext context, Map<String, dynamic> holiday) async {
    final holidayId = int.tryParse(holiday['id']?.toString() ?? '');
    if (holidayId == null) return;

    final description = holiday['description']?.toString() ?? 'hari libur ini';
    final provider = context.read<AdminProvider>();
    final confirmed = await AppDialogs.showConfirmationDialog(
      context,
      'Hapus Hari Libur?',
      'Apakah Anda yakin ingin menghapus "$description"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );
    if (!(confirmed ?? false) || !context.mounted) return;

    await provider.removeClinicHoliday(holidayId);
    if (context.mounted) {
      if (provider.error != null) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal',
          provider.error!,
          isError: true,
        );
      } else {
        AppDialogs.showSuccessDialog(
          context,
          'Berhasil Dihapus',
          'Hari libur telah berhasil dihapus.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    return Scaffold(
      backgroundColor: Colors.white, 
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient, 
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
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Libur Puskesmas',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, 
                                ),
                              ),
                              Text(
                                'Kelola libur operasional klinik',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8), 
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
              child: provider.isLoading && provider.clinicHolidays.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : provider.clinicHolidays.isEmpty
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
                                        Icons.event_available_rounded,
                                        size: 72,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Tidak Ada Hari Libur',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Puskesmas buka penuh untuk melayani pasien.',
                                      style: GoogleFonts.poppins(
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
                          onRefresh: () => provider.fetchClinicHolidays(),
                          child: AnimationLimiter(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: provider.clinicHolidays.length,
                              itemBuilder: (context, index) {
                                final holiday = provider.clinicHolidays[index];
                                final dateStr = holiday['holiday_date']?.toString() ?? '';
                                
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
                                      child: AdminClinicHolidayCard(
                                        holiday: holiday,
                                        formattedDate: formattedDate,
                                        onDelete: () => _deleteHoliday(context, holiday),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHolidaySheet(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_today_rounded, size: 20),
        label: Text(
          'Tambah Libur', 
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}