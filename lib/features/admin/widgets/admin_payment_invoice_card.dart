import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/payment_model.dart';
import '../../../core/theme/app_theme.dart';

class AdminPaymentInvoiceCard extends StatelessWidget {
  final PaymentModel payment;
  final List<dynamic> prescriptionItems;

  const AdminPaymentInvoiceCard({
    super.key,
    required this.payment,
    required this.prescriptionItems,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rincian Biaya Layanan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biaya Layanan Puskesmas',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  Text(
                    _formatCurrency(payment.registrationFee),
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 24),

              if (prescriptionItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Biaya Resep Obat',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatCurrency(payment.medicineFee),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...prescriptionItems.map((item) {
                  final name = item.medicine?.name ?? 'Obat';
                  final price = item.price;
                  final qty = item.quantity;
                  final total = price * qty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$name ($qty x ${_formatCurrency(price)})',
                            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
                          ),
                        ),
                        Text(
                          _formatCurrency(total),
                          style: GoogleFonts.inter(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900),
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
      ],
    );
  }
}
