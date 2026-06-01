import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BookingResultDialog extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback onFinished;

  const BookingResultDialog({
    super.key,
    required this.isSuccess,
    required this.message,
    required this.onFinished,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isSuccess,
    required String message,
    required VoidCallback onFinished,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: BookingResultDialog(
            isSuccess: isSuccess,
            message: message,
            onFinished: onFinished,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSuccess ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.errorColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              size: 64,
              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSuccess ? 'Pendaftaran Berhasil' : 'Pendaftaran Gagal',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onFinished,
              child: Text(
                'Selesai',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
