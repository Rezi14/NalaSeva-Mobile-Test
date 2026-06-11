import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../shared/models/payment_model.dart';
import '../../../shared/providers/payment_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/responsive_helper.dart';

class PatientPaymentDetailScreen extends StatefulWidget {
  final PaymentModel payment;

  const PatientPaymentDetailScreen({super.key, required this.payment});

  @override
  State<PatientPaymentDetailScreen> createState() => _PatientPaymentDetailScreenState();
}

class _PatientPaymentDetailScreenState extends State<PatientPaymentDetailScreen> {
  bool _isUploading = false;
  String _merchantName = 'Puskesmas NalaSeva Mandiri';
  String _nmid = 'ID102930293019';

  @override
  void initState() {
    super.initState();
    _loadQrisSettings();
  }

  Future<void> _loadQrisSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _merchantName = prefs.getString('qris_merchant_name') ?? 'Puskesmas NalaSeva Mandiri';
        _nmid = prefs.getString('qris_nmid') ?? 'ID102930293019';
      });
    }
  }

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

  Future<void> _pickAndUploadProof() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Ambil Foto Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final path = pickedFile.path.toLowerCase();
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg') && !path.endsWith('.png')) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Format File Salah',
          'Bukti pembayaran harus berupa gambar dengan format JPG, JPEG, atau PNG.',
          isError: true,
        );
      }
      return;
    }

    final file = File(pickedFile.path);
    final int fileSize = await file.length();
    if (fileSize > 2 * 1024 * 1024) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Ukuran File Terlalu Besar',
          'Ukuran bukti pembayaran tidak boleh melebihi 2MB.',
          isError: true,
        );
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await context.read<PaymentProvider>().uploadProof(
        widget.payment.id,
        pickedFile.path,
      );

      if (mounted) {
        AppDialogs.showSuccessDialog(
          context,
          'Pembayaran QRIS',
          'Bukti pembayaran QRIS berhasil diunggah! Menunggu verifikasi admin.',
          onOkPressed: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal Mengunggah',
          'Gagal mengunggah bukti: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
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

                    // Rincian Biaya/Invoice Card
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
                    const SizedBox(height: 28),

                    // Patient-Specific Layout Branches based on payment status:
                    if (payment.status == 'pending' || payment.status == 'failed') ...[
                      Center(
                        child: Text(
                          'METODE PEMBAYARAN: QRIS STATIS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: 32,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    'QRIS - STANDAR NASIONAL',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.indigo,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              QrImageView(
                                data: 'qris_payload_nmid_${_nmid}_amount_${payment.totalAmount}_tx_${payment.transactionNumber}',
                                version: QrVersions.auto,
                                size: 220.0,
                                gapless: false,
                                embeddedImageStyle: const QrEmbeddedImageStyle(
                                  size: Size(40, 40),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _merchantName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'NMID: $_nmid',
                                style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: _isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                            label: Text(
                              _isUploading ? 'Mengirim Bukti Bayar...' : 'Pilih & Kirim Bukti Transfer',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: _isUploading ? null : _pickAndUploadProof,
                          ),
                        ),
                      ),
                    ] else if (payment.status == 'waiting_verification') ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.hourglass_empty_rounded, size: 56, color: AppTheme.warningColor),
                              const SizedBox(height: 12),
                              Text(
                                'Menunggu Verifikasi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.warningColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Petugas sedang mencocokkan pembayaran QRIS Anda dengan sistem mutasi bank. Notifikasi akan segera muncul saat obat siap diambil.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: AppTheme.warningColor.withValues(red: 100, green: 50, blue: 0), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (payment.status == 'paid') ...[
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
                                    ? 'Silakan tunjukkan layar HP ini kepada Apoteker di Loket Apotek untuk menerima obat Anda.'
                                    : 'Obat telah diserahkan oleh Apoteker. Semoga lekas sembuh!',
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
