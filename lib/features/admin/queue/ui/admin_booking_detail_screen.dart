import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../logic/admin_provider.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/service_time_validator.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../shared/widgets/admin_info_row.dart';
import '../widgets/admin_booking_action_buttons.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final QueueModel queue;
  const AdminBookingDetailScreen({super.key, required this.queue});

  @override
  State<AdminBookingDetailScreen> createState() => _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  late QueueModel _currentQueue;

  @override
  void initState() {
    super.initState();
    _currentQueue = widget.queue;
  }

  void _onSuccessMessage(String msg) {
    AppDialogs.showNotificationDialog(
      context,
      'Berhasil',
      msg,
    );
  }

  void _onErrorMessage(String msg) {
    AppDialogs.showNotificationDialog(
      context,
      'Gagal',
      msg,
      isError: true,
    );
  }

  Future<String?> _showManualCheckInReasonDialog() async {
    String? selectedReason = 'Pasien tidak membawa smartphone / Lansia';
    final reasons = [
      'Pasien tidak membawa smartphone / Lansia',
      'Kamera scanner / QR Code bermasalah',
      'HP Pasien mati / Habis baterai',
      'Kondisi darurat medis',
      'Alasan lainnya'
    ];

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final maxW   = ResponsiveHelper.dialogMaxWidth(context);
        final radius = ResponsiveHelper.radiusDialog(context);
        final btnR   = ResponsiveHelper.radiusButton(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              constraints: BoxConstraints(maxWidth: maxW),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_ind_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Konfirmasi Absen Manual',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anda sedang melakukan absensi secara manual. Harap pilih alasan utama untuk pelaporan sistem:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(btnR),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReason,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        items: reasons.map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              selectedReason = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedReason),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(btnR),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(
                    'Konfirmasi Absen',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _checkInPatient() async {
    final validationError = ServiceTimeValidator.validateAdminAction(_currentQueue);
    if (validationError != null) {
      _onErrorMessage(validationError);
      return;
    }
    
    if (_currentQueue.status != QueueStatus.booked) {
      _onErrorMessage('Hanya antrean berstatus DIPESAN yang dapat diabsenkan.');
      return;
    }
    
    final reason = await _showManualCheckInReasonDialog();
    if (reason == null || !mounted) return; // Cancel check-in or if unmounted
    
    final provider = context.read<AdminProvider>();
    await provider.checkInQueue(_currentQueue.id, reason: reason);
    if (mounted) {
      if (provider.error != null) {
        _onErrorMessage(provider.error!);
      } else {
        _onSuccessMessage('Berhasil mengubah status menjadi MENUNGGU (Absen)\nAlasan: $reason');
        setState(() {
          final matchingQueues = provider.queues.where((q) => q.id == _currentQueue.id);
          if (matchingQueues.isNotEmpty) {
            _currentQueue = matchingQueues.first;
          } else {
            _currentQueue = _currentQueue.copyWith(status: QueueStatus.waiting);
          }
        });
      }
    }
  }

  Future<void> _moveQueueToBack() async {
    if (_currentQueue.status != QueueStatus.booked) {
      _onErrorMessage('Hanya antrean berstatus DIPESAN yang dapat dipindahkan ke belakang.');
      return;
    }
    
    final provider = context.read<AdminProvider>();
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Pindahkan ke Belakang',
      'Pasien belum check-in/absen. Apakah Anda yakin ingin memindahkan antrean ini ke posisi paling belakang?',
      confirmText: 'Pindahkan',
      cancelText: 'Batal',
    );

    if (confirm ?? false) {
      await provider.moveQueueToBack(_currentQueue);
      if (mounted) {
        if (provider.error != null) {
          _onErrorMessage(provider.error!);
        } else {
          final matchingQueues = provider.queues.where((q) => q.id == _currentQueue.id);
          setState(() {
            if (matchingQueues.isNotEmpty) {
              _currentQueue = matchingQueues.first;
            }
          });
        }
      }
    }
  }

  Future<void> _cancelQueue() async {
    if (_currentQueue.status.isTerminal) {
      _onErrorMessage('Antrean yang sudah selesai atau dibatalkan tidak dapat dibatalkan lagi.');
      return;
    }
    
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Batalkan Antrean',
      'Apakah Anda yakin ingin membatalkan antrean ini?',
      confirmText: 'Batalkan',
      cancelText: 'Tutup',
      isDestructive: true,
    );

    if ((confirm ?? false) && mounted) {
      final provider = context.read<AdminProvider>();
      await provider.updateQueueStatus(_currentQueue.id, QueueStatus.cancelled);
      if (mounted) {
        if (provider.error != null) {
          _onErrorMessage(provider.error!);
        } else {
          _onSuccessMessage('Antrean berhasil dibatalkan');
          setState(() {
            final matchingQueues = provider.queues.where((q) => q.id == _currentQueue.id);
            if (matchingQueues.isNotEmpty) {
              _currentQueue = matchingQueues.first;
            } else {
              _currentQueue = _currentQueue.copyWith(status: QueueStatus.cancelled);
            }
          });
        }
      }
    }
  }

  void _voiceCallingSimulation({bool isRecall = false}) {
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
                  final iconSz  = ResponsiveHelper.iconSize(ctx, base: 40);
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
                              isRecall ? 'PANGGILAN ULANG' : 'PANGGILAN SUARA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: fCap,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: padding * 0.3),
                            Text(
                              _currentQueue.queueNumber,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: qNumSz,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: padding * 0.2),
                            Text(
                              _currentQueue.patient.fullName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: fBody,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: padding),
                            Text(
                              isRecall
                                  ? '🔊 "Panggilan ulang untuk nomor antrean ${_currentQueue.queueNumber}, ${_currentQueue.patient.fullName}, ke Ruang Pemeriksaan ${_currentQueue.polyclinic.name}..."'
                                  : '🔊 "Memanggil nomor antrean ${_currentQueue.queueNumber}, ${_currentQueue.patient.fullName}, ke Ruang Pemeriksaan ${_currentQueue.polyclinic.name}..."',
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
                                  if (isRecall) {
                                    Navigator.pop(ctx);
                                    return;
                                  }
                                  final provider = ctx.read<AdminProvider>();
                                  final navigator = Navigator.of(ctx);
                                  await provider.updateQueueStatus(_currentQueue.id, QueueStatus.examining);
                                  if (mounted) {
                                    if (provider.error != null) {
                                      _onErrorMessage(provider.error!);
                                    } else {
                                      navigator.pop();
                                      _onSuccessMessage('Pasien dipanggil dan dimasukkan ke ruang periksa');
                                      setState(() {
                                        final matchingQueues = provider.queues.where((q) => q.id == _currentQueue.id);
                                        if (matchingQueues.isNotEmpty) {
                                          _currentQueue = matchingQueues.first;
                                        } else {
                                          _currentQueue = _currentQueue.copyWith(status: QueueStatus.examining);
                                        }
                                      });
                                    }
                                  }
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
                                  isRecall ? 'TUTUP' : 'PANGGIL & MASUKKAN',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveHelper.fontSizeButton(ctx),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: padding * 0.3),
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

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;
    final statusLabel = _currentQueue.status.displayName.toUpperCase();

    switch (_currentQueue.status) {
      case QueueStatus.booked:
        badgeColor = AppTheme.warningColor.withValues(alpha: 0.1);
        textColor = AppTheme.warningColor;
        break;
      case QueueStatus.waiting:
        badgeColor = AppTheme.accentColor.withValues(alpha: 0.1);
        textColor = AppTheme.accentColor;
        break;
      case QueueStatus.examining:
        badgeColor = AppTheme.secondaryColor.withValues(alpha: 0.1);
        textColor = AppTheme.secondaryColor;
        break;
      case QueueStatus.completed:
        badgeColor = AppTheme.successColor.withValues(alpha: 0.1);
        textColor = AppTheme.successColor;
        break;
      case QueueStatus.cancelled:
        badgeColor = AppTheme.cancelColor.withValues(alpha: 0.1);
        textColor = AppTheme.cancelColor;
        break;
      case QueueStatus.unknown:
        badgeColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
    }

    final p = _currentQueue.patient;
    final initials = p.fullName.isNotEmpty
        ? p.fullName.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
        : 'PS';

    final ageStr = p.birthDate != null
        ? '${DateTime.now().year - p.birthDate!.year} Tahun'
        : 'Tidak Diisi';

    final dobStr = p.birthDate != null
        ? DateFormat('dd MMMM yyyy').format(p.birthDate!)
        : 'Tidak Diisi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Detail Antrean Pasien',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.fullName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NIK: ${p.nationalId ?? "Belum diisi"}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  AdminInfoRow(icon: Icons.face_rounded, label: 'Jenis Kelamin', value: p.gender ?? 'Tidak Diisi'),
                  const SizedBox(height: 12),
                  AdminInfoRow(icon: Icons.cake_rounded, label: 'Tanggal Lahir', value: '$dobStr ($ageStr)'),
                  const SizedBox(height: 12),
                  AdminInfoRow(icon: Icons.phone_android_rounded, label: 'No. Telepon', value: p.phone ?? 'Tidak Diisi'),
                  const SizedBox(height: 12),
                  AdminInfoRow(icon: Icons.home_rounded, label: 'Alamat', value: p.address ?? 'Tidak Diisi'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Booking Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Informasi Kunjungan',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.plusJakartaSans(
                            color: textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nomor Antrean', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _currentQueue.queueNumber,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Poli Tujuan', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _currentQueue.polyclinic.name,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AdminInfoRow(icon: Icons.calendar_month_rounded, label: 'Tanggal Kunjungan', value: _currentQueue.date),
                ],
              ),
            ),
            const SizedBox(height: 32),

            AdminBookingActionButtons(
              queue: _currentQueue,
              onCheckIn: _checkInPatient,
              onMoveToBack: _moveQueueToBack,
              onCancel: _cancelQueue,
              onCallPatient: () {
                final validationError = ServiceTimeValidator.validateAdminAction(_currentQueue);
                if (validationError != null) {
                  _onErrorMessage(validationError);
                  return;
                }
                if (_currentQueue.status != QueueStatus.waiting) {
                  _onErrorMessage('Hanya antrean berstatus MENUNGGU yang dapat dipanggil.');
                  return;
                }
                final cleanQueueNum = _currentQueue.queueNumber.replaceAll('-', ' ');
                final text = "Panggilan untuk nomor antrean $cleanQueueNum, atas nama ${_currentQueue.patient.fullName}, silahkan menuju ke ruang ${_currentQueue.polyclinic.name}.";
                TtsHelper.speak(text);
                _voiceCallingSimulation(isRecall: false);
              },
              onRecallPatient: () async {
                final validationError = ServiceTimeValidator.validateAdminAction(_currentQueue);
                if (validationError != null) {
                  _onErrorMessage(validationError);
                  return;
                }
                if (_currentQueue.status != QueueStatus.examining) {
                  _onErrorMessage('Hanya antrean berstatus SEDANG DIPERIKSA yang dapat dipanggil ulang.');
                  return;
                }
                final currentCount = _currentQueue.recallCount;
                if (currentCount >= 3) {
                  _onErrorMessage('Batas maksimal panggilan ulang (3 kali) untuk pasien ini telah tercapai.');
                  return;
                }
                
                final provider = context.read<AdminProvider>();
                await provider.recallQueue(_currentQueue.id);
                
                if (mounted) {
                  if (provider.error != null) {
                    _onErrorMessage(provider.error!);
                    return;
                  }
                  
                  setState(() {
                    final matchingQueues = provider.queues.where((q) => q.id == _currentQueue.id);
                    if (matchingQueues.isNotEmpty) {
                      _currentQueue = matchingQueues.first;
                    }
                  });

                  final cleanQueueNum = _currentQueue.queueNumber.replaceAll('-', ' ');
                  final text = "Panggilan ulang untuk nomor antrean $cleanQueueNum, atas nama ${_currentQueue.patient.fullName}, silahkan menuju ke ruang ${_currentQueue.polyclinic.name}. (Panggilan ke-${_currentQueue.recallCount})";
                  TtsHelper.speak(text);
                  _voiceCallingSimulation(isRecall: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

}
