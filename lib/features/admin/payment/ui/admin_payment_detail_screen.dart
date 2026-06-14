import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/providers/payment_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../shared/widgets/web_image_widget.dart';
import '../widgets/admin_payment_invoice_card.dart';
import '../../../../core/api/api_client.dart';

class AdminPaymentDetailScreen extends StatefulWidget {
  final PaymentModel payment;

  const AdminPaymentDetailScreen({super.key, required this.payment});

  @override
  State<AdminPaymentDetailScreen> createState() =>
      _AdminPaymentDetailScreenState();
}

class _AdminPaymentDetailScreenState extends State<AdminPaymentDetailScreen> {
  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  Color _getStatusColor(PaymentModel payment) {
    if (payment.status == 'pending' && payment.createdAt != null) {
      if (DateTime.now().difference(payment.createdAt!).inHours >= 2) {
        return AppTheme.errorColor;
      }
    }
    switch (payment.status) {
      case 'paid':
        return AppTheme.successColor;
      case 'waiting_verification':
        return AppTheme.warningColor;
      case 'failed':
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.secondaryColor;
    }
  }

  String _getStatusText(PaymentModel payment) {
    if (payment.status == 'pending' && payment.createdAt != null) {
      if (DateTime.now().difference(payment.createdAt!).inHours >= 2) {
        return 'Kadaluwarsa';
      }
    }
    switch (payment.status) {
      case 'paid':
        return 'Lunas';
      case 'waiting_verification':
        return 'Menunggu Verifikasi';
      case 'failed':
        return 'Gagal';
      case 'cancelled':
        return 'Batal / Kadaluwarsa';
      default:
        return 'Belum Bayar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final payments = context.watch<PaymentProvider>().payments;
    final payment = payments.firstWhere(
      (p) => p.id == widget.payment.id,
      orElse: () => widget.payment,
    );
    final examination = payment.examination;
    final prescriptionItems = examination?.prescriptionItems ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: ResponsiveCenter(
          maxWidth: 800,
          child: Column(
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detail Tagihan',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              payment.transactionNumber,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFDCEEE7), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.06),
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
                                Text(
                                  'Status Pembayaran',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(payment)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _getStatusText(payment),
                                    style: GoogleFonts.poppins(
                                      color: _getStatusColor(payment),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No. Transaksi: ${payment.transactionNumber}',
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            if (payment.paidAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Waktu Lunas: ${DateFormat('dd MMMM yyyy, HH:mm WIB').format(payment.paidAt!.toLocal())}',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      AdminPaymentInvoiceCard(
                        payment: payment,
                        prescriptionItems: prescriptionItems,
                      ),
                      const SizedBox(height: 28),

                      // Pending / failed
                      if (payment.status == 'pending' ||
                          payment.status == 'failed') ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: const Color(0xFFDCEEE7), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.payments_rounded,
                                  size: 48, color: AppTheme.primaryColor),
                              const SizedBox(height: 12),
                              Text(
                                'Metode Pembayaran Tunai (Cash)',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gunakan tombol ini jika pasien membayar secara tunai langsung di kasir Puskesmas.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: ResponsiveHelper.buttonHeight(context),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.radiusButton(
                                              context)),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_rounded,
                                      color: Colors.white),
                                  label: Text(
                                    'VERIFIKASI BAYAR TUNAI',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    final confirm = await AppDialogs
                                        .showConfirmationDialog(
                                      context,
                                      'Konfirmasi Pembayaran Tunai',
                                      'Apakah Anda yakin ingin memproses pembayaran tunai sebesar ${_formatCurrency(payment.totalAmount)}?',
                                      confirmText: 'Lunas',
                                      cancelText: 'Batal',
                                    );
                                    if (confirm ?? false) {
                                      if (!context.mounted) return;
                                      try {
                                        await context
                                            .read<PaymentProvider>()
                                            .payWithCash(payment.id);
                                        if (context.mounted) {
                                          AppDialogs.showSuccessDialog(
                                              context,
                                              'Berhasil',
                                              'Pembayaran tunai berhasil diverifikasi!');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppDialogs.showNotificationDialog(
                                              context,
                                              'Gagal',
                                              e.toString(),
                                              isError: true);
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Waiting verification
                      ] else if (payment.status == 'waiting_verification') ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: const Color(0xFFDCEEE7), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded,
                                      color: AppTheme.warningColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Persetujuan Pembayaran QRIS',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (payment.paymentProofUrl != null) ...[
                                Text(
                                  'Bukti Transfer Pasien:',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    final String proofImageUrl =
                                        '${ApiClient.baseUrl}payments/${payment.id}/proof-image';
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: createWebImage(
                                        imageUrl: proofImageUrl,
                                        height: 350,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: Text(
                                    'Bukti transfer tidak diunggah oleh pasien',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.errorColor,
                                        side: const BorderSide(
                                            color: AppTheme.errorColor),
                                        minimumSize: Size(0,
                                            ResponsiveHelper.buttonHeight(
                                                context)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              ResponsiveHelper.radiusButton(
                                                  context)),
                                        ),
                                      ),
                                      icon: const Icon(Icons.close_rounded),
                                      label: Text('TOLAK',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () async {
                                        final confirm = await AppDialogs
                                            .showConfirmationDialog(
                                          context,
                                          'Tolak Pembayaran?',
                                          'Apakah Anda yakin ingin MENOLAK verifikasi bukti pembayaran QRIS ini?',
                                          confirmText: 'Tolak',
                                          cancelText: 'Batal',
                                          isDestructive: true,
                                        );
                                        if (confirm ?? false) {
                                          if (!context.mounted) return;
                                          try {
                                            await context
                                                .read<PaymentProvider>()
                                                .verify(payment.id, 'failed');
                                            if (context.mounted) {
                                              AppDialogs.showSuccessDialog(
                                                  context,
                                                  'Berhasil',
                                                  'Pembayaran QRIS telah ditolak.');
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              AppDialogs.showNotificationDialog(
                                                  context,
                                                  'Gagal',
                                                  e.toString(),
                                                  isError: true);
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.successColor,
                                        minimumSize: Size(0,
                                            ResponsiveHelper.buttonHeight(
                                                context)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              ResponsiveHelper.radiusButton(
                                                  context)),
                                        ),
                                      ),
                                      icon: const Icon(Icons.check_rounded,
                                          color: Colors.white),
                                      label: Text('TERIMA',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      onPressed: () async {
                                        final confirm = await AppDialogs
                                            .showConfirmationDialog(
                                          context,
                                          'Terima Pembayaran?',
                                          'Apakah Anda yakin ingin MENERIMA verifikasi bukti pembayaran QRIS ini?',
                                          confirmText: 'Lunas',
                                          cancelText: 'Batal',
                                        );
                                        if (confirm ?? false) {
                                          if (!context.mounted) return;
                                          try {
                                            await context
                                                .read<PaymentProvider>()
                                                .verify(payment.id, 'paid');
                                            if (context.mounted) {
                                              AppDialogs.showSuccessDialog(
                                                  context,
                                                  'Berhasil',
                                                  'Pembayaran QRIS telah disetujui (Lunas)!');
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              AppDialogs.showNotificationDialog(
                                                  context,
                                                  'Gagal',
                                                  e.toString(),
                                                  isError: true);
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // Paid
                      ] else if (payment.status == 'paid') ...[
                        if (payment.paymentProofUrl != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: const Color(0xFFDCEEE7), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bukti Transfer Pasien:',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 12),
                                Builder(
                                  builder: (context) {
                                    final String proofImageUrl =
                                        '${ApiClient.baseUrl}payments/${payment.id}/proof-image';
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: createWebImage(
                                        imageUrl: proofImageUrl,
                                        height: 350,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.successColor
                                    .withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.successColor
                                    .withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 56, color: AppTheme.successColor),
                              const SizedBox(height: 12),
                              Text(
                                'Pembayaran Sukses & Lunas!',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                payment.dispensedAt == null
                                    ? 'Pasien dapat mengambil obat di Loket Apotek setelah verifikasi lunas.'
                                    : 'Obat telah diserahkan oleh Apoteker.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
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