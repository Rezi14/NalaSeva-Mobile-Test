import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../logic/admin_provider.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  final MobileScannerController _controller = MobileScannerController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen Mobile Scanner
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) async {
                if (!_isScanning) return;
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() => _isScanning = false);
                  int? queueId;
                  
                  if (code.startsWith('NALASEVA_QUEUE_')) {
                    final queueIdStr = code.replaceFirst('NALASEVA_QUEUE_', '');
                    queueId = int.tryParse(queueIdStr);
                  } else {
                    final provider = context.read<AdminProvider>();
                    try {
                      final matched = provider.queues.firstWhere(
                        (q) => q.queueNumber.trim().toLowerCase() == code.trim().toLowerCase() && q.status == QueueStatus.booked,
                      );
                      queueId = matched.id;
                    } catch (_) {
                      try {
                        final matched = provider.queues.firstWhere(
                          (q) => q.queueNumber.trim().toLowerCase() == code.trim().toLowerCase(),
                        );
                        queueId = matched.id;
                      } catch (_) {}
                    }
                  }
                  
                  if (queueId != null) {
                    await _handleScanResult(queueId);
                  } else {
                    AppDialogs.showNotificationDialog(
                      context,
                      'Tidak Ditemukan',
                      'Antrean "$code" tidak ditemukan untuk tanggal hari ini.',
                      isError: true,
                    );
                    setState(() => _isScanning = true);
                  }
                }
              },
            ),
          ),

          // Custom Premium Glassmorphic Mask & Neon Border Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),

          // Animated Scanner Laser Line
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final cutoutHeight = 260.0;
              final cutoutWidth = 260.0;
              final screenHeight = MediaQuery.of(context).size.height;
              final screenWidth = MediaQuery.of(context).size.width;
              final cutoutLeft = (screenWidth - cutoutWidth) / 2;
              final cutoutTop = (screenHeight - cutoutHeight) / 2;
              
              final currentTop = cutoutTop + (_animation.value * cutoutHeight);
              
              return Positioned(
                top: currentTop,
                left: cutoutLeft + 12,
                right: cutoutLeft + 12,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating Top Control Bar (Glassmorphic)
          Positioned(
            top: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                // Top Center Title
                Text(
                  'Scan Absensi',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // Control Action Buttons
                Row(
                  children: [
                    // Flash Button
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: IconButton(
                            icon: Icon(
                              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                              color: _isTorchOn ? Colors.yellowAccent : Colors.white,
                            ),
                            onPressed: () {
                              _controller.toggleTorch();
                              setState(() {
                                _isTorchOn = !_isTorchOn;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Switch Camera Button
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: IconButton(
                            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                            onPressed: () => _controller.switchCamera(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Guidance & Status text
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    _isScanning 
                        ? 'Arahkan kamera ke QR Code Pasien' 
                        : 'Memproses tiket antrean...',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                if (!_isScanning)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScanResult(int queueId) async {
    final provider = context.read<AdminProvider>();
    await provider.checkInQueue(queueId);
    if (mounted) {
      if (provider.error != null) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal',
          provider.error!,
          isError: true,
        );
        setState(() => _isScanning = true);
      } else {
        AppDialogs.showSuccessDialog(
          context,
          'Berhasil',
          'Berhasil Absensi! Status menjadi MENUNGGU',
          onOkPressed: () {
            Navigator.pop(context);
          },
        );
      }
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final cutoutWidth = 260.0;
    final cutoutHeight = 260.0;
    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2;
    
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight),
      const Radius.circular(24),
    );

    // Subtract cutout area from standard fullscreen fill
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(cutoutRect),
      ),
      paint,
    );

    // Neon glowing corners
    final borderPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 32.0;
    final double radius = 24.0;

    // Top Left Corner
    final topLeftPath = Path()
      ..moveTo(cutoutLeft, cutoutTop + cornerLength)
      ..lineTo(cutoutLeft, cutoutTop + radius)
      ..quadraticBezierTo(cutoutLeft, cutoutTop, cutoutLeft + radius, cutoutTop)
      ..lineTo(cutoutLeft + cornerLength, cutoutTop);
    canvas.drawPath(topLeftPath, borderPaint);

    // Top Right Corner
    final topRightPath = Path()
      ..moveTo(cutoutLeft + cutoutWidth - cornerLength, cutoutTop)
      ..lineTo(cutoutLeft + cutoutWidth - radius, cutoutTop)
      ..quadraticBezierTo(cutoutLeft + cutoutWidth, cutoutTop, cutoutLeft + cutoutWidth, cutoutTop + radius)
      ..lineTo(cutoutLeft + cutoutWidth, cutoutTop + cornerLength);
    canvas.drawPath(topRightPath, borderPaint);

    // Bottom Left Corner
    final bottomLeftPath = Path()
      ..moveTo(cutoutLeft, cutoutTop + cutoutHeight - cornerLength)
      ..lineTo(cutoutLeft, cutoutTop + cutoutHeight - radius)
      ..quadraticBezierTo(cutoutLeft, cutoutTop + cutoutHeight, cutoutLeft + radius, cutoutTop + cutoutHeight)
      ..lineTo(cutoutLeft + cornerLength, cutoutTop + cutoutHeight);
    canvas.drawPath(bottomLeftPath, borderPaint);

    // Bottom Right Corner
    final bottomRightPath = Path()
      ..moveTo(cutoutLeft + cutoutWidth - cornerLength, cutoutTop + cutoutHeight)
      ..lineTo(cutoutLeft + cutoutWidth - radius, cutoutTop + cutoutHeight)
      ..quadraticBezierTo(cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight, cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight - radius)
      ..lineTo(cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight - cornerLength);
    canvas.drawPath(bottomRightPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
