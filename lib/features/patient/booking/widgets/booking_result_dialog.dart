import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';

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
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isLandscape(ctx) ? 48 : 24,
          vertical: ResponsiveHelper.isLandscape(ctx) ? 16 : 40,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.dialogMaxWidth(ctx),
            maxHeight: ResponsiveHelper.dialogMaxHeight(ctx),
          ),
          child: BookingResultDialog(
            isSuccess: isSuccess,
            message: message,
            onFinished: onFinished,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding  = ResponsiveHelper.paddingDialog(context);
    final radius   = ResponsiveHelper.radiusDialog(context);
    final iconSz   = ResponsiveHelper.iconSize(context, base: 52);
    final iconPad  = ResponsiveHelper.paddingCard(context);
    final headSz   = ResponsiveHelper.fontSizeHeading(context);
    final bodySz   = ResponsiveHelper.fontSizeBody(context);
    final btnH     = ResponsiveHelper.buttonHeight(context);
    final btnR     = ResponsiveHelper.radiusButton(context);
    final btnFontSz = ResponsiveHelper.fontSizeButton(context);
    final isLandscape = ResponsiveHelper.isLandscape(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with optional row layout in landscape to save vertical space
              if (isLandscape)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPad * 0.7),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : AppTheme.errorColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                        size: iconSz * 0.85,
                        color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                    SizedBox(width: padding * 0.8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSuccess ? 'Pendaftaran Berhasil' : 'Pendaftaran Gagal',
                            style: GoogleFonts.outfit(
                              fontSize: headSz,
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            message,
                            style: GoogleFonts.poppins(
                              fontSize: bodySz,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                Container(
                  padding: EdgeInsets.all(iconPad),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : AppTheme.errorColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                    size: iconSz,
                    color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                SizedBox(height: padding * 0.8),
                Text(
                  isSuccess ? 'Pendaftaran Berhasil' : 'Pendaftaran Gagal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: headSz,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                SizedBox(height: padding * 0.5),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: bodySz,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],

              SizedBox(height: padding),
              SizedBox(
                width: double.infinity,
                height: btnH,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(btnR),
                    ),
                  ),
                  onPressed: onFinished,
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.poppins(
                      fontSize: btnFontSz,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
