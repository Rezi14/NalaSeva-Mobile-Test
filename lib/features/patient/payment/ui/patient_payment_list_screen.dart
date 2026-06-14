import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../shared/providers/payment_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'patient_payment_detail_screen.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/patient_payment_card.dart';

class PatientPaymentListScreen extends StatefulWidget {
  const PatientPaymentListScreen({super.key});

  @override
  State<PatientPaymentListScreen> createState() =>
      _PatientPaymentListScreenState();
}

class _PatientPaymentListScreenState extends State<PatientPaymentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _filterScrollController = ScrollController();
  String _searchQuery = '';
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchMyPayments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  Widget _filterChip({required String label, required String? status}) {
    final isSelected = _selectedStatusFilter == status;
    return GestureDetector(
      onTap: () => setState(
          () => _selectedStatusFilter = isSelected ? null : status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Consumer<PaymentProvider>(
          builder: (context, provider, child) {
            final filteredPayments = provider.payments.where((p) {
              final matchesSearch = p.transactionNumber
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  (p.queue?.patient.fullName
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ??
                      false) ||
                  (p.queue?.polyclinic.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ??
                      false);
              final matchesStatus = _selectedStatusFilter == null ||
                  p.status == _selectedStatusFilter;
              return matchesSearch && matchesStatus;
            }).toList();

            return ResponsiveCenter(
              maxWidth: 850,
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
                          padding:
                              const EdgeInsets.fromLTRB(24, 24, 24, 20),
                          child: AnimationLimiter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimationConfiguration.staggeredList(
                                  position: 0,
                                  duration:
                                      const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 30.0,
                                    child: FadeInAnimation(
                                      child: Row(
                                        children: [
                                          if (Navigator.canPop(
                                              context)) ...[
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                              ),
                                              child: IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: const Icon(
                                                  Icons
                                                      .arrow_back_ios_new_rounded,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ],
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Riwayat Pembayaran',
                                                  style:
                                                      GoogleFonts.poppins(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Pantau tagihan & pembayaran Anda',
                                                  style:
                                                      GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.85),
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
                                  duration:
                                      const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 30.0,
                                    child: FadeInAnimation(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: (val) => setState(
                                              () => _searchQuery = val),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          decoration: InputDecoration(
                                            hintText:
                                                'Cari no transaksi, pasien, poli...',
                                            hintStyle: GoogleFonts.poppins(
                                              color: Colors.grey.shade400,
                                              fontSize: 14,
                                            ),
                                            prefixIcon: const Icon(
                                                Icons.search_rounded,
                                                size: 20,
                                                color: Colors.grey),
                                            suffixIcon:
                                                _searchQuery.isNotEmpty
                                                    ? IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .clear_rounded,
                                                            size: 20,
                                                            color:
                                                                Colors.grey),
                                                        onPressed: () {
                                                          _searchController
                                                              .clear();
                                                          setState(() =>
                                                              _searchQuery =
                                                                  '');
                                                        },
                                                      )
                                                    : null,
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 16),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: Colors.white,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                AnimationConfiguration.staggeredList(
                                  position: 2,
                                  duration:
                                      const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 30.0,
                                    child: FadeInAnimation(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        child: Row(
                                          children: [
                                            _filterChip(label: 'Semua', status: null),
                                            const SizedBox(width: 8),
                                            _filterChip(label: 'Belum Bayar', status: 'pending'),
                                            const SizedBox(width: 8),
                                            _filterChip(label: 'Verifikasi', status: 'waiting_verification'),
                                            const SizedBox(width: 8),
                                            _filterChip(label: 'Lunas', status: 'paid'),
                                            const SizedBox(width: 8),
                                            _filterChip(label: 'Gagal', status: 'failed'),
                                          ],
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
                    ),
                  ),

                  // List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          context.read<PaymentProvider>().fetchMyPayments(),
                      child: Builder(
                        builder: (context) {
                          if (provider.isLoading &&
                              provider.payments.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (provider.error != null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        size: 64, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text(
                                      provider.error!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () =>
                                          provider.fetchMyPayments(),
                                      child: const Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (filteredPayments.isEmpty) {
                            final isFiltering =
                                _selectedStatusFilter != null ||
                                    _searchQuery.isNotEmpty;
                            return SingleChildScrollView(
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
                                        isFiltering
                                            ? Icons.search_off_rounded
                                            : Icons.receipt_long_rounded,
                                        size: 64,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      isFiltering
                                          ? 'Hasil Tidak Ditemukan'
                                          : 'Belum Ada Tagihan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      isFiltering
                                          ? 'Tidak ada data yang cocok. Coba atur ulang pencarian.'
                                          : 'Belum ada catatan tagihan pembayaran yang terdaftar.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (isFiltering) ...[
                                      const SizedBox(height: 24),
                                      OutlinedButton.icon(
                                        onPressed: () => setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                          _selectedStatusFilter = null;
                                        }),
                                        icon: const Icon(
                                            Icons.refresh_rounded,
                                            size: 18),
                                        label: Text(
                                          'Reset Pencarian & Filter',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppTheme.primaryColor,
                                          side: BorderSide(
                                              color: AppTheme.primaryColor
                                                  .withValues(alpha: 0.5)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }

                          return AnimationLimiter(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: filteredPayments.length,
                              itemBuilder: (context, index) {
                                final payment = filteredPayments[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration:
                                      const Duration(milliseconds: 450),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: PatientPaymentCard(
                                        payment: payment,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PatientPaymentDetailScreen(
                                                      payment: payment),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}