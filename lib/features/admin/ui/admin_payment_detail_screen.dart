import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../shared/models/payment_model.dart';
import '../../../shared/providers/payment_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/web_image_widget.dart';
import '../widgets/admin_payment_invoice_card.dart';
import '../../../core/api/api_client.dart';

class AdminPaymentDetailScreen extends StatefulWidget {
  final PaymentModel payment;

  const AdminPaymentDetailScreen({super.key, required this.payment});

  @override
  State<AdminPaymentDetailScreen> createState() => _AdminPaymentDetailScreenState();
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
      final diff = DateTime.now().difference(payment.createdAt!);
      if (diff.inHours >= 2) {
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
      final diff = DateTime.now().difference(payment.createdAt!);
      if (diff.inHours >= 2) {
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
      backgroundColor: AppTheme.backgroundColor,
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            // Premium Header with Back Button
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detail Tagihan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              payment.transactionNumber,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey,
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
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Tagihan Card
                    Container(
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
                              Text(
                                'Status Pembayaran',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(payment).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _getStatusText(payment),
                                  style: GoogleFonts.plusJakartaSans(
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
                            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
                          ),
                          if (payment.paidAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Waktu Lunas: ${DateFormat('dd MMMM yyyy, HH:mm WIB').format(payment.paidAt!.toLocal())}',
                              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
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

                    // Admin-Specific Layout Branches based on payment status:
                    if (payment.status == 'pending' || payment.status == 'failed') ...[
                      Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.payments_rounded, size: 48, color: AppTheme.primaryColor),
                              const SizedBox(height: 12),
                              Text(
                                'Metode Pembayaran Tunai (Cash)',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gunakan tombol ini jika pasien membayar secara tunai langsung di kasir Puskesmas.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                                  label: Text(
                                    'VERIFIKASI BAYAR TUNAI',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    final confirm = await AppDialogs.showConfirmationDialog(
                                      context,
                                      'Konfirmasi Pembayaran Tunai',
                                      'Apakah Anda yakin ingin memproses pembayaran tunai sebesar ${_formatCurrency(payment.totalAmount)}?',
                                      confirmText: 'YA, LUNAS',
                                      cancelText: 'BATAL',
                                    );
                                    if (confirm ?? false) {
                                      if (!context.mounted) return;
                                      try {
                                        await context.read<PaymentProvider>().payWithCash(payment.id);
                                        if (context.mounted) {
                                          AppDialogs.showSuccessDialog(context, 'Berhasil', 'Pembayaran tunai berhasil diverifikasi!');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppDialogs.showNotificationDialog(context, 'Gagal', e.toString(), isError: true);
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (payment.status == 'waiting_verification') ...[
                      Center(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
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
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: AppTheme.warningColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Persetujuan Pembayaran QRIS',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (payment.paymentProofUrl != null) ...[
                                Text(
                                  'Bukti Transfer Pasien:',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    final String proofImageUrl = '${ApiClient.baseUrl}payments/${payment.id}/proof-image';
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
                                  color: Colors.grey.shade50,
                                  child: Text(
                                    'Bukti transfer tidak diunggah oleh pasien',
                                    style: GoogleFonts.inter(),
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
                                        side: const BorderSide(color: AppTheme.errorColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        minimumSize: const Size(0, 48),
                                      ),
                                      icon: const Icon(Icons.close_rounded),
                                      label: Text(
                                        'TOLAK',
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        final confirm = await AppDialogs.showConfirmationDialog(
                                          context,
                                          'Tolak Pembayaran?',
                                          'Apakah Anda yakin ingin MENOLAK verifikasi bukti pembayaran QRIS ini?',
                                          confirmText: 'YA, TOLAK',
                                          cancelText: 'BATAL',
                                          isDestructive: true,
                                        );
                                        if (confirm ?? false) {
                                          if (!context.mounted) return;
                                          try {
                                            await context.read<PaymentProvider>().verify(payment.id, 'failed');
                                            if (context.mounted) {
                                              AppDialogs.showSuccessDialog(context, 'Berhasil', 'Pembayaran QRIS telah ditolak.');
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              AppDialogs.showNotificationDialog(context, 'Gagal', e.toString(), isError: true);
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        minimumSize: const Size(0, 48),
                                      ),
                                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                                      label: Text(
                                        'TERIMA',
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        final confirm = await AppDialogs.showConfirmationDialog(
                                          context,
                                          'Terima Pembayaran?',
                                          'Apakah Anda yakin ingin MENERIMA verifikasi bukti pembayaran QRIS ini?',
                                          confirmText: 'YA, LUNAS',
                                          cancelText: 'BATAL',
                                        );
                                        if (confirm ?? false) {
                                          if (!context.mounted) return;
                                          try {
                                            await context.read<PaymentProvider>().verify(payment.id, 'paid');
                                            if (context.mounted) {
                                              AppDialogs.showSuccessDialog(context, 'Berhasil', 'Pembayaran QRIS telah disetujui (Lunas)!');
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              AppDialogs.showNotificationDialog(context, 'Gagal', e.toString(), isError: true);
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
                      ),
                    ] else if (payment.status == 'paid') ...[
                      if (payment.paymentProofUrl != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
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
                              Text(
                                'Bukti Transfer Pasien:',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Builder(
                                builder: (context) {
                                  final String proofImageUrl = '${ApiClient.baseUrl}payments/${payment.id}/proof-image';
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
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 56, color: AppTheme.successColor),
                              const SizedBox(height: 12),
                              Text(
                                'Pembayaran Sukses & Lunas!',
                                style: GoogleFonts.plusJakartaSans(
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
                                style: GoogleFonts.inter(color: AppTheme.successColor.withValues(red: 0, green: 100, blue: 50), fontSize: 13),
                              ),
                            ],
                          ),
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
    );
  }
}
