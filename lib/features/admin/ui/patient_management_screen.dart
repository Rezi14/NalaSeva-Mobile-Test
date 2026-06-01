import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../logic/admin_provider.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/widgets/staggered_list_animator.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_dialogs.dart';
import '../widgets/admin_patient_form_sheet.dart';
import '../widgets/admin_queue_booking_sheet.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    // Filter patients based on name or NIK
    final filteredPatients = provider.patients.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.nationalId ?? '').contains(_searchQuery);
      return matchesSearch;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Safe Native Premium Header
            Container(
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(context, '/admin/home');
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manajemen Pasien',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Daftar data pasien yang terdaftar di Puskesmas',
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
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari nama pasien atau NIK...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
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

            const Divider(height: 1),

            // Patient List
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.fetchPatients,
                child: provider.isLoading && provider.patients.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        children: [
                          if (provider.error != null) _errorCard(provider.error!),
                          filteredPatients.isEmpty
                              ? _emptyState()
                              : StaggeredListAnimator(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  itemCount: filteredPatients.length,
                                  itemBuilder: (context, index) {
                                    final patient = filteredPatients[index];
                                    return _buildPatientCard(patient);
                                  },
                                ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => AdminPatientFormSheet.show(context),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text(
            'TAMBAH PASIEN',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    final initials = patient.name.isNotEmpty
        ? patient.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
        : 'P';

    final birthDateStr = patient.birthDate != null
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(patient.birthDate!)
        : 'Tidak diketahui';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showPatientDetails(patient),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    initials,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Main info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (patient.isElderly) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'LANSIA',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.warningColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Details
                      _infoRow(Icons.credit_card_rounded, 'NIK: ${patient.nationalId ?? "-"}'),
                      const SizedBox(height: 4),
                      _infoRow(Icons.phone_iphone_rounded, patient.phone ?? 'Tidak ada nomor telepon'),
                      const SizedBox(height: 4),
                      _infoRow(
                        patient.gender == 'Perempuan' ? Icons.female_rounded : Icons.male_rounded,
                        '${patient.gender ?? "Tidak diketahui"} | lahir $birthDateStr',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  void _showPatientDetails(PatientModel patient) {
    final birthDateStr = patient.birthDate != null
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(patient.birthDate!)
        : 'Tidak diketahui';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Profil Pasien',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (patient.isElderly)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PASIEN LANSIA',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.warningColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 32),
              
              _detailItem(Icons.person_outline_rounded, 'Nama Lengkap', patient.name),
              _detailItem(Icons.credit_card_rounded, 'Nomor Induk Kependudukan (NIK)', patient.nationalId ?? '-'),
              _detailItem(Icons.badge_outlined, 'No Rekam Medis', patient.medicalRecordNumber ?? '-'),
              _detailItem(
                patient.gender == 'Perempuan' ? Icons.female_rounded : Icons.male_rounded,
                'Jenis Kelamin',
                patient.gender ?? 'Tidak diketahui',
              ),
              _detailItem(Icons.calendar_month_rounded, 'Tanggal Lahir', birthDateStr),
              _detailItem(Icons.phone_rounded, 'Nomor Telepon', patient.phone ?? 'Tidak tersedia'),
              _detailItem(Icons.home_outlined, 'Alamat', patient.address ?? 'Tidak tersedia'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  AdminQueueBookingSheet.show(context, patient);
                },
                icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white),
                label: Text(
                  'DAFTAR ANTREAN MANUAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Premium emerald green
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(patient);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.cancelColor),
                      label: Text(
                        'Hapus',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.cancelColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.cancelColor),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditPatientForm(patient);
                      },
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      label: Text(
                        'Edit Profil',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(PatientModel patient) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Hapus Akun Pasien?',
      'Apakah Anda yakin ingin menghapus akun ${patient.name}? Tindakan ini akan menghapus seluruh data pendaftaran dan antrean pasien ini secara permanen dari sistem.',
      confirmText: 'HAPUS',
      cancelText: 'BATAL',
      isDestructive: true,
    );

    if ((confirm ?? false) && mounted) {
      final provider = context.read<AdminProvider>();
      await provider.deleteUser(patient.userId);
      await provider.fetchPatients();
      if (mounted) {
        AppDialogs.showSuccessDialog(
          context,
          'Berhasil Dihapus',
          'Pasien ${patient.name} berhasil dihapus dari database Puskesmas.',
        );
      }
    }
  }

  void _showEditPatientForm(PatientModel patient) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: patient.name);
    final emailController = TextEditingController(text: patient.user?.email ?? '');
    final phoneController = TextEditingController(text: patient.phone ?? '');
    final addressController = TextEditingController(text: patient.address ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pull bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Edit Profil Pasien',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Email tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon (Opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat (Opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final isModified = nameController.text.trim() != patient.name ||
                                emailController.text.trim() != (patient.user?.email ?? '') ||
                                phoneController.text.trim() != (patient.phone ?? '') ||
                                addressController.text.trim() != (patient.address ?? '');
                            if (isModified) {
                              final confirm = await AppDialogs.showConfirmationDialog(
                                context,
                                'Batalkan Perubahan?',
                                'Apakah Anda yakin ingin membatalkan perubahan? Data yang sudah diubah tidak akan disimpan.',
                                confirmText: 'YA, BATALKAN',
                                cancelText: 'TETAP EDIT',
                                isDestructive: true,
                              );
                              if ((confirm ?? false) && context.mounted) {
                                Navigator.pop(context); // Close edit bottom sheet
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
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final provider = context.read<AdminProvider>();
                            
                            final confirm = await AppDialogs.showConfirmationDialog(
                              context,
                              'Simpan Perubahan?',
                              'Apakah Anda yakin ingin menyimpan perubahan data profil pasien ini?',
                              confirmText: 'YA, SIMPAN',
                              cancelText: 'BATAL',
                            );
                            
                            if (!(confirm ?? false)) return;
                            
                            final data = {
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'address': addressController.text.trim(),
                              'role': 'patient',
                            };
                            
                            await provider.updateUser(patient.userId, data);
                            await provider.fetchPatients();
                            
                            if (context.mounted) {
                              Navigator.pop(context); // Close edit bottom sheet
                              AppDialogs.showSuccessDialog(
                                context,
                                'Berhasil Diperbarui',
                                'Profil ${nameController.text} telah berhasil diperbarui di database Puskesmas.',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching
                  ? 'Pasien Tidak Ditemukan'
                  : 'Belum Ada Pasien',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'Tidak ada data akun pasien terdaftar yang cocok dengan kata kunci pencarian Anda.'
                  : 'Belum ada data pasien terdaftar yang tersedia di sistem saat ini. Daftarkan pasien baru menggunakan tombol di kanan bawah.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Reset Pencarian',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
