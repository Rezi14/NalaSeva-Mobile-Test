import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

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
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Profil Saya',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Data diri dan informasi akun Anda',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.editColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        if (user?.role == 'admin') {
                                          Navigator.pushNamed(context, '/admin/edit-profile');
                                        } else if (user?.role == 'doctor') {
                                          Navigator.pushNamed(context, '/doctor/edit-profile');
                                        } else if (user?.role == 'pharmacist') {
                                          Navigator.pushNamed(context, '/pharmacy/edit-profile');
                                        } else {
                                          Navigator.pushNamed(context, '/patient/edit-profile');
                                        }
                                      },
                                      icon: const Icon(Icons.edit_outlined, color: AppTheme.editColor),
                                      tooltip: 'Edit Profil',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user?.name != null && user!.name.isNotEmpty
                        ? user.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: Text(
                user?.name ?? 'Nama Pengguna',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 180),
              child: Text(
                user?.email ?? 'email@example.com',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 260),
              child: _buildInfoCard(
                context,
                title: 'Data Diri',
                items: [
                  _infoItem(Icons.phone_outlined, 'Nomor HP', user?.phone ?? '-'),
                  _infoItem(Icons.location_on_outlined, 'Alamat', user?.address ?? '-'),
                  _infoItem(Icons.badge_outlined, 'NIK', user?.nationalId ?? '-'),
                  _infoItem(Icons.person_outline, 'Jenis Kelamin', user?.gender ?? '-'),
                  _infoItem(Icons.cake_outlined, 'Tanggal Lahir', user?.birthDate != null ? DateFormat('dd MMMM yyyy').format(user!.birthDate!) : '-'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 340),
              child: _buildInfoCard(
                context,
                title: 'Akun',
                items: [
                  _infoItem(Icons.security_outlined, 'Role', user?.role.toUpperCase() ?? '-'),
                  _infoItem(Icons.calendar_today_outlined, 'Bergabung Sejak', 'Mei 2024'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 420),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('KELUAR DARI AKUN', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cancelColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),
),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Konfirmasi Keluar',
      'Apakah Anda yakin ingin keluar dari akun Anda?',
      confirmText: 'KELUAR',
      isDestructive: true,
    );

    if ((confirm ?? false) && context.mounted) {
      context.read<AuthProvider>().logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}
