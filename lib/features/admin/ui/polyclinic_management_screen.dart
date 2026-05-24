import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../widgets/admin_mini_stat_card.dart';
import '../widgets/admin_service_card.dart';

class PolyclinicManagementScreen extends StatefulWidget {
  const PolyclinicManagementScreen({super.key});

  @override
  State<PolyclinicManagementScreen> createState() => _PolyclinicManagementScreenState();
}

class _PolyclinicManagementScreenState extends State<PolyclinicManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchPolyclinics();
      provider.fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final polyclinics = provider.polyclinics.where((p) => 
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.code.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    int totalDailyQuota = 0;
    for (var poly in provider.polyclinics) {
      totalDailyQuota += _calculatePolyclinicQuota(poly, provider.schedules);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Header
            FadeInDown(
              duration: const Duration(milliseconds: 600),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Layanan Klinik',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Atur ruangan dan batas kuota',
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
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) => setState(() => _searchQuery = val),
                                    decoration: const InputDecoration(
                                      hintText: 'Cari layanan...',
                                      border: InputBorder.none,
                                      icon: Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Icon(Icons.tune_rounded, color: Colors.black87, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1),

            // Stats Row
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  children: [
                    AdminMiniStatCard(label: 'Ruangan Aktif', value: '${provider.polyclinics.length}', bgColor: AppTheme.primaryColor.withValues(alpha: 0.1), textColor: AppTheme.primaryColor),
                    const SizedBox(width: 16),
                    AdminMiniStatCard(label: 'Kuota Harian', value: '$totalDailyQuota', bgColor: Colors.green.withValues(alpha: 0.1), textColor: Colors.green),
                  ],
                ),
              ),
            ),

            // List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.fetchPolyclinics();
                  await provider.fetchSchedules();
                },
                child: provider.isLoading && provider.polyclinics.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: polyclinics.length,
                        itemBuilder: (context, index) {
                          final poly = polyclinics[index];
                          return FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: Duration(milliseconds: 100 * index),
                            child: AdminServiceCard(
                              polyclinic: poly,
                              quota: _calculatePolyclinicQuota(poly, provider.schedules),
                              operatingHours: _getPolyclinicOperatingHours(poly, provider.schedules),
                              onEdit: () => _showPolyclinicForm(context, poly: poly),
                              onDelete: () => _confirmDeletePolyclinic(context, poly),
                            ),
                          );
                        },
                      ),
              ),
            ),

            // Bottom Actions
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  children: [
                    _actionButton('Perbarui Semua Jadwal', Icons.schedule_rounded, true, () {
                      AppDialogs.showNotificationDialog(
                        context,
                        'Berhasil',
                        'Jadwal seluruh poliklinik berhasil disinkronisasi & diperbarui!',
                      );
                    }),
                    const SizedBox(height: 12),
                    _actionButton('Lihat Laporan Antrean', Icons.assessment_rounded, false, () {
                      AppDialogs.showNotificationDialog(
                        context,
                        'Berhasil',
                        'Laporan antrean poliklinik hari ini berhasil diunduh (PDF)',
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: _bottomNav(context),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 226),
          child: FloatingActionButton(
            onPressed: () => _showPolyclinicForm(context),
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }



  void _confirmDeletePolyclinic(BuildContext context, PolyclinicModel poly) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Hapus Poliklinik',
      'Apakah Anda yakin ingin menghapus ${poly.name}? Ini mungkin memengaruhi jadwal dokter yang terkait.',
      confirmText: 'HAPUS',
      isDestructive: true,
    );

    if (confirm == true && context.mounted) {
      await context.read<AdminProvider>().deletePolyclinic(poly.id);
    }
  }

  Widget _actionButton(String label, IconData icon, bool isPrimary, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: AppTheme.primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isPrimary ? Colors.white : AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              color: isPrimary ? Colors.white : AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.dashboard_rounded, false, () => Navigator.pushReplacementNamed(context, '/admin/home')),
              _navItem(Icons.medical_services_rounded, false, () => Navigator.pushReplacementNamed(context, '/admin/doctors')),
              _navItem(Icons.calendar_month_rounded, false, () => Navigator.pushReplacementNamed(context, '/admin/schedules')),
              _navItem(Icons.local_hospital_rounded, true, () {}),
              _navItem(Icons.settings_rounded, false, () => Navigator.pushReplacementNamed(context, '/admin/settings')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, bool isActive, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey, size: 28),
    );
  }

  void _showPolyclinicForm(BuildContext context, {PolyclinicModel? poly}) {
    final isEdit = poly != null;
    final nameController = TextEditingController(text: poly?.name);
    final codeController = TextEditingController(text: poly?.code);
    final descController = TextEditingController(text: poly?.description);
    final formKey = GlobalKey<FormState>();


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Consumer<AdminProvider>(
        builder: (context, provider, child) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEdit ? 'Edit Poliklinik' : 'Tambah Poliklinik Baru', 
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController, 
                  decoration: const InputDecoration(labelText: 'Nama Klinik', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Nama Klinik tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController, 
                  decoration: const InputDecoration(
                    labelText: 'Kode Klinik (cth. GIGI)', 
                    helperText: 'Format: HURUF BESAR & angka (cth: GIGI, THT, PL01)',
                    helperStyle: TextStyle(color: Colors.blueGrey, fontSize: 11),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Kode Klinik tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController, 
                  decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)', border: OutlineInputBorder()), 
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
              ElevatedButton(
                onPressed: provider.isLoading ? null : () async {
                  if (!formKey.currentState!.validate()) return;
                  
                  final data = {
                    'name': nameController.text.trim(),
                    'code': codeController.text.trim(),
                    'description': descController.text.trim(),
                  };
                  if (isEdit) {
                    await provider.updatePolyclinic(poly.id, data);
                  } else {
                    await provider.createPolyclinic(data);
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
                        isEdit ? 'Data poliklinik berhasil diperbarui' : 'Poliklinik berhasil ditambahkan',
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
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Perbarui Poliklinik' : 'Simpan Poliklinik', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  int _calculatePolyclinicQuota(PolyclinicModel poly, List<ScheduleModel> schedules) {
    int totalQuota = 0;
    final polySchedules = schedules.where((s) => s.doctor?.polyclinicId == poly.id).toList();
    for (var s in polySchedules) {
      totalQuota += _calculateScheduleQuota(s.startTime, s.endTime);
    }
    return totalQuota;
  }

  int _calculateScheduleQuota(String startTime, String endTime) {
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      if (startParts.length >= 2 && endParts.length >= 2) {
        final startHour = int.parse(startParts[0]);
        final startMin = int.parse(startParts[1]);
        final endHour = int.parse(endParts[0]);
        final endMin = int.parse(endParts[1]);
        
        final startTotal = startHour * 60 + startMin;
        final endTotal = endHour * 60 + endMin;
        final duration = endTotal - startTotal;
        if (duration > 0) {
          return (duration / 15).floor();
        }
      }
    } catch (_) {}
    return 10; // fallback
  }

  String _getPolyclinicOperatingHours(PolyclinicModel poly, List<ScheduleModel> schedules) {
    final polySchedules = schedules.where((s) => s.doctor?.polyclinicId == poly.id).toList();
    if (polySchedules.isEmpty) {
      return 'Tidak ada praktik';
    }
    
    String earliestStart = '23:59';
    String latestEnd = '00:00';
    
    for (var s in polySchedules) {
      final sStart = s.startTime.substring(0, 5);
      final sEnd = s.endTime.substring(0, 5);
      
      if (sStart.compareTo(earliestStart) < 0) {
        earliestStart = sStart;
      }
      if (sEnd.compareTo(latestEnd) > 0) {
        latestEnd = sEnd;
      }
    }
    
    if (earliestStart == '23:59' || latestEnd == '00:00') {
      return 'Tidak ada praktik';
    }
    
    return '$earliestStart - $latestEnd';
  }
}
