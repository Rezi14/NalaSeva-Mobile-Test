import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppDialogs {
  static void showNotificationDialog(BuildContext context, String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppTheme.errorColor : AppTheme.successColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isError ? AppTheme.errorColor : AppTheme.successColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
  static Future<void> showSuccessDialog(
    BuildContext context, 
    String title, 
    String message, {
    VoidCallback? onOkPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.successColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context, 
    String title, 
    String message, {
    String confirmText = 'YA',
    String cancelText = 'BATAL',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    cancelText == 'BATAL' ? 'Batal' : cancelText,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(
                    confirmText == 'YA, DAFTAR' ? 'Daftar' :
                    confirmText == 'YA, SIMPAN' ? 'Simpan' :
                    confirmText == 'YA, UPDATE' ? 'Update' :
                    confirmText == 'YA, BATALKAN' ? 'Batalkan' :
                    confirmText == 'YA, HAPUS' || confirmText == 'HAPUS' ? 'Hapus' :
                    confirmText,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
