import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/doctor_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../widgets/doctor_medical_history_card.dart';
import '../widgets/doctor_patient_info_card.dart';
import '../widgets/doctor_medical_text_area.dart';
import '../widgets/doctor_medicine_form.dart';
import '../../../../core/utils/responsive_helper.dart';

class ExaminationFormScreen extends StatefulWidget {
  const ExaminationFormScreen({super.key});

  @override
  State<ExaminationFormScreen> createState() => _ExaminationFormScreenState();
}

class _ExaminationFormScreenState extends State<ExaminationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentNotesController = TextEditingController(); // Notes

  // Structured medicines list for Opsi 3
  final List<Map<String, dynamic>> _medicines = [];
  bool _isSubmitting = false;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().addListener(_onDoctorError);
    });
  }

  @override
  void dispose() {
    context.read<DoctorProvider>().removeListener(_onDoctorError);
    _complaintController.dispose();
    _diagnosisController.dispose();
    _treatmentNotesController.dispose();
    super.dispose();
  }

  void _onDoctorError() {
    final error = context.read<DoctorProvider>().error;
    if (error != null && mounted) {
      AppDialogs.showNotificationDialog(
        context,
        'Terjadi Kesalahan',
        error,
        isError: true,
      );
    }
  }



  void _submit(QueueModel queue) async {
    if (_isSubmitting) return;

    final doctorId = context.read<AuthProvider>().user?.doctorId;
    if (doctorId == null) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Terjadi Kesalahan',
          'Data dokter tidak ditemukan. Akun Anda tidak terdaftar sebagai dokter.',
          isError: true,
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<DoctorProvider>();
      
      // Refresh queues to get the latest status
      await provider.fetchMyQueues();
      final freshQueue = provider.queues.where((q) => q.id == queue.id).firstOrNull;

        if (freshQueue == null || freshQueue.status.isTerminal) {
        if (mounted) {
          AppDialogs.showNotificationDialog(
            context,
            'Antrean Tidak Valid',
            'Pemeriksaan tidak dapat disimpan karena status antrean ini sudah selesai atau telah dibatalkan.',
            isError: true,
          );
        }
        return;
      }

      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      // Format the treatment text to be perfectly readable and 100% DB compatible (Opsi 3)
      String formattedTreatment = "";
      if (_treatmentNotesController.text.isNotEmpty) {
        formattedTreatment += "📋 Catatan Tindakan:\n${_treatmentNotesController.text}";
      }
      
      if (_medicines.isNotEmpty) {
        if (formattedTreatment.isNotEmpty) formattedTreatment += "\n\n";
        formattedTreatment += "💊 Resep Obat:\n";
        formattedTreatment += _medicines.map((m) {
          return "- ${m['name']} (${m['qty']} Tab) - ${m['dose']}";
        }).join("\n");
      }

      // Map Flutter _medicines structure to backend prescription_items format
      final List<Map<String, dynamic>> prescriptionItems = _medicines.map((m) {
        return {
          'medicine_id': m['medicine_id'],
          'quantity': int.tryParse(m['qty'].toString()) ?? 1,
          'instruction': m['dose'],
        };
      }).toList();

      await provider.finishExamination({
        'queue_id': freshQueue.id,
        'doctor_id': doctorId,
        'complaint': _complaintController.text,
        'diagnosis': _diagnosisController.text,
        'treatment': formattedTreatment,
        'prescription_items': prescriptionItems,
      });

      if (mounted && provider.error == null) {
        AppDialogs.showSuccessDialog(
          context,
          'Berhasil',
          'Pemeriksaan berhasil disimpan & diselesaikan',
          onOkPressed: () {
            Navigator.pop(context);
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMedicalHistoryBottomSheet(BuildContext context, int patientUserId, String patientName) {
    // Fetch EMR history before showing bottom sheet
    context.read<DoctorProvider>().fetchHistoryForPatient(patientUserId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rekam Medis (EMR)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Riwayat pemeriksaan $patientName',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  Expanded(
                    child: Consumer<DoctorProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (provider.patientHistory.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum Ada Riwayat Kunjungan',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ini adalah kunjungan pemeriksaan pertama pasien di rumah sakit ini.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.all(24),
                          itemCount: provider.patientHistory.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final exam = provider.patientHistory[index];
                            final dateStr = exam.createdAt != null 
                                ? '${exam.createdAt!.day}/${exam.createdAt!.month}/${exam.createdAt!.year}' 
                                : '-';

                            return DoctorMedicalHistoryCard(
                              examination: exam,
                              formattedDate: dateStr,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final queue = ModalRoute.of(context)!.settings.arguments as QueueModel;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
          // Header Screen
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          onPressed: () async {
                            final hasValue = _complaintController.text.trim().isNotEmpty ||
                                _diagnosisController.text.trim().isNotEmpty ||
                                _treatmentNotesController.text.trim().isNotEmpty ||
                                _medicines.isNotEmpty;
                            if (hasValue) {
                              final confirm = await AppDialogs.showConfirmationDialog(
                                context,
                                'Batalkan Pemeriksaan?',
                                'Apakah Anda yakin ingin keluar? Seluruh data pemeriksaan yang telah diisi akan hilang.',
                                confirmText: 'YA, KELUAR',
                                cancelText: 'TETAP DI SINI',
                                isDestructive: true,
                              );
                              if ((confirm ?? false) && context.mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Pemeriksaan Medis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Info Card with EMR button
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: DoctorPatientInfoCard(
                      queue: queue,
                      onViewEMR: () => _showMedicalHistoryBottomSheet(context, queue.patient.userId, queue.patient.fullName),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Fields Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DoctorMedicalTextArea(
                            label: 'Keluhan Utama Pasien',
                            placeholder: 'Contoh: Kepala pusing dan demam sejak 2 hari...',
                            controller: _complaintController,
                            maxLines: 3,
                            validator: (v) => v == null || v.isEmpty ? 'Keluhan Utama tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 20),
                          DoctorMedicalTextArea(
                            label: 'Diagnosa Medis',
                            placeholder: 'Contoh: Influenza / Hipertensi stadium 1...',
                            controller: _diagnosisController,
                            maxLines: 3,
                            validator: (v) => v == null || v.isEmpty ? 'Diagnosa Medis tidak boleh kosong' : null,
                          ),
                        const SizedBox(height: 24),
                        
                        // Structured Medicine Input
                        DoctorMedicineForm(
                          medicines: _medicines,
                          onMedicinesChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                        
                        // Non-medicine Treatment Notes
                        FormField<bool>(
                          validator: (value) {
                            if (_medicines.isEmpty && _treatmentNotesController.text.trim().isEmpty) {
                              return 'Harap masukkan Catatan Tindakan atau minimal satu Resep Obat';
                            }
                            return null;
                          },
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DoctorMedicalTextArea(
                                  label: 'Catatan Tindakan Medis (Opsional)',
                                  placeholder: 'Contoh: Edukasi untuk kurangi garam, istirahat tirah baring...',
                                  controller: _treatmentNotesController,
                                  maxLines: 3,
                                  onChanged: (val) => state.didChange(true), // Trigger re-evaluation
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
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Submit Button
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Consumer<DoctorProvider>(
                      builder: (context, provider, _) {
                        return ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : () => _submit(queue),
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save_rounded, color: Colors.white),
                          label: Text(
                            provider.isLoading ? 'Menyimpan...' : 'Selesai & Simpan Pemeriksaan',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context))),
                            elevation: 0,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }



}
