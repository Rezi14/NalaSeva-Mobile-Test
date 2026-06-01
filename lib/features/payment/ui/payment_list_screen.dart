import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../logic/payment_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'payment_detail_screen.dart';
import '../../admin/widgets/admin_bottom_nav.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppTheme.successColor;
      case 'waiting_verification':
        return AppTheme.warningColor;
      case 'failed':
        return AppTheme.errorColor;
      default:
        return AppTheme.secondaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Lunas';
      case 'waiting_verification':
        return 'Menunggu Verifikasi';
      case 'failed':
        return 'Gagal';
      default:
        return 'Belum Bayar';
    }
  }

  Widget _filterChip({required String label, required String? status}) {
    final isSelected = _selectedStatusFilter == status;
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
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? status : null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        bottomNavigationBar: const AdminBottomNav(activeIndex: 3),
        body: Consumer<PaymentProvider>(
          builder: (context, provider, child) {
            final filteredPayments = provider.payments.where((p) {
              final matchesSearch = p.transactionNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (p.queue?.patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                  (p.queue?.polyclinic.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
              
              final matchesStatus = _selectedStatusFilter == null || p.status == _selectedStatusFilter;
              
              return matchesSearch && matchesStatus;
            }).toList();

            return Column(
              children: [
                // Premium Header Block
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimationConfiguration.staggeredList(
                                position: 0,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 30.0,
                                  child: FadeInAnimation(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Manajemen Pembayaran',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Kelola riwayat & tagihan pembayaran pasien',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Search Input Column
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
                                              hintText: 'Cari no transaksi, pasien, poli...',
                                              hintStyle: GoogleFonts.plusJakartaSans(
                                                color: Colors.grey.shade400,
                                                fontSize: 14,
                                              ),
                                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                                              suffixIcon: _searchQuery.isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(Icons.clear_rounded, size: 20, color: Colors.grey),
                                                      onPressed: () {
                                                        _searchController.clear();
                                                        setState(() => _searchQuery = '');
                                                      },
                                                    )
                                                  : null,
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
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Filter horizontal ChoiceChips
                              AnimationConfiguration.staggeredList(
                                position: 2,
                                duration: const Duration(milliseconds: 375),
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
                // Rest of the List in Expanded
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<PaymentProvider>().fetchMyPayments(),
                    child: Builder(
                      builder: (context) {
                        if (provider.isLoading && provider.payments.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (provider.error != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.error!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => provider.fetchMyPayments(),
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (filteredPayments.isEmpty) {
                          final isFiltering = _selectedStatusFilter != null || _searchQuery.isNotEmpty;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isFiltering ? Icons.search_off_rounded : Icons.receipt_long_rounded,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isFiltering ? 'Tidak ada hasil pencarian/filter' : 'Belum ada tagihan pembayaran',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }

                        return AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: filteredPayments.length,
                            itemBuilder: (context, index) {
                              final payment = filteredPayments[index];
                              final queueDate = payment.queue?.date ?? '';
                              final polyClinicName = payment.queue?.polyclinic.name ?? 'Poli Puskesmas';

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 450),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentDetailScreen(payment: payment),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    payment.transactionNumber,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey[800],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(payment.status).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    _getStatusText(payment.status),
                                                    style: TextStyle(
                                                      color: _getStatusColor(payment.status),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      polyClinicName,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      queueDate.isNotEmpty
                                                          ? DateFormat('dd MMMM yyyy').format(DateTime.parse(queueDate))
                                                          : 'Kunjungan Hari Ini',
                                                      style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  _formatCurrency(payment.totalAmount),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppTheme.secondaryColor,
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
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
