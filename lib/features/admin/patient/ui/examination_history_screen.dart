import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../logic/admin_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/admin_examination_card.dart';

class ExaminationHistoryScreen extends StatefulWidget {
  const ExaminationHistoryScreen({super.key});

  @override
  State<ExaminationHistoryScreen> createState() =>
      _ExaminationHistoryScreenState();
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
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final hasActiveFilter =
              _selectedPolyclinicId != null || _selectedDoctorId != null;
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
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
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
                            style: GoogleFonts.poppins(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Layanan Poliklinik',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedPolyclinicId,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.primaryColor),
                    decoration: InputDecoration(
                      hintText: 'Semua Poliklinik',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Semua Poliklinik',
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ),
                      ...provider.polyclinics.map((p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name,
                                style: GoogleFonts.poppins(fontSize: 14)),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedPolyclinicId = val);
                      setSheetState(() => _selectedPolyclinicId = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Dokter Pemeriksa',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedDoctorId,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.primaryColor),
                    decoration: InputDecoration(
                      hintText: 'Semua Dokter',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Semua Dokter',
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ),
                      ...provider.doctors.map((d) => DropdownMenuItem<int>(
                            value: d.id,
                            child: Text(d.name,
                                style: GoogleFonts.poppins(fontSize: 14)),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedDoctorId = val);
                      setSheetState(() => _selectedDoctorId = val);
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity,
                          ResponsiveHelper.buttonHeight(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            ResponsiveHelper.radiusButton(context)),
                      ),
                    ),
                    child: Text(
                      'Terapkan Filter',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    final filtered = provider.examinations.where((exam) {
      final matchesSearch =
          exam.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              exam.doctorName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              exam.diagnosis
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              exam.treatment.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPolyclinic = _selectedPolyclinicId == null ||
          exam.doctor?.polyclinicId == _selectedPolyclinicId ||
          exam.queue?.polyclinic.id == _selectedPolyclinicId;
      final matchesDoctor =
          _selectedDoctorId == null || exam.doctorId == _selectedDoctorId;
      return matchesSearch && matchesPolyclinic && matchesDoctor;
    }).toList();

    final hasActiveFilter =
        _selectedPolyclinicId != null || _selectedDoctorId != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
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
                child: FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                      child: Column(
                        children: [
                          Row(
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
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rekam Medis Pasien',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Riwayat pemeriksaan & diagnosa klinis',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) =>
                                        setState(() => _searchQuery = val),
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.black87),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Cari nama pasien, dokter, diagnosa...',
                                      hintStyle: GoogleFonts.poppins(
                                          color: Colors.grey.shade400,
                                          fontSize: 14),
                                      prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          size: 20,
                                          color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                            color: Colors.white, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: _showFilterSheet,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: hasActiveFilter
                                        ? Colors.white
                                        : Colors.white
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasActiveFilter
                                          ? AppTheme.primaryColor
                                              .withValues(alpha: 0.3)
                                          : Colors.white
                                              .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: hasActiveFilter
                                        ? AppTheme.primaryColor
                                        : Colors.white,
                                    size: 20,
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

              // List
              Expanded(
                child: provider.isLoading && provider.examinations.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 40),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 48),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: const Color(0xFFDCEEE7)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentColor
                                        .withValues(alpha: 0.06),
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
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      hasActiveFilter ||
                                              _searchQuery.isNotEmpty
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
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    hasActiveFilter || _searchQuery.isNotEmpty
                                        ? 'Tidak ada data rekam medis yang cocok.'
                                        : 'Belum ada riwayat rekam medis yang tercatat.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (hasActiveFilter ||
                                      _searchQuery.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    OutlinedButton.icon(
                                      onPressed: () => setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                        _selectedPolyclinicId = null;
                                        _selectedDoctorId = null;
                                      }),
                                      icon: const Icon(Icons.refresh_rounded,
                                          size: 18),
                                      label: Text('Reset Pencarian & Filter',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.primaryColor,
                                        side: BorderSide(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.5)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
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
                                      ? DateFormat('dd MMM yyyy, HH:mm').format(
                                          examination.createdAt!.toLocal())
                                      : '-';
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration:
                                        const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: AdminExaminationCard(
                                          examination: examination,
                                          formattedDate: date,
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