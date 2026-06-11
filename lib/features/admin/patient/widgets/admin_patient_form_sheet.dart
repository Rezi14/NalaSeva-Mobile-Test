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
    
    String selectedGender = 'Laki-laki';
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
                          'Registrasi Pasien Baru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: headSz,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: pad),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap Pasien',
                            prefixIcon: Icon(Icons.person_outline_rounded),
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
                            prefixIcon: Icon(Icons.badge_outlined),
                            counterText: '',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'NIK tidak boleh kosong';
                            if (v.trim().length != 16) return 'NIK harus terdiri dari 16 digit';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Jenis Kelamin',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => selectedGender = 'Laki-laki'),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: selectedGender == 'Laki-laki' ? AppTheme.primaryColor : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Laki-laki',
                                                style: TextStyle(
                                                  color: selectedGender == 'Laki-laki' ? Colors.white : Colors.black87,
                                                  fontWeight: selectedGender == 'Laki-laki' ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => selectedGender = 'Perempuan'),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: selectedGender == 'Perempuan' ? AppTheme.primaryColor : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Perempuan',
                                                style: TextStyle(
                                                  color: selectedGender == 'Perempuan' ? Colors.white : Colors.black87,
                                                  fontWeight: selectedGender == 'Perempuan' ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Tanggal Lahir',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: selectBirthDate,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedBirthDate == null
                                                  ? 'Pilih Tanggal'
                                                  : DateFormat('dd/MM/yyyy').format(selectedBirthDate!),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(Icons.calendar_today_rounded, color: Colors.grey.shade500, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor HP',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Alamat Pasien',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Alamat tidak boleh kosong' : null,
                        ),
                        SizedBox(height: pad),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  final hasValue = nameController.text.trim().isNotEmpty ||
                                      nikController.text.trim().isNotEmpty ||
                                      phoneController.text.trim().isNotEmpty ||
                                      addressController.text.trim().isNotEmpty ||
                                      selectedBirthDate != null;
                                  if (hasValue) {
                                    final confirm = await AppDialogs.showConfirmationDialog(
                                      context,
                                      'Batalkan Registrasi?',
                                      'Apakah Anda yakin ingin membatalkan registrasi pasien baru ini?',
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
                                   minimumSize: Size(double.infinity, btnH),
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(btnR),
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
                                onPressed: provider.isLoading ? null : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  if (selectedBirthDate == null) {
                                    AppDialogs.showNotificationDialog(
                                      context,
                                      'Tanggal Lahir',
                                      'Silakan pilih tanggal lahir pasien terlebih dahulu!',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  final confirm = await AppDialogs.showConfirmationDialog(
                                    context,
                                    'Daftarkan Pasien?',
                                    'Apakah Anda yakin ingin mendaftarkan pasien baru ini secara manual?',
                                    confirmText: 'YA, DAFTAR',
                                    cancelText: 'BATAL',
                                  );
                                  if (!(confirm ?? false)) return;

                                  final birthStr = DateFormat('yyyy-MM-dd').format(selectedBirthDate!);
                                  final nik = nikController.text.trim();
                                  
                                  final data = {
                                    'name': nameController.text.trim(),
                                    'email': '$nik@nalaseva.com',
                                    'password': 'password123',
                                    'password_confirmation': 'password123',
                                    'national_id': nik,
                                    'phone': phoneController.text.trim(),
                                    'gender': selectedGender,
                                    'birth_date': birthStr,
                                    'address': addressController.text.trim(),
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
                                        'Pasien ${nameController.text.trim()} telah terdaftar secara manual dengan sukses.',
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
                                        'Simpan',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
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
