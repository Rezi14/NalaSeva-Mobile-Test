import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../logic/admin_provider.dart';
import '../../../../shared/models/patient_model.dart';
import '../../../../shared/widgets/staggered_list_animator.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../widgets/admin_patient_form_sheet.dart';
import '../../queue/widgets/admin_queue_booking_sheet.dart';
import '../../../../core/utils/responsive_helper.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() =>
      _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedGender;
  bool? _filterElderly;

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

  bool get _hasActiveFilter => _selectedGender != null || _filterElderly != null;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    final filteredPatients = provider.patients.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.nationalId ?? '').contains(_searchQuery);
      final matchesGender =
          _selectedGender == null || p.gender == _selectedGender;
      final matchesElderly =
          _filterElderly == null || p.isElderly == _filterElderly;
      return matchesSearch && matchesGender && matchesElderly;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ResponsiveCenter(
          maxWidth: 900,
          child: Column(
            children: [
              Container(
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
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    child: Column(
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pushReplacementNamed(
                                          context, '/admin/home');
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Manajemen Pasien',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Daftar data pasien yang terdaftar di Puskesmas',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.8),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) =>
                                        setState(() => _searchQuery = val),
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.black87),
                                    decoration: InputDecoration(
                                      hintText: 'Cari nama pasien atau NIK...',
                                      hintStyle: GoogleFonts.poppins(
                                          color: Colors.grey.shade400,
                                          fontSize: 14),
                                      prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          size: 20,
                                          color: Colors.grey),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.grey),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() => _searchQuery = '');
                                              },
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                            color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              Container(
                                decoration: BoxDecoration(
                                  color: _hasActiveFilter
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5), 
                                    width: 1, 
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () => _showFilterSheet(context),
                                  icon: Icon(
                                    Icons.tune_rounded,
                                    color: _hasActiveFilter
                                        ? AppTheme.primaryColor
                                        : Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_hasActiveFilter) ...[
                          const SizedBox(height: 12),
                          FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            child: SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  if (_selectedGender != null)
                                    _activeFilterChip(
                                      _selectedGender!,
                                      () => setState(() => _selectedGender = null),
                                    ),
                                  if (_filterElderly != null)
                                    _activeFilterChip(
                                      _filterElderly! ? 'Lansia' : 'Non-Lansia',
                                      () => setState(() => _filterElderly = null),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.fetchPatients,
                  child: provider.isLoading && provider.patients.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          children: [
                            if (provider.error != null)
                              _errorCard(provider.error!),
                            filteredPatients.isEmpty
                                ? _emptyState()
                                : StaggeredListAnimator(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    itemCount: filteredPatients.length,
                                    itemBuilder: (context, index) =>
                                        _buildPatientCard(
                                            filteredPatients[index]),
                                  ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: ResponsiveCenter(
          maxWidth: 900,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: () => AdminPatientFormSheet.show(context),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(
                'Tambah Pasien',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Pasien',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_hasActiveFilter)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedGender = null;
                                _filterElderly = null;
                              });
                              setSheetState(() {});
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.poppins(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Jenis Kelamin',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['Laki-laki', 'Perempuan'].map((gender) {
                        final isSelected = _selectedGender == gender;
                        return ChoiceChip(
                          label: Text(gender,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: Colors.grey.shade100,
                          showCheckmark: false,
                          onSelected: (val) {
                            setState(() =>
                                _selectedGender = val ? gender : null);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Kategori Usia',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        {'label': 'Lansia', 'value': true},
                        {'label': 'Non-Lansia', 'value': false},
                      ].map((item) {
                        final isSelected = _filterElderly == item['value'];
                        return ChoiceChip(
                          label: Text(item['label'] as String,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: Colors.grey.shade100,
                          showCheckmark: false,
                          onSelected: (val) {
                            setState(() => _filterElderly =
                                val ? item['value'] as bool : null);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: Size(
                            double.infinity,
                            ResponsiveHelper.buttonHeight(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.radiusButton(context)),
                        ),
                      ),
                      child: Text(
                        'Terapkan Filter',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    final initials = patient.name.isNotEmpty
        ? patient.name
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'P';

    final birthDateStr = patient.birthDate != null
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(patient.birthDate!)
        : 'Tidak diketahui';

    return GestureDetector(
      onTap: () => _showPatientDetails(patient),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          patient.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (patient.isElderly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppTheme.warningColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'LANSIA',
                            style: GoogleFonts.poppins(
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
                  _infoRow(Icons.credit_card_rounded,
                      'NIK: ${patient.nationalId ?? "-"}'),
                  const SizedBox(height: 4),
                  _infoRow(Icons.phone_iphone_rounded,
                      patient.phone ?? 'Tidak ada nomor telepon'),
                  const SizedBox(height: 4),
                  _infoRow(
                    patient.gender == 'Perempuan'
                        ? Icons.female_rounded
                        : Icons.male_rounded,
                    '${patient.gender ?? "Tidak diketahui"} | lahir $birthDateStr',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.72)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // _showPatientDetails, _confirmDelete, _showEditPatientForm,
  // _detailItem, _errorCard, _emptyState — tidak ada perubahan
  void _showPatientDetails(PatientModel patient) {
    final birthDateStr = patient.birthDate != null
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(patient.birthDate!)
        : 'Tidak diketahui';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: false,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (patient.isElderly)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PASIEN LANSIA',
                        style: GoogleFonts.poppins(
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
                'Jenis Kelamin', patient.gender ?? 'Tidak diketahui',
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
                label: Text('Daftar Antrean Manual',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context))),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(context); _confirmDelete(patient); },
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.cancelColor),
                      label: Text('Hapus', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.cancelColor)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.cancelColor),
                        minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(context); _showEditPatientForm(patient); },
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      label: Text('Edit Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context))),
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
      context, 'Hapus Akun Pasien?',
      'Apakah Anda yakin ingin menghapus akun ${patient.name}? Tindakan ini akan menghapus seluruh data pendaftaran dan antrean pasien ini secara permanen dari sistem.',
      confirmText: 'Hapus', cancelText: 'Batal', isDestructive: true,
    );
    if ((confirm ?? false) && mounted) {
      final provider = context.read<AdminProvider>();
      await provider.deleteUser(patient.userId);
      await provider.fetchPatients();
      if (mounted) {
        AppDialogs.showSuccessDialog(context, 'Berhasil Dihapus',
            'Pasien ${patient.name} berhasil dihapus dari database Puskesmas.');
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
      context: context, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      showDragHandle: false,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 40),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  Text('Edit Profil Pasien', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const Divider(height: 32),
                  TextFormField(controller: nameController,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.primaryColor),
                    decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline_rounded)),
                    validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: emailController,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.primaryColor),
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => v == null || v.isEmpty ? 'Email tidak boleh kosong' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: phoneController,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.primaryColor),
                    decoration: const InputDecoration(labelText: 'Nomor Telepon (Opsional)', prefixIcon: Icon(Icons.phone_outlined))),
                  const SizedBox(height: 16),
                  TextFormField(controller: addressController,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.primaryColor),
                    decoration: const InputDecoration(labelText: 'Alamat (Opsional)', prefixIcon: Icon(Icons.location_on_outlined)),
                    maxLines: 2),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () async {
                        final isModified = nameController.text.trim() != patient.name ||
                            emailController.text.trim() != (patient.user?.email ?? '') ||
                            phoneController.text.trim() != (patient.phone ?? '') ||
                            addressController.text.trim() != (patient.address ?? '');
                        if (isModified) {
                          final confirm = await AppDialogs.showConfirmationDialog(context,
                            'Batalkan Perubahan?', 'Apakah Anda yakin ingin membatalkan perubahan?',
                            confirmText: 'Batalkan', cancelText: 'Tetap Edit', isDestructive: true);
                          if ((confirm ?? false) && context.mounted) Navigator.pop(context);
                        } else { Navigator.pop(context); }
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey),
                        minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)))),
                      child: Text('Batal', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey.shade700)))),
                    const SizedBox(width: 16),
                    Expanded(child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final provider = context.read<AdminProvider>();
                        final confirm = await AppDialogs.showConfirmationDialog(context,
                          'Simpan Perubahan?', 'Apakah Anda yakin ingin menyimpan perubahan?',
                          confirmText: 'Simpan', cancelText: 'Batal');
                        if (!(confirm ?? false)) return;
                        final data = {'name': nameController.text.trim(), 'email': emailController.text.trim(),
                          'phone': phoneController.text.trim(), 'address': addressController.text.trim(), 'role': 'patient'};
                        await provider.updateUser(patient.userId, data);
                        await provider.fetchPatients();
                        if (context.mounted) {
                          Navigator.pop(context);
                          AppDialogs.showSuccessDialog(context, 'Berhasil Diperbarui',
                            'Profil ${nameController.text} telah berhasil diperbarui.');
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor,
                        minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)))),
                      child: Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)))),
                  ]),
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
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _errorCard(String error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200)),
        child: Row(children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(error, style: GoogleFonts.poppins(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    final isSearching = _searchQuery.isNotEmpty || _hasActiveFilter;
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFDCEEE7)),
          boxShadow: [BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(isSearching ? Icons.search_off_rounded : Icons.people_outline_rounded,
                  size: 64, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(isSearching ? 'Pasien Tidak Ditemukan' : 'Belum Ada Pasien',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'Tidak ada data pasien yang cocok dengan pencarian atau filter yang dipilih.'
                  : 'Belum ada data pasien terdaftar.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedGender = null;
                  _filterElderly = null;
                }),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Reset Pencarian & Filter', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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