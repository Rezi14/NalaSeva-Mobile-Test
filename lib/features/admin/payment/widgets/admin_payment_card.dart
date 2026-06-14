import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../core/theme/app_theme.dart';

class AdminPaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onTap;

  const AdminPaymentCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount);
  }

  Color _getStatusColor(PaymentModel payment) {
    if (payment.status == 'pending' && payment.createdAt != null) {
      if (DateTime.now().difference(payment.createdAt!).inHours >= 2) return AppTheme.errorColor;
    }
    switch (payment.status) {
      case 'paid': return AppTheme.successColor;
      case 'waiting_verification': return AppTheme.warningColor;
      case 'failed':
      case 'cancelled': return AppTheme.errorColor;
      default: return AppTheme.secondaryColor;
    }
  }

  String _getStatusText(PaymentModel payment) {
    if (payment.status == 'pending' && payment.createdAt != null) {
      if (DateTime.now().difference(payment.createdAt!).inHours >= 2) return 'Kadaluwarsa';
    }
    switch (payment.status) {
      case 'paid': return 'Lunas';
      case 'waiting_verification': return 'Menunggu Verifikasi';
      case 'failed': return 'Gagal';
      case 'cancelled': return 'Batal / Kadaluwarsa';
      default: return 'Belum Bayar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueDate = payment.queue?.date ?? '';
    final polyClinicName = payment.queue?.polyclinic.name ?? 'Poli Puskesmas';
    final statusColor = _getStatusColor(payment);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
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
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _getStatusText(payment),
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: Colors.white.withValues(alpha: 0.2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      polyClinicName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      queueDate.isNotEmpty
                          ? DateFormat('dd MMMM yyyy').format(DateTime.parse(queueDate))
                          : 'Kunjungan Hari Ini',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(payment.totalAmount),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}