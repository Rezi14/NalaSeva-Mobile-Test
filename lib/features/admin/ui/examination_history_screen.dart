import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../logic/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';

class ExaminationHistoryScreen extends StatefulWidget {
  const ExaminationHistoryScreen({super.key});

  @override
  State<ExaminationHistoryScreen> createState() => _ExaminationHistoryScreenState();
}

class _ExaminationHistoryScreenState extends State<ExaminationHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedPolyclinicId;
  int? _selectedDoctorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchExaminations();
      provider.fetchPolyclinics();
      provider.fetchDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final provider = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final hasActiveFilter = _selectedPolyclinicId != null || _selectedDoctorId != null;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Rekam Medis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (hasActiveFilter)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedPolyclinicId = null;
                                _selectedDoctorId = null;
                              });
                              setSheetState(() {
                                _selectedPolyclinicId = null;
                                _selectedDoctorId = null;
                              });
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Poliklinik
                    Text(
                      'Layanan Poliklinik',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedPolyclinicId,
                      decoration: InputDecoration(
                        hintText: 'Semua Poliklinik',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Poliklinik'),
                        ),
                        ...provider.polyclinics.map((p) => DropdownMenuItem<int>(
                              value: p.id,
                              child: Text(p.name),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedPolyclinicId = val);
                        setSheetState(() => _selectedPolyclinicId = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Filter Dokter
                    Text(
                      'Dokter Pemeriksa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedDoctorId,
                      decoration: InputDecoration(
                        hintText: 'Semua Dokter',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Dokter'),
                        ),
                        ...provider.doctors.map((d) => DropdownMenuItem<int>(
                              value: d.id,
                              child: Text(d.name),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedDoctorId = val);
                        setSheetState(() => _selectedDoctorId = val);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Apply Button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)),
                        ),
                      ),
                      child: Text(
                        'Terapkan Filter',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    final filtered = provider.examinations.where((exam) {
      final matchesSearch = exam.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exam.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exam.diagnosis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exam.treatment.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesPolyclinic = _selectedPolyclinicId == null || 
          exam.doctor?.polyclinicId == _selectedPolyclinicId ||
          exam.queue?.polyclinic.id == _selectedPolyclinicId;

      final matchesDoctor = _selectedDoctorId == null || exam.doctorId == _selectedDoctorId;

      return matchesSearch && matchesPolyclinic && matchesDoctor;
    }).toList();

    final hasActiveFilter = _selectedPolyclinicId != null || _selectedDoctorId != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: ResponsiveCenter(
          maxWidth: 900,
          child: Column(
            children: [
            // Custom Premium Header
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(context, '/admin/home');
                                }
                              },
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rekam Medis Pasien',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Riwayat pemeriksaan & diagnosa klinis',
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
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => setState(() => _searchQuery = val),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Cari nama pasien, dokter, diagnosa...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showFilterSheet,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: hasActiveFilter
                                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasActiveFilter
                                          ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: hasActiveFilter ? AppTheme.primaryColor : Colors.black87,
                                    size: 20,
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
              ),
            ),
            const Divider(height: 1),

            // History Records List
            Expanded(
              child: provider.isLoading && provider.examinations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                                    hasActiveFilter || _searchQuery.isNotEmpty
                                        ? Icons.search_off_rounded
                                        : Icons.history_rounded,
                                    size: 64,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  hasActiveFilter || _searchQuery.isNotEmpty
                                      ? 'Hasil Tidak Ditemukan'
                                      : 'Riwayat Rekam Medis Kosong',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  hasActiveFilter || _searchQuery.isNotEmpty
                                      ? 'Tidak ada data rekam medis pasien yang cocok dengan pencarian atau filter aktif Anda. Silakan coba atur ulang pencarian.'
                                      : 'Belum ada riwayat rekam medis pemeriksaan pasien yang tercatat pada sistem saat ini.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (hasActiveFilter || _searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                        _selectedPolyclinicId = null;
                                        _selectedDoctorId = null;
                                      });
                                    },
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: Text(
                                      'Reset Pencarian & Filter',
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
                        )
                      : RefreshIndicator(
                          onRefresh: provider.fetchExaminations,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final examination = filtered[index];
                                final date = examination.createdAt != null 
                                    ? DateFormat('dd MMM yyyy, HH:mm').format(examination.createdAt!.toLocal())
                                    : '-';

                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.grey.shade100),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      date,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        color: Colors.grey.shade600, 
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.successColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    'Selesai',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      color: AppTheme.successColor, 
                                                      fontSize: 10, 
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                                  child: const Icon(Icons.person_rounded, size: 16, color: AppTheme.primaryColor),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Pasien',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          color: Colors.grey.shade500,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        examination.patientName,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                                  child: const Icon(Icons.medical_services_rounded, size: 16, color: AppTheme.secondaryColor),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Dokter Pemeriksa',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          color: Colors.grey.shade500,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        examination.doctorName,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Diagnosis:',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11, 
                                                      fontWeight: FontWeight.bold, 
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    examination.diagnosis.isNotEmpty ? examination.diagnosis : '-',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Tindakan & Terapi:',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11, 
                                                      fontWeight: FontWeight.bold, 
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    examination.treatment.isNotEmpty ? examination.treatment : '-',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w500,
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
                                );
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
