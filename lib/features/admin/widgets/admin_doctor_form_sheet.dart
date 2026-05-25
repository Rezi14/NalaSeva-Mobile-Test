import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../logic/admin_provider.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';

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
            builder: (context, provider, child) => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Dokter' : 'Tambah Dokter Baru', 
                        style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController, 
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap', 
                      border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
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
                  if (!isEdit) ...[
                    TextFormField(
                      controller: emailController, 
                      decoration: const InputDecoration(
                        labelText: 'Email', 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                        if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController, 
                      decoration: const InputDecoration(
                        labelText: 'Kata Sandi', 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline_rounded),
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
                  // Dropdown for Polyclinic Selection
                  DropdownButtonFormField<int>(
                    initialValue: selectedPolyclinicId,
                    decoration: const InputDecoration(
                      labelText: 'Layanan Poliklinik',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital_outlined),
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
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.star_outline_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Spesialisasi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: licenseController, 
                    decoration: const InputDecoration(
                      labelText: 'Nomor SIP/Lisensi', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.card_membership_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nomor SIP / Lisensi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gender Segmented Selection
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
                      // Birth Date Selection Card
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
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP (Opsional)', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController, 
                    decoration: const InputDecoration(
                      labelText: 'Alamat (Opsional)', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : () async {
                      if (!formKey.currentState!.validate()) return;

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
                          AppDialogs.showNotificationDialog(
                            context,
                            'Berhasil',
                            isEdit ? 'Data dokter berhasil diperbarui' : 'Dokter berhasil ditambahkan',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(isEdit ? 'PERBARUI' : 'SIMPAN', style: const TextStyle(color: Colors.white)),
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
);
  }
}
