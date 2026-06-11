import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/payment_model.dart';
import '../../../core/theme/app_theme.dart';

class PatientPaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onTap;

  const PatientPaymentCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

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
    final queueDate = payment.queue?.date ?? '';
    final polyClinicName = payment.queue?.polyclinic.name ?? 'Poli Puskesmas';

    return GestureDetector(
      onTap: onTap,
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
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payment).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getStatusText(payment),
                    style: GoogleFonts.plusJakartaSans(
                      color: _getStatusColor(payment),
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      queueDate.isNotEmpty
                          ? DateFormat('dd MMMM yyyy').format(DateTime.parse(queueDate))
                          : 'Kunjungan Hari Ini',
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(payment.totalAmount),
                  style: GoogleFonts.plusJakartaSans(
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
    );
  }
}
