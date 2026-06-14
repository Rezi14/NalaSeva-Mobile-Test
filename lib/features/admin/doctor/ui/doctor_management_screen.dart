import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/admin_provider.dart';
import '../../../../shared/models/doctor_model.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../widgets/admin_doctor_card.dart';
import '../widgets/admin_doctor_form_sheet.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../dashboard/widgets/admin_mini_stat_card.dart';

class DoctorManagementScreen extends StatefulWidget {
  const DoctorManagementScreen({super.key});

  @override
  State<DoctorManagementScreen> createState() => _DoctorManagementScreenState();
}

class _DoctorManagementScreenState extends State<DoctorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedPolyclinicId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchDoctors();
      provider.fetchPolyclinics();
      provider.fetchQueues();
      provider.fetchSchedules();
      provider.fetchDoctorLeaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final doctors = provider.doctors.where((d) {
      final matchesSearch = (d.user?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (d.specialization?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesPolyclinic = _selectedPolyclinicId == null || d.polyclinicId?.toString() == _selectedPolyclinicId;
      return matchesSearch && matchesPolyclinic;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: ResponsiveCenter(
          maxWidth: 900,
          child: Column(
            children: [
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: AnimationLimiter(
                      child: Column(
                        children: [
                          AnimationConfiguration.staggeredList(
                            position: 0,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 30.0,
                              child: FadeInAnimation(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                          } else {
                                            Navigator.pushReplacementNamed(context, '/admin/home');
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: 18,
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
                                            'Manajemen Dokter',
                                            style: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Daftar dokter yang terdaftar di Puskesmas',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white.withValues(alpha: 0.9),
                                              height: 1.3,
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
                          const SizedBox(height: 20),
                          AnimationConfiguration.staggeredList(
                            position: 1,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 30.0,
                              child: FadeInAnimation(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (val) => setState(() => _searchQuery = val),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Cari dokter...',
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search_rounded,
                                            size: 20,
                                            color: Colors.grey.shade500,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: 0.92),
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
                                        onTap: () {
                                          _showFilterSheet(context);
                                        },
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _selectedPolyclinicId != null
                                                ? Colors.white
                                                : Colors.white.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.tune_rounded,
                                            color: _selectedPolyclinicId != null
                                                ? AppTheme.primaryColor
                                                : Colors.white.withValues(alpha: 0.8),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1),

            // Doctor List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.fetchDoctors();
                  await provider.fetchSchedules();
                  await provider.fetchDoctorLeaves();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 350),
                      child: _availabilityCard(provider),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: _sectionTitle('dokter'),
                      ),

                      if (provider.isLoading && provider.doctors.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else if (doctors.isEmpty)
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 24),
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
                                    _searchQuery.isNotEmpty || _selectedPolyclinicId != null
                                        ? Icons.search_off_rounded
                                        : Icons.people_outline_rounded,
                                    size: 64,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                Text(
                                  _searchQuery.isNotEmpty || _selectedPolyclinicId != null
                                      ? 'Dokter Tidak Ditemukan'
                                      : 'Tidak Ada Dokter',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),

                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada dokter dengan nama atau spesialisasi "$_searchQuery".'
                                      : 'Belum ada dokter terdaftar untuk filter poliklinik terpilih.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty || _selectedPolyclinicId != null) ...[
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                        _selectedPolyclinicId = null;
                                      });
                                    },
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: Text(
                                      'Reset Pencarian & Filter',
                                      style: GoogleFonts.poppins(
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
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: doctors.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final doc = doctors[index];
                            return FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: Duration(milliseconds: 250 + (index * 80)),
                              child: AdminDoctorCard(
                                doctor: doc,
                                schedules: provider.schedules,
                                doctorLeaves: provider.doctorLeaves,
                                onEdit: () => AdminDoctorFormSheet.show(context, doctor: doc),
                                onDelete: () => _confirmDeleteDoctor(context, doc),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
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
            onPressed: () => AdminDoctorFormSheet.show(context),
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 22),
            label: const Text(
              'Tambah Dokter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  void _confirmDeleteDoctor(BuildContext context, DoctorModel doc) async {
    final provider = context.read<AdminProvider>();
    
    // Check if the doctor has any active queues
    final activeQueues = provider.queues.where((q) =>
      q.doctorId == doc.id &&
      q.status != QueueStatus.completed &&
      q.status.isActive
    ).toList();

    if (activeQueues.isNotEmpty) {
      AppDialogs.showNotificationDialog(
        context,
        'Tidak Dapat Menghapus',
        '${doc.user?.name ?? "Dokter"} masih memiliki ${activeQueues.length} antrean aktif. Selesaikan atau batalkan semua antrean terlebih dahulu.',
        isError: true,
      );
      return;
    }

    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Hapus Dokter',
      'Apakah Anda yakin ingin menghapus ${doc.user?.name}?',
      confirmText: 'Hapus',
      isDestructive: true,
    );

    if ((confirm ?? false) && context.mounted) {
      await context.read<AdminProvider>().deleteDoctor(doc.id);
    }
  }

  Widget _availabilityCard(AdminProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: AdminMiniStatCard(
              label: 'Poli Aktif',
              value: '${provider.polyclinics.length}',
              bgColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              textColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AdminMiniStatCard(
              label: 'Total Dokter',
              value: '${provider.doctors.length}',
              bgColor: AppTheme.accentColor.withValues(alpha: 0.1),
              textColor: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
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
                          'Filter dokter',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_selectedPolyclinicId != null)
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedPolyclinicId = null);
                              setSheetState(() => _selectedPolyclinicId = null);
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
                      'Berdasarkan Poliklinik',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (provider.polyclinics.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('Tidak ada poliklinik tersedia')),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.polyclinics.map((poly) {
                          final isSelected = _selectedPolyclinicId == poly.id.toString();
                          return ChoiceChip(
                            label: Text(
                              poly.name,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryColor,
                            backgroundColor: Colors.grey.shade100,
                            checkmarkColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                _selectedPolyclinicId = selected ? poly.id.toString() : null;
                              });
                              setSheetState(() {
                                _selectedPolyclinicId = selected ? poly.id.toString() : null;
                              });
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
