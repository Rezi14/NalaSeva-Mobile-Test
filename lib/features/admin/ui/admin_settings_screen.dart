import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../widgets/admin_settings_item.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/admin/home'),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pengaturan Sistem',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Bantuan NalaSeva'),
                            content: const Text('Silakan hubungi tim IT Support untuk bantuan teknis dan administrasi sistem.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline_rounded, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _settingsGroup(
                    'Konfigurasi Umum',
                    [
                      AdminSettingsItem(
                        icon: Icons.language_rounded,
                        title: 'Bahasa',
                        value: 'Bahasa Indonesia (ID)',
                        onTap: () => _onItemTap(context, 'Language'),
                      ),
                      AdminSettingsItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Mode Gelap',
                        value: 'Nonaktif',
                        onTap: () => _onItemTap(context, 'Dark Mode'),
                      ),
                      AdminSettingsItem(
                        icon: Icons.security_rounded,
                        title: 'Akses Keamanan',
                        value: 'Standar',
                        onTap: () => _onItemTap(context, 'Security Access'),
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
                        value: '15 menit',
                        onTap: () => _onItemTap(context, 'Average Service Time'),
                      ),
                      AdminSettingsItem(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Panggil Pasien Otomatis',
                        value: 'Aktif',
                        onTap: () => _onItemTap(context, 'Auto-call Next Patient'),
                      ),
                      AdminSettingsItem(
                        icon: Icons.priority_high_rounded,
                        title: 'Jalur Darurat',
                        value: 'Level 2',
                        onTap: () => _onItemTap(context, 'Emergency Bypass'),
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
                        value: 'Aktif',
                        onTap: () => _onItemTap(context, 'Push Notifications'),
                      ),
                      AdminSettingsItem(
                        icon: Icons.email_outlined,
                        title: 'Laporan Email',
                        value: 'Mingguan',
                        onTap: () => _onItemTap(context, 'Email Reports'),
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
                        value: 'Terakhir: Hari ini 04:00',
                        onTap: () => _onItemTap(context, 'Database Backup'),
                      ),
                      AdminSettingsItem(
                        icon: Icons.update_rounded,
                        title: 'Periksa Pembaruan',
                        value: 'v2.4.0',
                        onTap: () => _onItemTap(context, 'Check for Updates'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  FadeInUp(
                    child: Column(
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
                              'Apakah Anda yakin ingin keluar dari akun Admin?',
                              confirmText: 'KELUAR',
                              isDestructive: true,
                            );
                            if (confirm == true && context.mounted) {
                              context.read<AuthProvider>().logout();
                              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                            }
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('KELUAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
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

  void _onItemTap(BuildContext context, String title) {
    AppDialogs.showNotificationDialog(
      context,
      'Info',
      'Pengaturan "$title" siap disesuaikan.',
    );
  }
}
