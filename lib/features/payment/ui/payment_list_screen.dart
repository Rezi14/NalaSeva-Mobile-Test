import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../logic/payment_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'payment_detail_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchMyPayments();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Riwayat & Tagihan Pembayaran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PaymentProvider>().fetchMyPayments(),
        child: Consumer<PaymentProvider>(
          builder: (context, provider, child) {
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

            if (provider.payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada tagihan pembayaran',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: provider.payments.length,
                itemBuilder: (context, index) {
                  final payment = provider.payments[index];
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
    );
  }
}
