import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/models/payment_model.dart';
import '../../logic/pharmacy_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/prescription_item_row.dart';

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
    final absoluteUrl = 'https://nalaseva-api.up.railway.app/storage/$proofPath';

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
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.fontSizeHeading(context),
                  ),
                ),
                SizedBox(height: padding * 0.8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(btnR),
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
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
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
                      style: GoogleFonts.poppins(
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/admin/home');
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Rincian Penyiapan Resep',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Informasi Pasien',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('NIK:', style: GoogleFonts.poppins(color: AppTheme.primaryColor)),
                          Text(nationalId, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Usia:', style: GoogleFonts.poppins(color: AppTheme.primaryColor)),
                          Text('$age Tahun ($gender)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Alamat:', style: GoogleFonts.poppins(color: AppTheme.primaryColor)),
                          Expanded(
                            child: Text(
                              address,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status Pembayaran:',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lunas',
                              style: GoogleFonts.poppins(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                            label: Text(
                              'Verifikasi Bukti QRIS Pasien',
                              style: GoogleFonts.poppins(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _showPaymentProofDialog(widget.payment.paymentProof!),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Text(
                              'Dibayar tunai / lunas via admin loket.',
                              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ],
                        )
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Rincian Resep Obat Dokter',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
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
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white, width: 1),
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
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isProcessing ? null : _dispensePrescription,
                            child: _isProcessing
                                ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                                : Text(
                                    'Serahkan Obat (Selesai)',
                                    style: GoogleFonts.poppins(
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
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            'Hanya Apoteker yang dapat menyerahkan obat',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
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
        ),
      ),
    );
  }
}