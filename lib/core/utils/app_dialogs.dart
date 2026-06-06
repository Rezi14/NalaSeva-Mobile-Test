import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'responsive_helper.dart';

class AppDialogs {
  // ─── Notification / Error Dialog ─────────────────────────────────────────
  static void showNotificationDialog(
    BuildContext context,
    String title,
    String message, {
    bool isError = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => _buildNotificationDialog(ctx, title, message, isError: isError),
    );
  }

  static Widget _buildNotificationDialog(
    BuildContext ctx,
    String title,
    String message, {
    bool isError = false,
  }) {
    final headingSize = ResponsiveHelper.fontSizeHeading(ctx);
    final bodySize    = ResponsiveHelper.fontSizeBody(ctx);
    final btnHeight   = ResponsiveHelper.buttonHeightCompact(ctx);
    final radius      = ResponsiveHelper.radiusDialog(ctx);
    final btnRadius   = ResponsiveHelper.radiusButton(ctx);
    final padding     = ResponsiveHelper.paddingDialog(ctx);
    final maxWidth    = ResponsiveHelper.dialogMaxWidth(ctx);
    final maxHeight   = ResponsiveHelper.dialogMaxHeight(ctx);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.check_circle_outline,
                      color: isError ? AppTheme.errorColor : AppTheme.successColor,
                      size: ResponsiveHelper.iconSize(ctx, base: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: headingSize,
                          color: isError ? AppTheme.errorColor : AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding * 0.6),
                // Content
                Text(
                  message,
                  style: GoogleFonts.inter(fontSize: bodySize, color: Colors.black87, height: 1.5),
                ),
                SizedBox(height: padding),
                // Action button
                SizedBox(
                  width: double.infinity,
                  height: btnHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(btnRadius),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.fontSizeButton(ctx),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Success Dialog ───────────────────────────────────────────────────────
  static Future<void> showSuccessDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onOkPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final headingSize = ResponsiveHelper.fontSizeHeading(ctx);
        final bodySize    = ResponsiveHelper.fontSizeBody(ctx);
        final btnHeight   = ResponsiveHelper.buttonHeightCompact(ctx);
        final radius      = ResponsiveHelper.radiusDialog(ctx);
        final btnRadius   = ResponsiveHelper.radiusButton(ctx);
        final padding     = ResponsiveHelper.paddingDialog(ctx);
        final maxWidth    = ResponsiveHelper.dialogMaxWidth(ctx);
        final maxHeight   = ResponsiveHelper.dialogMaxHeight(ctx);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.successColor,
                          size: ResponsiveHelper.iconSize(ctx, base: 22),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: headingSize,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: padding * 0.6),
                    Text(
                      message,
                      style: GoogleFonts.inter(fontSize: bodySize, color: Colors.black87, height: 1.5),
                    ),
                    SizedBox(height: padding),
                    SizedBox(
                      width: double.infinity,
                      height: btnHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onOkPressed?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(btnRadius),
                          ),
                        ),
                        child: Text(
                          'OK',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.fontSizeButton(ctx),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Confirmation Dialog ──────────────────────────────────────────────────
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'YA',
    String cancelText  = 'BATAL',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final headingSize = ResponsiveHelper.fontSizeHeading(ctx);
        final bodySize    = ResponsiveHelper.fontSizeBody(ctx);
        final btnHeight   = ResponsiveHelper.buttonHeightCompact(ctx);
        final radius      = ResponsiveHelper.radiusDialog(ctx);
        final btnRadius   = ResponsiveHelper.radiusButton(ctx);
        final padding     = ResponsiveHelper.paddingDialog(ctx);
        final maxWidth    = ResponsiveHelper.dialogMaxWidth(ctx);
        final maxHeight   = ResponsiveHelper.dialogMaxHeight(ctx);

        // Normalize confirm label
        final resolvedConfirm = _resolveLabel(confirmText);
        final resolvedCancel  = cancelText == 'BATAL' ? 'Batal' : cancelText;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: headingSize,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: padding * 0.6),
                    Text(
                      message,
                      style: GoogleFonts.inter(fontSize: bodySize, color: Colors.black87, height: 1.5),
                    ),
                    SizedBox(height: padding),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: btnHeight,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(btnRadius),
                                ),
                              ),
                              child: Text(
                                resolvedCancel,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveHelper.fontSizeButton(ctx),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: btnHeight,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDestructive
                                    ? AppTheme.errorColor
                                    : AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(btnRadius),
                                ),
                              ),
                              child: Text(
                                resolvedConfirm,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveHelper.fontSizeButton(ctx),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  static String _resolveLabel(String raw) {
    const map = {
      'YA, DAFTAR'   : 'Daftar',
      'YA, SIMPAN'   : 'Simpan',
      'YA, UPDATE'   : 'Update',
      'YA, BATALKAN' : 'Batalkan',
      'YA, HAPUS'    : 'Hapus',
      'HAPUS'        : 'Hapus',
      'YA'           : 'Ya',
    };
    return map[raw] ?? raw;
  }
}
