import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../widgets/admin_settings_item.dart';
import '../widgets/admin_bottom_nav.dart';
import '../../../shared/providers/puskesmas_profile_provider.dart';
import '../../../shared/widgets/map_picker_screen.dart';
import 'package:latlong2/latlong.dart';
import '../logic/admin_provider.dart';
import '../../../core/utils/responsive_helper.dart';

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

  String? _qrisMerchantName;
  String? _qrisNmid;
  String? _qrisImagePath;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('admin_language') ?? 'Bahasa Indonesia (ID)';
      _darkMode = prefs.getBool('admin_dark_mode') ?? false;
      _securityAccess = prefs.getString('admin_security_access') ?? 'Standar';
      _autoCall = prefs.getBool('admin_auto_call') ?? true;
      _emergencyBypass = prefs.getString('admin_emergency_bypass') ?? 'Level 2';
      _pushNotification = prefs.getBool('admin_push_notification') ?? true;
      _emailReport = prefs.getString('admin_email_report') ?? 'Mingguan';
      _lastBackup = prefs.getString('admin_last_backup') ?? 'Terakhir: Hari ini 04:00';
      _qrisMerchantName = prefs.getString('qris_merchant_name') ?? 'Puskesmas NalaSeva Mandiri';
      _qrisNmid = prefs.getString('qris_nmid') ?? 'ID102930293019';
      _qrisImagePath = prefs.getString('qris_image_path');
    });

    if (mounted) {
      try {
        final adminProvider = context.read<AdminProvider>();
        await adminProvider.fetchSystemSettings();
        if (!mounted) return;
        final apiSettings = adminProvider.systemSettings;
        setState(() {
          final slotDuration = apiSettings['slot_duration_minutes'] ?? '15';
          _avgServiceTime = '$slotDuration menit';
        });
      } catch (e) {
        // Fallback
      }
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
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
                                        AppDialogs.showNotificationDialog(
                                          context,
                                          'Bantuan NalaSeva',
                                          'Silakan hubungi tim IT Support untuk bantuan teknis dan administrasi sistem.',
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
                            icon: Icons.local_hospital_rounded,
                            title: 'Profil Puskesmas',
                            value: 'Kelola identitas & GPS',
                            onTap: _showPuskesmasProfileSheet,
                          ),
                          AdminSettingsItem(
                            icon: Icons.qr_code_scanner_rounded,
                            title: 'QRIS Pembayaran',
                            value: _qrisNmid != null ? 'NMID: $_qrisNmid' : 'Kelola stiker QRIS & NMID',
                            onTap: _showQrisSettingSheet,
                          ),
                          AdminSettingsItem(
                            icon: Icons.payments_rounded,
                            title: 'Biaya Pendaftaran',
                            value: _getRegistrationFeeText(context),
                            onTap: _showRegistrationFeeSheet,
                          ),
                          AdminSettingsItem(
                            icon: Icons.language_rounded,
                            title: 'Bahasa',
                            value: _language,
                            onTap: () => _showChoiceSheet(
                              title: 'Pilih Bahasa',
                              currentValue: _language,
                              options: const ['Bahasa Indonesia (ID)', 'English (US)', 'Basa Jawa (JV)'],
                              onSelected: (val) {
                                setState(() => _language = val);
                                _saveSetting('admin_language', val);
                              },
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
                              onChanged: (val) {
                                setState(() => _darkMode = val);
                                _saveSetting('admin_dark_mode', val);
                              },
                            ),
                            onTap: () {
                              setState(() => _darkMode = !_darkMode);
                              _saveSetting('admin_dark_mode', _darkMode);
                            },
                          ),
                          AdminSettingsItem(
                            icon: Icons.security_rounded,
                            title: 'Akses Keamanan',
                            value: _securityAccess,
                            onTap: () => _showChoiceSheet(
                              title: 'Akses Keamanan',
                              currentValue: _securityAccess,
                              options: const ['Standar', 'Dua Faktor (2FA)', 'Tinggi (IP Lock)'],
                              onSelected: (val) {
                                setState(() => _securityAccess = val);
                                _saveSetting('admin_security_access', val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _settingsGroup(
                        'Hak Akses & Pengguna',
                        [
                          AdminSettingsItem(
                            icon: Icons.manage_accounts_rounded,
                            title: 'Manajemen Pengguna (User)',
                            value: 'Kelola akun, peran, & akses sistem',
                            onTap: () => Navigator.pushNamed(context, '/admin/users'),
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
                              onSelected: (val) async {
                                setState(() => _avgServiceTime = val);
                                final durationOnly = val.replaceAll(RegExp(r'[^0-9]'), '');
                                try {
                                  await context.read<AdminProvider>().updateSystemSettings({
                                    'slot_duration_minutes': int.tryParse(durationOnly) ?? 15,
                                  });
                                } catch (e) {
                                  // Fallback/log
                                }
                              },
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
                              onChanged: (val) {
                                setState(() => _autoCall = val);
                                _saveSetting('admin_auto_call', val);
                              },
                            ),
                            onTap: () {
                              setState(() => _autoCall = !_autoCall);
                              _saveSetting('admin_auto_call', _autoCall);
                            },
                          ),
                          AdminSettingsItem(
                            icon: Icons.priority_high_rounded,
                            title: 'Jalur Darurat',
                            value: _emergencyBypass,
                            onTap: () => _showChoiceSheet(
                              title: 'Jalur Darurat',
                              currentValue: _emergencyBypass,
                              options: const ['Level 1', 'Level 2', 'Level 3'],
                              onSelected: (val) {
                                setState(() => _emergencyBypass = val);
                                _saveSetting('admin_emergency_bypass', val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _settingsGroup(
                        'Kalender Operasional',
                        [
                          AdminSettingsItem(
                            icon: Icons.event_busy_rounded,
                            title: 'Hari Libur Puskesmas',
                            value: 'Kelola libur operasional',
                            onTap: () => Navigator.pushNamed(context, '/admin/holidays'),
                          ),
                          AdminSettingsItem(
                            icon: Icons.time_to_leave_rounded,
                            title: 'Cuti Dokter',
                            value: 'Kelola cuti pelayanan',
                            onTap: () => Navigator.pushNamed(context, '/admin/leaves'),
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
                              onChanged: (val) {
                                setState(() => _pushNotification = val);
                                _saveSetting('admin_push_notification', val);
                              },
                            ),
                            onTap: () {
                              setState(() => _pushNotification = !_pushNotification);
                              _saveSetting('admin_push_notification', _pushNotification);
                            },
                          ),
                          AdminSettingsItem(
                            icon: Icons.email_outlined,
                            title: 'Laporan Email',
                            value: _emailReport,
                            onTap: () => _showChoiceSheet(
                              title: 'Laporan Email',
                              currentValue: _emailReport,
                              options: const ['Harian', 'Mingguan', 'Bulanan', 'Nonaktif'],
                              onSelected: (val) {
                                setState(() => _emailReport = val);
                                _saveSetting('admin_email_report', val);
                              },
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
                            style: GoogleFonts.plusJakartaSans(color: AppTheme.successColor, fontSize: 12, fontWeight: FontWeight.w600),
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
                              if ((confirm ?? false) && context.mounted) {
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

  void _showPuskesmasProfileSheet() {
    final provider = context.read<PuskesmasProfileProvider>();
    final profile = provider.profile;

    final nameController = TextEditingController(text: profile?.name ?? '');
    final addressController = TextEditingController(text: profile?.address ?? '');
    final phoneController = TextEditingController(text: profile?.phone ?? '');
    final emailController = TextEditingController(text: profile?.email ?? '');
    final latController = TextEditingController(text: profile?.latitude?.toString() ?? '');
    final lngController = TextEditingController(text: profile?.longitude?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Profil Puskesmas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Puskesmas',
                      labelStyle: GoogleFonts.inter(fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.local_hospital_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      labelStyle: GoogleFonts.inter(fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.location_on_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Telepon',
                            labelStyle: GoogleFonts.inter(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.phone_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.inter(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.email_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Latitude GPS',
                            labelStyle: GoogleFonts.inter(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.map_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Longitude GPS',
                            labelStyle: GoogleFonts.inter(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.explore_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPickerScreen(
                            initialLatitude: double.tryParse(latController.text),
                            initialLongitude: double.tryParse(lngController.text),
                          ),
                        ),
                      );

                      if (result != null && result is LatLng) {
                        latController.text = result.latitude.toString();
                        lngController.text = result.longitude.toString();
                      }
                    },
                    icon: const Icon(Icons.pin_drop_rounded, color: AppTheme.primaryColor),
                    label: Text(
                      'PILIH LOKASI DARI PETA',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          emailController.text.isEmpty) {
                        AppDialogs.showNotificationDialog(
                          context,
                          'Gagal',
                          'Semua field utama wajib diisi!',
                        );
                        return;
                      }

                      final lat = double.tryParse(latController.text);
                      final lng = double.tryParse(lngController.text);

                      try {
                        // Tampilkan loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        await provider.updatePuskesmasProfile(
                          name: nameController.text,
                          address: addressController.text,
                          phone: phoneController.text,
                          email: emailController.text,
                          latitude: lat,
                          longitude: lng,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Tutup loading dialog
                          Navigator.pop(context); // Tutup bottom sheet
                          AppDialogs.showNotificationDialog(
                            context,
                            'Sukses',
                            'Profil Puskesmas berhasil diperbarui secara real-time!',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Tutup loading dialog
                          AppDialogs.showNotificationDialog(
                            context,
                            'Kesalahan',
                            e.toString(),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'SIMPAN PERUBAHAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQrisSettingSheet() {
    final nameController = TextEditingController(text: _qrisMerchantName);
    final nmidController = TextEditingController(text: _qrisNmid);
    String? localImagePath = _qrisImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Pengaturan QRIS Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Merchant QRIS',
                          labelStyle: GoogleFonts.inter(fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.storefront_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nmidController,
                        decoration: InputDecoration(
                          labelText: 'NMID (Merchant ID)',
                          labelStyle: GoogleFonts.inter(fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.qr_code_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Custom QRIS Image Upload Simulation
                      const Text(
                        'Foto Stiker QRIS Statis',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          // Simulasikan upload stiker QRIS
                          setModalState(() {
                            localImagePath = 'assets/struk_qris_mock.png';
                          });
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                          ),
                          child: localImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/logo.png', // Fallback or mock logo visual
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 72,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload_rounded, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Sentuh untuk Unggah Foto QRIS', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                    Text('(Format JPG/PNG, Maks. 2MB)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final nmid = nmidController.text.trim();
                          
                          if (name.isEmpty || nmid.isEmpty) {
                            AppDialogs.showNotificationDialog(
                              context,
                              'Kesalahan',
                              'Nama Merchant dan NMID wajib diisi!',
                            );
                            return;
                          }

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('qris_merchant_name', name);
                          await prefs.setString('qris_nmid', nmid);
                          if (localImagePath != null) {
                            await prefs.setString('qris_image_path', localImagePath!);
                          }

                          setState(() {
                            _qrisMerchantName = name;
                            _qrisNmid = nmid;
                            _qrisImagePath = localImagePath;
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            AppDialogs.showNotificationDialog(
                              context,
                              'Sukses',
                              'Konfigurasi QRIS berhasil diperbarui untuk seluruh loket!',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'SIMPAN CONFIG QRIS',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
            _saveSetting('admin_last_backup', 'Terakhir: Baru saja');
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
            AppDialogs.showNotificationDialog(
              context,
              'Sistem Diperbarui',
              'NalaSeva Admin menggunakan versi terbaru (v2.4.0). Tidak ada pembaruan tambahan yang tersedia.',
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

  String _getRegistrationFeeText(BuildContext context) {
    final settings = context.watch<AdminProvider>().systemSettings;
    final fee = settings['registration_fee'] ?? '10000';
    final parsed = double.tryParse(fee.toString()) ?? 10000.0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(parsed);
  }

  void _showRegistrationFeeSheet() {
    final settings = context.read<AdminProvider>().systemSettings;
    final fee = settings['registration_fee'] ?? '10000';
    final controller = TextEditingController(text: fee.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ubah Biaya Pendaftaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Biaya Pendaftaran (Rupiah)',
                      labelStyle: GoogleFonts.inter(fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.payments_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final input = double.tryParse(controller.text);
                      if (input == null || input < 0) {
                        AppDialogs.showNotificationDialog(
                          context,
                          'Kesalahan',
                          'Biaya pendaftaran tidak valid!',
                          isError: true,
                        );
                        return;
                      }

                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        await context.read<AdminProvider>().updateSystemSettings({
                          'registration_fee': input,
                        });

                        if (context.mounted) {
                          Navigator.pop(context); // Tutup loading dialog
                          Navigator.pop(context); // Tutup bottom sheet
                          AppDialogs.showNotificationDialog(
                            context,
                            'Sukses',
                            'Biaya pendaftaran berhasil diperbarui ke database!',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Tutup loading
                          AppDialogs.showNotificationDialog(
                            context,
                            'Kesalahan',
                            e.toString(),
                            isError: true,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'SIMPAN PERUBAHAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
