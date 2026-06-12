import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../logic/admin_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'admin_booking_detail_screen.dart';
import '../../dashboard/widgets/admin_mini_stat_card.dart';
import '../../patient/widgets/admin_patient_card.dart';
import 'qr_scanner_page.dart';
import '../../dashboard/widgets/admin_bottom_nav.dart';
import '../../../../core/utils/responsive_helper.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // State variables for filter
  String? _selectedStatusFilter = QueueStatus.booked.value; 
  String? _selectedPolyclinicId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchQueues();
      context.read<AdminProvider>().fetchPolyclinics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    
    final filteredQueues = provider.queues.where((q) {
      final matchesSearch = q.patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.queueNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatusFilter == null || q.status.value == _selectedStatusFilter;
      
      final matchesPolyclinic = _selectedPolyclinicId == null || q.polyclinic.id.toString() == _selectedPolyclinicId;
      
      return matchesSearch && matchesStatus && matchesPolyclinic;
    }).toList();

    final total = provider.queues.length;
    final served = provider.queues.where((q) => q.status == QueueStatus.completed).length;
    final waiting = provider.queues.where((q) => q.status == QueueStatus.waiting).length;
    final examining = provider.queues.where((q) => q.status == QueueStatus.examining).length;
    final cancelled = provider.queues.where((q) => q.status == QueueStatus.cancelled).length;
    
    final hasActiveFilter = _selectedStatusFilter != null || _selectedPolyclinicId != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        floatingActionButton: ResponsiveCenter(
          maxWidth: 900,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: FloatingActionButton.extended(
                onPressed: () => _openScanner(context),
                backgroundColor: AppTheme.primaryColor,
                elevation: 4,
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  'SCAN ABSENSI',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: ResponsiveCenter(
          maxWidth: 900,
          child: Column(
            children: [
            // Header - static fade container with staggered slides
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
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Manajemen Antrean',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Kelola pendaftaran pasien hari ini',
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
                                          hintText: 'Cari nama atau nomor antrean...',
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

             // List with Stats Row integrated inside to scroll together
             Expanded(
               child: RefreshIndicator(
                 onRefresh: provider.fetchQueues,
                 child: provider.isLoading && provider.queues.isEmpty
                     ? const Center(child: CircularProgressIndicator())
                     : ListView.builder(
                         padding: const EdgeInsets.all(24),
                         itemCount: filteredQueues.isEmpty ? 3 : filteredQueues.length + 2,
                         itemBuilder: (context, index) {
                           if (index == 0) {
                             // Stats Row at index 0 of the scrollable list
                             return FadeInUp(
                               duration: const Duration(milliseconds: 500),
                               delay: const Duration(milliseconds: 250),
                               child: Padding(
                                 padding: const EdgeInsets.only(bottom: 24),
                                 child: SingleChildScrollView(
                                   scrollDirection: Axis.horizontal,
                                   child: Row(
                                     children: [
                                       AdminMiniStatCard(width: 100, label: 'Total', value: total.toString(), bgColor: Colors.white, textColor: Colors.black87, border: true),
                                       const SizedBox(width: 12),
                                       AdminMiniStatCard(width: 100, label: 'Dilayani', value: served.toString(), bgColor: AppTheme.successColor.withValues(alpha: 0.1), textColor: AppTheme.successColor),
                                       const SizedBox(width: 12),
                                       AdminMiniStatCard(width: 100, label: 'Menunggu', value: waiting.toString(), bgColor: AppTheme.warningColor.withValues(alpha: 0.1), textColor: AppTheme.warningColor),
                                       const SizedBox(width: 12),
                                       AdminMiniStatCard(width: 100, label: 'Diperiksa', value: examining.toString(), bgColor: AppTheme.secondaryColor.withValues(alpha: 0.1), textColor: AppTheme.secondaryColor),
                                       const SizedBox(width: 12),
                                       AdminMiniStatCard(width: 100, label: 'Batal', value: cancelled.toString(), bgColor: AppTheme.cancelColor.withValues(alpha: 0.1), textColor: AppTheme.cancelColor),
                                     ],
                                   ),
                                 ),
                               ),
                             );
                           }

                           if (index == 1) {
                             // Section Header label
                             return FadeInUp(
                               duration: const Duration(milliseconds: 500),
                               delay: const Duration(milliseconds: 320),
                               child: Padding(
                                 padding: const EdgeInsets.only(bottom: 12),
                                 child: Text(
                                   'Pendaftaran Terbaru',
                                   style: GoogleFonts.plusJakartaSans(
                                     fontWeight: FontWeight.bold,
                                     color: Colors.grey,
                                     fontSize: 13,
                                   ),
                                 ),
                               ),
                             );
                           }

                           if (filteredQueues.isEmpty) {
                             // Premium Empty State at index 2 if search results/queues are empty
                             final isSearchingOrFiltering = hasActiveFilter || _searchQuery.isNotEmpty;
                             return FadeInUp(
                               duration: const Duration(milliseconds: 500),
                               delay: const Duration(milliseconds: 200),
                               child: Container(
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
                                         isSearchingOrFiltering
                                             ? Icons.search_off_rounded
                                             : Icons.hourglass_disabled_rounded,
                                         size: 64,
                                         color: AppTheme.primaryColor,
                                       ),
                                     ),
                                     const SizedBox(height: 24),
                                     Text(
                                       isSearchingOrFiltering
                                           ? 'Hasil Tidak Ditemukan'
                                           : 'Antrean Hari Ini Kosong',
                                       style: GoogleFonts.plusJakartaSans(
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.black87,
                                       ),
                                       textAlign: TextAlign.center,
                                      ),
                                     const SizedBox(height: 12),
                                     Text(
                                       isSearchingOrFiltering
                                           ? 'Tidak ada nomor antrean atau nama pasien yang cocok dengan pencarian Anda. Silakan periksa kembali filter Anda.'
                                           : 'Belum ada pasien yang melakukan pendaftaran antrean hari ini. Semua data antrean akan muncul di sini setelah pasien mendaftar.',
                                       style: GoogleFonts.plusJakartaSans(
                                         fontSize: 13,
                                         color: Colors.grey.shade600,
                                         height: 1.5,
                                       ),
                                       textAlign: TextAlign.center,
                                     ),
                                     if (isSearchingOrFiltering) ...[
                                       const SizedBox(height: 24),
                                       OutlinedButton.icon(
                                         onPressed: () {
                                           setState(() {
                                             _searchController.clear();
                                             _searchQuery = '';
                                             _selectedStatusFilter = null;
                                             _selectedPolyclinicId = null;
                                           });
                                         },
                                         icon: const Icon(Icons.refresh_rounded, size: 18),
                                         label: Text(
                                           'Reset Filter & Pencarian',
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

                           // Queue Patient Card item
                           final q = filteredQueues[index - 2];
                           return FadeInUp(
                             duration: const Duration(milliseconds: 500),
                             delay: Duration(milliseconds: 400 + ((index - 2) * 80)),
                             child: Padding(
                               padding: const EdgeInsets.only(bottom: 16),
                               child: AdminPatientCard(
                                 queue: q,
                                 onTap: () {
                                   final provider = context.read<AdminProvider>();
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                       builder: (context) => AdminBookingDetailScreen(queue: q),
                                     ),
                                   ).then((_) {
                                     if (mounted) {
                                       provider.fetchQueues();
                                     }
                                   });
                                 },
                               ),
                             ),
                           );
                         },
                       ),
               ),
             ),

              // Bottom Navigation
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: const AdminBottomNav(activeIndex: 1),
              ),
            ],
          ),
        ),
      ),
    );
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
            final hasActiveFilter = _selectedStatusFilter != null || _selectedPolyclinicId != null;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Antrean',
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
                                _selectedStatusFilter = null;
                                _selectedPolyclinicId = null;
                              });
                              setSheetState(() {
                                _selectedStatusFilter = null;
                                _selectedPolyclinicId = null;
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

                    // Filter Status
                    Text(
                      'Status Antrean',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip(
                          label: 'Semua',
                          isSelected: _selectedStatusFilter == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedStatusFilter = null);
                              setSheetState(() => _selectedStatusFilter = null);
                            }
                          },
                        ),
                        _filterChip(
                          label: 'Booking',
                          isSelected: _selectedStatusFilter == QueueStatus.booked.value,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedStatusFilter = QueueStatus.booked.value);
                              setSheetState(() => _selectedStatusFilter = QueueStatus.booked.value);
                            }
                          },
                        ),
                        _filterChip(
                          label: 'Menunggu',
                          isSelected: _selectedStatusFilter == QueueStatus.waiting.value,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedStatusFilter = QueueStatus.waiting.value);
                              setSheetState(() => _selectedStatusFilter = QueueStatus.waiting.value);
                            }
                          },
                        ),
                        _filterChip(
                          label: 'Dilayani',
                          isSelected: _selectedStatusFilter == QueueStatus.completed.value,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedStatusFilter = QueueStatus.completed.value);
                              setSheetState(() => _selectedStatusFilter = QueueStatus.completed.value);
                            }
                          },
                        ),
                        _filterChip(
                          label: 'Diperiksa',
                          isSelected: _selectedStatusFilter == QueueStatus.examining.value,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedStatusFilter = QueueStatus.examining.value);
                              setSheetState(() => _selectedStatusFilter = QueueStatus.examining.value);
                            }
                          },
                        ),
                        _filterChip(
                          label: 'Batal',
                          isSelected: _selectedStatusFilter == QueueStatus.cancelled.value,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedStatusFilter = QueueStatus.cancelled.value);
                              setSheetState(() => _selectedStatusFilter = QueueStatus.cancelled.value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip(
                          label: 'Semua',
                          isSelected: _selectedPolyclinicId == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedPolyclinicId = null);
                              setSheetState(() => _selectedPolyclinicId = null);
                            }
                          },
                        ),
                        ...provider.polyclinics.map((poly) {
                          final isSelected = _selectedPolyclinicId == poly.id.toString();
                          return _filterChip(
                            label: poly.name,
                            isSelected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedPolyclinicId = poly.id.toString());
                                setSheetState(() => _selectedPolyclinicId = poly.id.toString());
                              }
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

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

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.grey.shade100,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: onSelected,
    );
  }

  void _openScanner(BuildContext context) {
    final provider = context.read<AdminProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    ).then((_) {
      if (!context.mounted) return;
      provider.fetchQueues();
    });
  }
}
