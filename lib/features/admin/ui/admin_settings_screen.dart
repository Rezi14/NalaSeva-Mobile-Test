import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../widgets/admin_settings_item.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // State variables for dynamic settings
  String _language = 'Bahasa Indonesia (ID)';
  bool _darkMode = false;
  String _securityAccess = 'Standar';
  
  String _avgServiceTime = '15 menit';
  bool _autoCall = true;
  String _emergencyBypass = 'Level 2';
  
  bool _pushNotification = true;
  String _emailReport = 'Mingguan';
  
  String _lastBackup = 'Terakhir: Hari ini 04:00';

  @override
  Widget build(BuildContext context) {
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
                  child: AnimationLimiter(
                    child: Column(
                      children: [
                        AnimationConfiguration.staggeredList(
                          position: 0,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pengaturan Sistem',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Kelola parameter dan pemeliharaan platform',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: Text(
                                              'Bantuan NalaSeva',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: Text(
                                              'Silakan hubungi tim IT Support untuk bantuan teknis dan administrasi sistem.',
                                              style: GoogleFonts.plusJakartaSans(fontSize: 14),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: Text(
                                                  'OK',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.help_outline_rounded, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content with premium staggered list animations
          Expanded(
            child: AnimationLimiter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _settingsGroup(
                        'Konfigurasi Umum',
                        [
                          AdminSettingsItem(
                            icon: Icons.language_rounded,
                            title: 'Bahasa',
                            value: _language,
                            onTap: () => _showChoiceSheet(
                              title: 'Pilih Bahasa',
                              currentValue: _language,
                              options: const ['Bahasa Indonesia (ID)', 'English (US)', 'Basa Jawa (JV)'],
                              onSelected: (val) => setState(() => _language = val),
                            ),
                          ),
                          AdminSettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'Mode Gelap',
                            value: _darkMode ? 'Aktif' : 'Nonaktif',
                            trailing: Switch(
                              value: _darkMode,
                              activeThumbColor: AppTheme.primaryColor,
                              activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                              inactiveThumbColor: Colors.grey.shade400,
                              inactiveTrackColor: Colors.grey.shade200,
                              onChanged: (val) => setState(() => _darkMode = val),
                            ),
                            onTap: () => setState(() => _darkMode = !_darkMode),
                          ),
                          AdminSettingsItem(
                            icon: Icons.security_rounded,
                            title: 'Akses Keamanan',
                            value: _securityAccess,
                            onTap: () => _showChoiceSheet(
                              title: 'Akses Keamanan',
                              currentValue: _securityAccess,
                              options: const ['Standar', 'Dua Faktor (2FA)', 'Tinggi (IP Lock)'],
                              onSelected: (val) => setState(() => _securityAccess = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _settingsGroup(
                        'Logika Antrean',
                        [
                          AdminSettingsItem(
                            icon: Icons.timer_outlined,
                            title: 'Rata-rata Waktu Layanan',
                            value: _avgServiceTime,
                            onTap: () => _showChoiceSheet(
                              title: 'Rata-rata Waktu Layanan',
                              currentValue: _avgServiceTime,
                              options: const ['10 menit', '15 menit', '20 menit', '30 menit'],
                              onSelected: (val) => setState(() => _avgServiceTime = val),
                            ),
                          ),
                          AdminSettingsItem(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Panggil Pasien Otomatis',
                            value: _autoCall ? 'Aktif' : 'Nonaktif',
                            trailing: Switch(
                              value: _autoCall,
                              activeThumbColor: AppTheme.primaryColor,
                              activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                              inactiveThumbColor: Colors.grey.shade400,
                              inactiveTrackColor: Colors.grey.shade200,
                              onChanged: (val) => setState(() => _autoCall = val),
                            ),
                            onTap: () => setState(() => _autoCall = !_autoCall),
                          ),
                          AdminSettingsItem(
                            icon: Icons.priority_high_rounded,
                            title: 'Jalur Darurat',
                            value: _emergencyBypass,
                            onTap: () => _showChoiceSheet(
                              title: 'Jalur Darurat',
                              currentValue: _emergencyBypass,
                              options: const ['Level 1', 'Level 2', 'Level 3'],
                              onSelected: (val) => setState(() => _emergencyBypass = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _settingsGroup(
                        'Notifikasi & Peringatan',
                        [
                          AdminSettingsItem(
                            icon: Icons.notifications_active_outlined,
                            title: 'Notifikasi Push',
                            value: _pushNotification ? 'Aktif' : 'Nonaktif',
                            trailing: Switch(
                              value: _pushNotification,
                              activeThumbColor: AppTheme.primaryColor,
                              activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                              inactiveThumbColor: Colors.grey.shade400,
                              inactiveTrackColor: Colors.grey.shade200,
                              onChanged: (val) => setState(() => _pushNotification = val),
                            ),
                            onTap: () => setState(() => _pushNotification = !_pushNotification),
                          ),
                          AdminSettingsItem(
                            icon: Icons.email_outlined,
                            title: 'Laporan Email',
                            value: _emailReport,
                            onTap: () => _showChoiceSheet(
                              title: 'Laporan Email',
                              currentValue: _emailReport,
                              options: const ['Harian', 'Mingguan', 'Bulanan', 'Nonaktif'],
                              onSelected: (val) => setState(() => _emailReport = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _settingsGroup(
                        'Pemeliharaan Sistem',
                        [
                          AdminSettingsItem(
                            icon: Icons.backup_outlined,
                            title: 'Pencadangan Database',
                            value: _lastBackup,
                            onTap: _startDatabaseBackup,
                          ),
                          AdminSettingsItem(
                            icon: Icons.update_rounded,
                            title: 'Periksa Pembaruan',
                            value: 'v2.4.0',
                            onTap: _checkSystemUpdates,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Footer and Logout button
                      Column(
                        children: [
                          Text(
                            'NalaSeva Admin v2.4.0',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status Sistem: Sehat',
                            style: GoogleFonts.plusJakartaSans(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 24),
                           ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await AppDialogs.showConfirmationDialog(
                                context,
                                'Konfirmasi Keluar',
                                'Apakah Anda yakin ingin keluar dari akun Admin Anda?',
                                confirmText: 'KELUAR',
                                isDestructive: true,
                              );
                              if (confirm == true && context.mounted) {
                                context.read<AuthProvider>().logout();
                                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                              }
                            },
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('KELUAR DARI AKUN', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cancelColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Navigation
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: const AdminBottomNav(activeIndex: 4),
          ),
        ],
      ),
    );
  }

  Widget _settingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  void _showChoiceSheet({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: options.map((option) {
                    final isSelected = option == currentValue;
                    return ChoiceChip(
                      label: Text(
                        option,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: Colors.grey.shade100,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          onSelected(option);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startDatabaseBackup() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // Simulate backup progression
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (!mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            setState(() {
              _lastBackup = 'Terakhir: Baru saja';
            });
            AppDialogs.showNotificationDialog(
              context,
              'Sukses',
              'Database sistem NalaSeva berhasil dicadangkan dengan aman!',
            );
          }
        });

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mencadangkan Database...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem sedang mengompresi dan mengenkripsi data rekam medis...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkSystemUpdates() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // Simulate progress bar loading
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (dialogCtx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  'Sistem Diperbarui',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'NalaSeva Admin menggunakan versi terbaru (v2.4.0). Tidak ada pembaruan tambahan yang tersedia.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text(
                      'OK',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const LinearProgressIndicator(
                  backgroundColor: Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                Text(
                  'Memeriksa Pembaruan Sistem...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Menghubungkan ke server repositori pusat NalaSeva...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
