import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../logic/admin_provider.dart';
import '../../../../../shared/models/doctor_model.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/app_dialogs.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/utils/responsive_helper.dart';

class AdminDoctorFormSheet {
  static void show(BuildContext context, {DoctorModel? doctor}) {
    final isEdit = doctor != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: doctor?.user?.name);
    final emailController = TextEditingController(text: doctor?.user?.email);
    final passwordController = TextEditingController();
    final specController = TextEditingController(text: doctor?.specialization);
    final licenseController = TextEditingController(text: doctor?.licenseNumber);
    final phoneController = TextEditingController(text: doctor?.user?.phone);
    final addressController = TextEditingController(text: doctor?.user?.address);
    final nikController = TextEditingController(text: doctor?.user?.nationalId);
    String? selectedGender = doctor?.user?.gender ?? 'Laki-laki';
    DateTime? selectedBirthDate = doctor?.user?.birthDate;
    int? selectedPolyclinicId = doctor?.polyclinicId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> selectBirthDate() async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedBirthDate ?? DateTime(1985),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
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
                selectedBirthDate = picked;
              });
            }
          }

          return Consumer<AdminProvider>(
            builder: (context, provider, child) {
              final sheetH = ResponsiveHelper.sheetMaxHeight(context);
              final pad    = ResponsiveHelper.paddingDialog(context);
              final headSz = ResponsiveHelper.fontSizeHeading(context);
              final btnH   = ResponsiveHelper.buttonHeight(context);
              final btnR   = ResponsiveHelper.radiusButton(context);
              return Container(
              constraints: BoxConstraints(maxHeight: sheetH),
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, MediaQuery.of(context).viewInsets.bottom + pad),
                child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                    isEdit ? 'Edit Dokter' : 'Tambah Dokter Baru', 
                    style: GoogleFonts.poppins(fontSize: headSz, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: pad),
                  TextFormField(
                    controller: nameController, 
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap', 
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.accentColor),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nama lengkap tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nikController,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    decoration: const InputDecoration(
                      labelText: 'NIK (Nomor Induk Kependudukan)', 
                      prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.accentColor),
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'NIK tidak boleh kosong';
                      if (v.trim().length != 16) return 'NIK harus terdiri dari 16 digit';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!isEdit) ...[
                    TextFormField(
                      controller: emailController, 
                      decoration: const InputDecoration(
                        labelText: 'Email', 
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.accentColor),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController, 
                      decoration: const InputDecoration(
                        labelText: 'Kata Sandi', 
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.accentColor),
                      ), 
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  DropdownButtonFormField<int>(
                    initialValue: selectedPolyclinicId,
                    decoration: const InputDecoration(
                      labelText: 'Layanan Poliklinik',
                      prefixIcon: Icon(Icons.local_hospital_outlined, color: AppTheme.accentColor),
                    ),
                    hint: const Text('Pilih Poliklinik'),
                    items: provider.polyclinics.map((poly) {
                      return DropdownMenuItem<int>(
                        value: poly.id,
                        child: Text(poly.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedPolyclinicId = val;
                      });
                    },
                    validator: (v) => v == null ? 'Pilih Poliklinik terlebih dahulu!' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: specController, 
                    decoration: const InputDecoration(
                      labelText: 'Spesialisasi', 
                      prefixIcon: Icon(Icons.star_outline_rounded, color: AppTheme.accentColor),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Spesialisasi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: licenseController, 
                    decoration: const InputDecoration(
                      labelText: 'Nomor SIP/Lisensi', 
                      prefixIcon: Icon(Icons.card_membership_outlined, color: AppTheme.accentColor),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nomor SIP / Lisensi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedGender,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.primaryColor),
                          decoration: InputDecoration(
                            labelText: 'Jenis Kelamin',
                            prefixIcon:
                                const Icon(Icons.wc_rounded, color: AppTheme.accentColor,),
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFFCDE8DE),
                                  width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFFCDE8DE),
                                  width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppTheme.accentColor,
                                  width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppTheme.errorColor,
                                  width: 1.5),
                            ),
                          ),
                          items: ['Laki-laki', 'Perempuan']
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedGender = val),
                          validator: (v) => v == null
                              ? 'Pilih jenis kelamin'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: FormField<DateTime>(
                          validator: (_) => selectedBirthDate == null
                              ? 'Pilih tanggal lahir'
                              : null,
                          builder: (state) => Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await selectBirthDate();
                                  state.didChange(selectedBirthDate);
                                },
                                borderRadius:
                                    BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.9),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    border: Border.all(
                                      color: state.hasError
                                          ? AppTheme.errorColor
                                          : const Color(0xFFCDE8DE),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: AppTheme.accentColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedBirthDate == null
                                              ? 'Tgl Lahir'
                                              : DateFormat('dd/MM/yy')
                                                  .format(
                                                      selectedBirthDate!),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: selectedBirthDate ==
                                                    null
                                                ? Colors.grey.shade400
                                                : AppTheme.primaryColor,
                                            fontWeight:
                                                selectedBirthDate ==
                                                        null
                                                    ? FontWeight.w400
                                                    : FontWeight.w600,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (state.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 6, left: 4),
                                  child: Text(
                                    state.errorText!,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.errorColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController, 
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP (Opsional)', 
                      prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.accentColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController, 
                    decoration: const InputDecoration(
                      labelText: 'Alamat (Opsional)', 
                      prefixIcon: Icon(Icons.location_on_outlined,color: AppTheme.accentColor),
                    ),
                  ),
                  SizedBox(height: pad),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            bool shouldShowConfirm = false;
                            if (isEdit) {
                              shouldShowConfirm = nameController.text.trim() != (doctor.user?.name ?? '') ||
                                  nikController.text.trim() != (doctor.user?.nationalId ?? '') ||
                                  specController.text.trim() != (doctor.specialization ?? '') ||
                                  licenseController.text.trim() != (doctor.licenseNumber ?? '') ||
                                  phoneController.text.trim() != (doctor.user?.phone ?? '') ||
                                  addressController.text.trim() != (doctor.user?.address ?? '') ||
                                  selectedGender != (doctor.user?.gender ?? 'Laki-laki') ||
                                  selectedBirthDate != doctor.user?.birthDate ||
                                  selectedPolyclinicId != doctor.polyclinicId;
                            } else {
                              shouldShowConfirm = nameController.text.trim().isNotEmpty ||
                                  nikController.text.trim().isNotEmpty ||
                                  emailController.text.trim().isNotEmpty ||
                                  passwordController.text.isNotEmpty ||
                                  specController.text.trim().isNotEmpty ||
                                  licenseController.text.trim().isNotEmpty ||
                                  phoneController.text.trim().isNotEmpty ||
                                  addressController.text.trim().isNotEmpty ||
                                  selectedBirthDate != null ||
                                  selectedPolyclinicId != null;
                            }
                            if (shouldShowConfirm) {
                              final confirm = await AppDialogs.showConfirmationDialog(
                                context,
                                'Batalkan Perubahan?',
                                'Apakah Anda yakin ingin membatalkan pengisian/perubahan data dokter ini?',
                                confirmText: 'Batalkan',
                                cancelText: 'Tetap Edit',
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
                            minimumSize: Size(double.infinity, btnH),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(btnR),
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
                          onPressed: provider.isLoading ? null : () async {
                            if (!formKey.currentState!.validate()) return;
                            
                            final confirm = await AppDialogs.showConfirmationDialog(
                              context,
                              isEdit ? 'Perbarui Data Dokter?' : 'Simpan Dokter Baru?',
                              isEdit 
                                  ? 'Apakah Anda yakin ingin menyimpan perubahan data dokter ini?'
                                  : 'Apakah Anda yakin ingin menambahkan dokter baru ini?',
                              confirmText: isEdit ? 'Perbarui' : 'Simpan',
                              cancelText: 'Batal',
                            );
                            if (!(confirm ?? false)) return;

                            final data = {
                              'name': nameController.text.trim(),
                              'specialization': specController.text.trim(),
                              'license_number': licenseController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'address': addressController.text.trim(),
                              'polyclinic_id': selectedPolyclinicId,
                              'national_id': nikController.text.trim(),
                              'gender': selectedGender,
                              'birth_date': selectedBirthDate != null 
                                  ? DateFormat('yyyy-MM-dd').format(selectedBirthDate!) 
                                  : null,
                            };
                            if (!isEdit) {
                              data['email'] = emailController.text.trim();
                              data['password'] = passwordController.text;
                            }
                            
                            if (isEdit) {
                              await provider.updateDoctor(doctor.id, data);
                            } else {
                              await provider.createDoctor(data);
                            }
                            
                            if (context.mounted) {
                              if (provider.error != null) {
                                AppDialogs.showNotificationDialog(
                                  context,
                                  'Gagal',
                                  provider.error!,
                                  isError: true,
                                );
                              } else {
                                Navigator.pop(context);
                                AppDialogs.showSuccessDialog(
                                  context,
                                  'Berhasil Disimpan',
                                  isEdit 
                                      ? 'Data dokter ${nameController.text} telah berhasil diperbarui.'
                                      : 'Dokter baru ${nameController.text} telah berhasil ditambahkan.',
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: Size(double.infinity, btnH),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(btnR)),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                isEdit ? 'Perbarui' : 'Simpan', 
                                style: GoogleFonts.poppins(
                                  color: Colors.white, fontWeight: FontWeight.bold)
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
    },
  );
},
),
);
  }
}
