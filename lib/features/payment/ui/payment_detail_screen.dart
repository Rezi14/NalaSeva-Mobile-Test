import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/models/payment_model.dart';
import '../logic/payment_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';

class PaymentDetailScreen extends StatefulWidget {
  final PaymentModel payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  bool _isUploading = false;
  String _merchantName = 'Puskesmas NalaSeva Mandiri';
  String _nmid = 'ID102930293019';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadQrisSettings();
    if (widget.payment.status == 'waiting_verification') {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    _stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (timer) async {
      try {
        final provider = context.read<PaymentProvider>();
        await provider.fetchMyPayments();
        final currentPayment = provider.payments.firstWhere((p) => p.id == widget.payment.id);
        if (currentPayment.status == 'paid' || currentPayment.status == 'failed') {
          _stopPolling();
        }
      } catch (e) {
        // Silent error to prevent UI crash during network issue in polling
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
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

    // Sisi Klien: Validasi Ekstensi File & Ukuran Maksimal 2MB
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
              _startPolling();
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
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
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
                      const Text(
                        'Status Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(payment.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getStatusText(payment.status),
                          style: TextStyle(
                            color: _getStatusColor(payment.status),
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (payment.paidAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Waktu Lunas: ${DateFormat('dd MMMM yyyy, HH:mm WIB').format(payment.paidAt!.toLocal())}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rincian Biaya/Invoice Card
            const Text(
              'Rincian Biaya Layanan',
              style: TextStyle(
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
                  // Biaya Registrasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biaya Layanan Puskesmas',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        _formatCurrency(payment.registrationFee),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Biaya Resep Obat jika ada
                  if (prescriptionItems.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Biaya Resep Obat',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatCurrency(payment.medicineFee),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Itemized Medicines List
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
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ),
                            Text(
                              _formatCurrency(total),
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                  ],

                  // Total Tagihan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
            const SizedBox(height: 28),

            // QRIS Statis Section (jika belum lunas)
            if (payment.status == 'pending' || payment.status == 'failed') ...[
              const Center(
                child: Text(
                  'METODE PEMBAYARAN: QRIS STATIS',
                  style: TextStyle(
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
                      // Header QRIS mockup
                      Image.asset(
                        'assets/logo.png', // Fallback header
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'QRIS - STANDAR NASIONAL',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.indigo,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Generator QR Code Real
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'NMID: $_nmid',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tombol Unggah Bukti
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
                      style: const TextStyle(
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
                      const Text(
                        'Menunggu Verifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Petugas sedang mencocokkan pembayaran QRIS Anda dengan sistem mutasi bank. Notifikasi akan segera muncul saat obat siap diambil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.warningColor.withValues(red: 100, green: 50, blue: 0), fontSize: 13),
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
                      const Text(
                        'Pembayaran Sukses & Lunas!',
                        style: TextStyle(
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
                        style: TextStyle(color: AppTheme.successColor.withValues(red: 0, green: 100, blue: 50), fontSize: 13),
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
    );
  }
}
