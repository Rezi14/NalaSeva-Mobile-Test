import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../widgets/admin_doctor_card.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/admin_doctor_form_sheet.dart';

class DoctorManagementScreen extends StatefulWidget {
  const DoctorManagementScreen({super.key});

  @override
  State<DoctorManagementScreen> createState() => _DoctorManagementScreenState();
}

class _DoctorManagementScreenState extends State<DoctorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDoctors();
      context.read<AdminProvider>().fetchPolyclinics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final doctors = provider.doctors.where((d) => 
      (d.user?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
      (d.specialization?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
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
                                    'Manajemen Staf',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${provider.doctors.length} tenaga medis aktif',
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
                                      hintText: 'Cari staf...',
                                      border: InputBorder.none,
                                      icon: Icon(Icons.search, size: 20, color: Colors.grey),
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

            // Doctor List
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.fetchDoctors,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Tenaga Medis'),
                      const SizedBox(height: 16),
                      if (provider.isLoading && provider.doctors.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else if (doctors.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Text('Tidak ada staf yang cocok dengan pencarian'),
                        ))
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
                              delay: Duration(milliseconds: 100 * index),
                              child: AdminDoctorCard(
                                doctor: doc,
                                onEdit: () => AdminDoctorFormSheet.show(context, doctor: doc),
                                onDelete: () => _confirmDeleteDoctor(context, doc),
                              ),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 30),
                      
                      // Stats Card
                      _availabilityCard(provider),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: const AdminBottomNav(activeIndex: 1),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 76),
          child: FloatingActionButton(
            onPressed: () => AdminDoctorFormSheet.show(context),
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  void _confirmDeleteDoctor(BuildContext context, DoctorModel doc) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Hapus Dokter',
      'Apakah Anda yakin ingin menghapus ${doc.user?.name}?',
      confirmText: 'HAPUS',
      isDestructive: true,
    );

    if (confirm == true && context.mounted) {
      await context.read<AdminProvider>().deleteDoctor(doc.id);
    }
  }

  Widget _availabilityCard(AdminProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Ketersediaan Loket',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('${provider.polyclinics.length}', 'Poli Aktif'),
              Container(width: 1, height: 32, color: Colors.grey.shade200),
              _statItem('${provider.doctors.length}', 'Total Dokter'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
