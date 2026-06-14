import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../logic/admin_provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/app_dialogs.dart';
import '../../../../../core/utils/responsive_helper.dart';

class AdminPatientFormSheet {
  static void show(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final nikController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    String? selectedGender;
    DateTime? selectedBirthDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> selectBirthDate() async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedBirthDate ?? DateTime(1995),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppTheme.primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => selectedBirthDate = picked);
          }

          return Consumer<AdminProvider>(
            builder: (context, provider, child) {
              final sheetH = ResponsiveHelper.sheetMaxHeight(context);
              final pad = ResponsiveHelper.paddingDialog(context);
              final headSz = ResponsiveHelper.fontSizeHeading(context);
              final btnH = ResponsiveHelper.buttonHeight(context);
              final btnR = ResponsiveHelper.radiusButton(context);

              return Container(
                constraints: BoxConstraints(maxHeight: sheetH),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, pad, pad,
                      MediaQuery.of(context).viewInsets.bottom + pad),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Registrasi Pasien Baru',
                            style: GoogleFonts.poppins(
                              fontSize: headSz,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: pad),

                          // Nama
                          TextFormField(
                            controller: nameController,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppTheme.primaryColor),
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap Pasien',
                              prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.accentColor,),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Nama lengkap tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // NIK
                          TextFormField(
                            controller: nikController,
                            keyboardType: TextInputType.number,
                            maxLength: 16,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppTheme.primaryColor),
                            decoration: const InputDecoration(
                              labelText: 'NIK (Nomor Induk Kependudukan)',
                              prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.accentColor,),
                              counterText: '',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'NIK tidak boleh kosong';
                              }
                              if (v.trim().length != 16) {
                                return 'NIK harus terdiri dari 16 digit';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // gender
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

                              // Tanggal Lahir
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

                          // Nomor HP
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppTheme.primaryColor),
                            decoration: const InputDecoration(
                              labelText: 'Nomor HP',
                              prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.accentColor,),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Nomor HP tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Alamat
                          TextFormField(
                            controller: addressController,
                            maxLines: 2,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppTheme.primaryColor),
                            decoration: const InputDecoration(
                              labelText: 'Alamat Pasien',
                              prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.accentColor,),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Alamat tidak boleh kosong'
                                : null,
                          ),
                          SizedBox(height: pad),

                          // btn
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final hasValue =
                                        nameController.text.trim().isNotEmpty ||
                                            nikController.text
                                                .trim()
                                                .isNotEmpty ||
                                            phoneController.text
                                                .trim()
                                                .isNotEmpty ||
                                            addressController.text
                                                .trim()
                                                .isNotEmpty ||
                                            selectedBirthDate != null;
                                    if (hasValue) {
                                      final confirm =
                                          await AppDialogs.showConfirmationDialog(
                                        context,
                                        'Batalkan Registrasi?',
                                        'Apakah Anda yakin ingin membatalkan registrasi pasien baru ini?',
                                        confirmText: 'Batalkan',
                                        cancelText: 'Kembali',
                                        isDestructive: true,
                                      );
                                      if ((confirm ?? false) &&
                                          context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey),
                                    minimumSize:
                                        Size(double.infinity, btnH),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(btnR)),
                                  ),
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          if (!formKey.currentState!
                                              .validate()) {
                                            return;
                                          }
                                          if (selectedBirthDate == null) {
                                            AppDialogs.showNotificationDialog(
                                              context,
                                              'Tanggal Lahir',
                                              'Silakan pilih tanggal lahir pasien terlebih dahulu!',
                                              isError: true,
                                            );
                                            return;
                                          }
                                          final confirm = await AppDialogs
                                              .showConfirmationDialog(
                                            context,
                                            'Daftarkan Pasien?',
                                            'Apakah Anda yakin ingin mendaftarkan pasien baru ini?',
                                            confirmText: 'Daftar',
                                            cancelText: 'Batal',
                                          );
                                          if (!(confirm ?? false)) return;

                                          final birthStr =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(selectedBirthDate!);
                                          final nik =
                                              nikController.text.trim();
                                          final data = {
                                            'name':
                                                nameController.text.trim(),
                                            'email': '$nik@nalaseva.com',
                                            'password': 'password123',
                                            'password_confirmation':
                                                'password123',
                                            'national_id': nik,
                                            'phone':
                                                phoneController.text.trim(),
                                            'gender': selectedGender,
                                            'birth_date': birthStr,
                                            'address':
                                                addressController.text.trim(),
                                            'role': 'patient',
                                          };
                                          await provider.createPatient(data);
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
                                                'Pendaftaran Berhasil',
                                                'Pasien ${nameController.text.trim()} telah terdaftar.',
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    minimumSize:
                                        Size(double.infinity, btnH),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(btnR)),
                                  ),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : Text(
                                          'Simpan',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
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