import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/date_time_parser.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../widgets/admin_mini_stat_card.dart';
import '../widgets/admin_service_card.dart';
import '../widgets/admin_bottom_nav.dart';

class PolyclinicManagementScreen extends StatefulWidget {
  const PolyclinicManagementScreen({super.key});

  @override
  State<PolyclinicManagementScreen> createState() => _PolyclinicManagementScreenState();
}

class _PolyclinicManagementScreenState extends State<PolyclinicManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _filterOnlyWithSchedules = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchPolyclinics();
      provider.fetchSchedules();
      provider.fetchQueues();
      provider.fetchDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final polyclinics = provider.polyclinics.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_filterOnlyWithSchedules) {
        final quota = _calculatePolyclinicQuota(p, provider.schedules);
        return matchesSearch && quota > 0;
      }
      return matchesSearch;
    }).toList();

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
            // Premium Header with smooth bottom-up stagger
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
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Cari layanan...',
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        onTap: () {
                                          _showFilterSheet(context);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Icon(
                                            Icons.tune_rounded,
                                            color: _filterOnlyWithSchedules 
                                                ? AppTheme.primaryColor 
                                                : Colors.black87,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
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

            // Stats Row
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
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
                            delay: Duration(milliseconds: 250 + (index * 80)),
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

            // Bottom Navigation
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: const AdminBottomNav(activeIndex: 3),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 76),
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
    final provider = context.read<AdminProvider>();
    
    // Check if the polyclinic has any doctor schedules
    final activeSchedules = provider.schedules.where((s) => s.doctor?.polyclinicId == poly.id).toList();
    if (activeSchedules.isNotEmpty) {
      AppDialogs.showNotificationDialog(
        context,
        'Tidak Dapat Menghapus',
        'Poliklinik ${poly.name} masih memiliki ${activeSchedules.length} jadwal dokter aktif. Hapus jadwal dokter terlebih dahulu.',
        isError: true,
      );
      return;
    }

    // Check if there are active queues in this polyclinic (checking the doctors of this polyclinic)
    final doctorsInPoly = provider.doctors.where((d) => d.polyclinicId == poly.id).map((d) => d.id).toSet();
    final activeQueues = provider.queues.where((q) =>
      doctorsInPoly.contains(q.doctorId) &&
      q.status != QueueStatus.completed &&
      q.status != QueueStatus.cancelled
    ).toList();

    if (activeQueues.isNotEmpty) {
      AppDialogs.showNotificationDialog(
        context,
        'Tidak Dapat Menghapus',
        'Poliklinik ${poly.name} masih memiliki ${activeQueues.length} antrean aktif. Selesaikan atau batalkan semua antrean terlebih dahulu.',
        isError: true,
      );
      return;
    }

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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (isEdit) {
                          final confirm = await AppDialogs.showConfirmationDialog(
                            context,
                            'Batalkan Perubahan?',
                            'Apakah Anda yakin ingin membatalkan perubahan data poliklinik ini?',
                            confirmText: 'YA, BATALKAN',
                            cancelText: 'TETAP EDIT',
                            isDestructive: true,
                          );
                          if (confirm == true && context.mounted) {
                            Navigator.pop(context);
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
                        'BATAL',
                        style: TextStyle(
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
                          isEdit ? 'Perbarui Poliklinik?' : 'Simpan Poliklinik Baru?',
                          isEdit 
                              ? 'Apakah Anda yakin ingin menyimpan perubahan data poliklinik ini?'
                              : 'Apakah Anda yakin ingin menambahkan poliklinik baru ini?',
                          confirmText: isEdit ? 'YA, UPDATE' : 'YA, SIMPAN',
                          cancelText: 'BATAL',
                        );
                        if (confirm != true) return;

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
                            AppDialogs.showSuccessDialog(
                              context,
                              'Berhasil Disimpan',
                              isEdit 
                                  ? 'Data poliklinik ${nameController.text} telah berhasil diperbarui.'
                                  : 'Poliklinik baru ${nameController.text} telah berhasil ditambahkan.',
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: provider.isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? 'UPDATE' : 'SIMPAN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  }

  int _calculatePolyclinicQuota(PolyclinicModel poly, List<ScheduleModel> schedules) {
    int totalQuota = 0;
    final polySchedules = schedules.where((s) => s.doctor?.polyclinicId == poly.id).toList();
    for (var s in polySchedules) {
      final quota = _calculateScheduleQuota(s.startTime, s.endTime);
      if (quota != null) {
        totalQuota += quota;
      }
    }
    return totalQuota;
  }

  int? _calculateScheduleQuota(String startTime, String endTime) {
    try {
      final startTotal = DateTimeParser.parseMinutesOfDay(startTime);
      final endTotal = DateTimeParser.parseMinutesOfDay(endTime);
      if (startTotal != null && endTotal != null) {
        final duration = endTotal - startTotal;
        if (duration > 0) {
          return (duration / 15).floor();
        }
      }
    } catch (e) {
      debugPrint('PolyclinicManagementScreen: gagal menghitung kuota jadwal "$startTime - $endTime": $e');
    }
    return null;
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
                          'Filter Layanan Klinik',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_filterOnlyWithSchedules)
                          TextButton(
                            onPressed: () {
                              setState(() => _filterOnlyWithSchedules = false);
                              setSheetState(() => _filterOnlyWithSchedules = false);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Jadwal & Kuota',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Hanya Tampilkan Klinik Aktif',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Menyaring poliklinik yang memiliki jadwal dokter dan kuota harian saat ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Switch(
                        value: _filterOnlyWithSchedules,
                        activeThumbColor: AppTheme.primaryColor,
                        onChanged: (val) {
                          setState(() {
                            _filterOnlyWithSchedules = val;
                          });
                          setSheetState(() {
                            _filterOnlyWithSchedules = val;
                          });
                          Navigator.pop(context);
                        },
                      ),
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
