import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_provider.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/queue_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/service_time_validator.dart';
import '../../../core/utils/responsive_helper.dart';

class AdminVoiceCallDialog {
  static void show(BuildContext context, QueueModel queue) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'calling',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: anim1,
            child: Material(
              color: Colors.transparent,
              child: Builder(
                builder: (ctx) {
                  final maxW    = ResponsiveHelper.dialogMaxWidth(ctx);
                  final padding = ResponsiveHelper.paddingDialog(ctx);
                  final radius  = ResponsiveHelper.radiusDialog(ctx);
                  final btnH    = ResponsiveHelper.buttonHeight(ctx);
                  final btnR    = ResponsiveHelper.radiusButton(ctx);
                  final iconSz  = ResponsiveHelper.iconSize(ctx, base: 36);
                  final qNumSz  = ResponsiveHelper.fontSizeHeading(ctx) * 1.8;
                  final fBody   = ResponsiveHelper.fontSizeBody(ctx);
                  final fCap    = ResponsiveHelper.fontSizeCaption(ctx);

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxW,
                      maxHeight: ResponsiveHelper.dialogMaxHeight(ctx),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isLandscape(ctx) ? 24 : 16,
                      ),
                      padding: EdgeInsets.all(padding),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: padding * 0.4),
                            Container(
                              padding: EdgeInsets.all(padding * 0.8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.settings_voice_rounded,
                                size: iconSz,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: padding),
                            Text(
                              'PANGGILAN SUARA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: fCap,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              queue.queueNumber,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: qNumSz,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              queue.patient.fullName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: fBody,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: padding),
                            Text(
                              '🔊 "Memanggil nomor antrean ${queue.queueNumber}, ${queue.patient.fullName}, ke Ruang Pemeriksaan ${queue.polyclinic.name}..."',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: fCap,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: padding * 1.2),
                            SizedBox(
                              width: double.infinity,
                              height: btnH,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final validationError = ServiceTimeValidator.validateAdminAction(queue);
                                  if (validationError != null) {
                                    AppDialogs.showNotificationDialog(
                                      ctx,
                                      'Tidak Sesuai Jam Pelayanan',
                                      validationError,
                                      isError: true,
                                    );
                                    return;
                                  }

                                  if (queue.status != QueueStatus.waiting) {
                                    AppDialogs.showNotificationDialog(
                                      ctx,
                                      'Status Tidak Valid',
                                      'Hanya antrean berstatus MENUNGGU yang dapat dipanggil dari dialog ini.',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  final provider = ctx.read<AdminProvider>();
                                  await provider.updateQueueStatus(queue.id, QueueStatus.examining);
                                  if (!ctx.mounted) return;
                                  if (provider.error != null) {
                                    AppDialogs.showNotificationDialog(
                                      ctx,
                                      'Gagal Memanggil Pasien',
                                      provider.error!,
                                      isError: true,
                                    );
                                    return;
                                  }

                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(btnR),
                                  ),
                                ),
                                child: Text(
                                  'PANGGIL & MASUKKAN',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveHelper.fontSizeButton(ctx),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'Batal',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fBody,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
