import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../shared/models/payment_model.dart';
import '../../logic/pharmacy_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../shared/widgets/web_image_widget.dart';
import '../widgets/prescription_item_row.dart';
import '../../../../shared/constants/app_constants.dart';

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
        await context.read<PharmacyProvider>().callPatient(widget.payment.id);
      }

      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Panggilan Suara',
          'Memanggil suara loket: "$announcement" dan mengirim notifikasi ke pasien.',
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

  void _showPaymentProofDialog() {
    final absoluteUrl = 'https://nalaseva-api.up.railway.app/api/payments/${widget.payment.id}/proof-image';

    showDialog(
      context: context,
      builder: (context) {
        final radius  = ResponsiveHelper.radiusDialog(context);
        final padding = ResponsiveHelper.paddingDialog(context);
        final maxW    = ResponsiveHelper.dialogMaxWidth(context);
        final btnH    = ResponsiveHelper.buttonHeight(context);
        final btnR    = ResponsiveHelper.radiusButton(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          constraints: BoxConstraints(maxWidth: maxW),
          child: Container(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Struk Bukti Pembayaran QRIS',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.fontSizeHeading(context),
                  ),
                ),
                SizedBox(height: padding * 0.8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(btnR),
                  child: createWebImage(
                    imageUrl: absoluteUrl,
                    fit: BoxFit.contain,
                    height: 380,
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: padding),
                SizedBox(
                  width: double.infinity,
                  height: btnH,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(btnR),
                      ),
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.fontSizeButton(context),
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
        AppDialogs.showNotificationDialog(
          context,
          'Gagal Menyerahkan Obat',
          e.toString(),
          isError: true,
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
    
    final pagePadding = ResponsiveHelper.paddingPage(context);
    final cardPadding = ResponsiveHelper.paddingCard(context);
    final cardRadius = ResponsiveHelper.radiusCard(context);
    final textBodySize = ResponsiveHelper.fontSizeBody(context);
    final textHeadingSize = ResponsiveHelper.fontSizeHeading(context);
    final smallRadius = ResponsiveHelper.radiusSmall(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Premium Header with smooth bottom-up stagger
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
                  child: ResponsiveCenter(
                    maxWidth: 800,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rincian Resep',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Penyiapan dan penyerahan resep obat',
                              style: GoogleFonts.plusJakartaSans(
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
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Patient Details Card (With Integrated Payment Proof inside as requested!)
            Text(
              'Profil Informasi Pasien',
              style: TextStyle(
                fontSize: textHeadingSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(cardRadius),
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
                    style: TextStyle(fontSize: textBodySize + 6, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NIK:', style: TextStyle(color: Colors.grey[600], fontSize: textBodySize)),
                      Text(nationalId, style: TextStyle(fontWeight: FontWeight.bold, fontSize: textBodySize)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Usia:', style: TextStyle(color: Colors.grey[600], fontSize: textBodySize)),
                      Text('$age Tahun ($gender)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: textBodySize)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Alamat:', style: TextStyle(color: Colors.grey[600], fontSize: textBodySize)),
                      Expanded(
                        child: Text(
                          address,
                          textAlign: TextAlign.end,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: textBodySize),
                        ),
                      ),
                    ],
                  ),

                  // INTEGRASI BUKTI PEMBAYARAN langsung di profil pasien!
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status Pembayaran:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: textBodySize),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(smallRadius),
                        ),
                        child: Text(
                          'Lunas (${QueueStatus.completed.displayName})',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: textBodySize - 1,
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
                        onPressed: () => _showPaymentProofDialog(),
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
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(cardRadius),
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
                    ...prescriptionItems.map((item) => PrescriptionItemRow(item: item))
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
            ],
        ),
      ),
    ),
  ],
),
);
  }
}
