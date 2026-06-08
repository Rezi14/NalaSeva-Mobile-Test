import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/payment_model.dart';
import '../logic/pharmacy_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/tts_helper.dart';
import '../../../core/utils/app_dialogs.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final PaymentModel payment;

  const PrescriptionDetailScreen({super.key, required this.payment});

  @override
  State<PrescriptionDetailScreen> createState() => _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  bool _isProcessing = false;

  void _announcePatient() async {
    final patientName = widget.payment.queue?.patient.name ?? 'Pasien';
    final announcement = 'Panggilan kepada pasien $patientName, silakan mengambil obat Anda di loket Apotek.';

    try {
      await TtsHelper.speak(announcement);
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Panggilan Suara',
          'Memanggil suara loket: "$announcement"',
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal Memanggil',
          'Gagal membunyikan panggilan: $e',
          isError: true,
        );
      }
    }
  }

  void _showPaymentProofDialog(String proofPath) {
    // Generate absolute URL for Laravel storage
    // Base URL is typically 'https://nalaseva-api.up.railway.app/'
    final absoluteUrl = 'https://nalaseva-api.up.railway.app/storage/$proofPath';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Struk Bukti Pembayaran QRIS',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    absoluteUrl,
                    fit: BoxFit.contain,
                    height: 380,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 240,
                        color: Colors.grey[100],
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_rounded, size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Gagal memuat bukti bayar\n(Mungkin dalam lingkungan lokal)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dispensePrescription() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await context.read<PharmacyProvider>().dispense(widget.payment.id);

      if (mounted) {
        AppDialogs.showSuccessDialog(
          context,
          'Resep Diserahkan',
          'Obat sukses diserahkan! Stok obat di database otomatis berkurang.',
          onOkPressed: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            constraints: const BoxConstraints(maxWidth: 480),
            title: const Text('Gagal Menyerahkan Obat'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isPharmacist = user?.role == 'pharmacist';
    
    final patient = widget.payment.queue?.patient;
    final patientName = patient?.name ?? 'Pasien';
    final nationalId = patient?.nationalId ?? '-';
    final age = patient?.age ?? 0;
    final address = patient?.address ?? '-';
    final gender = patient?.gender ?? '-';

    final prescriptionItems = widget.payment.examination?.prescriptionItems ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Rincian Penyiapan Resep'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Details Card (With Integrated Payment Proof inside as requested!)
            const Text(
              'Profil Informasi Pasien',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NIK:', style: TextStyle(color: Colors.grey[600])),
                      Text(nationalId, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Usia:', style: TextStyle(color: Colors.grey[600])),
                      Text('$age Tahun ($gender)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Alamat:', style: TextStyle(color: Colors.grey[600])),
                      Expanded(
                        child: Text(
                          address,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // INTEGRASI BUKTI PEMBAYARAN langsung di profil pasien!
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status Pembayaran:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Lunas',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Button to view proof, only shown if paymentProof path exists
                  if (widget.payment.paymentProof != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.secondaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.secondaryColor),
                        label: const Text(
                          'Verifikasi Bukti QRIS Pasien',
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _showPaymentProofDialog(widget.payment.paymentProof!),
                      ),
                    ),
                  ] else ...[
                    // Cash payment or offline fallback
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          'Dibayar tunai / lunas via admin loket.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    )
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Prescription Items List Card
            const Text(
              'Rincian Resep Obat Dokter',
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
                  if (prescriptionItems.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Resep kosong / tidak ada obat yang diresepkan'),
                    )
                  ] else ...[
                    ...prescriptionItems.map((item) {
                      final name = item.medicine?.name ?? 'Obat';
                      final qty = item.quantity;
                      final unit = item.medicine?.unit ?? 'tablet';
                      final instruction = item.instruction;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dosis: $instruction',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$qty $unit',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  ]
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons (Voice Call + Serah Terima Obat)
            Row(
              children: [
                // Voice Announcement Button using TtsHelper
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: _announcePatient,
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
                if (isPharmacist) ...[
                  const SizedBox(width: 16),
                  // Dispense Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isProcessing ? null : _dispensePrescription,
                        child: _isProcessing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Serahkan Obat (Selesai)',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Hanya Apoteker yang dapat menyerahkan obat',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
