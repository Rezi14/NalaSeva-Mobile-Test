import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
            // ── Header gradient hijau (pendek, seperti edit profil) ──
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profil Saya',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Data diri dan informasi akun Anda',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Tombol edit
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              final role = user?.role ?? '';
                              if (role == 'admin') {
                                Navigator.pushNamed(context, '/admin/edit-profile');
                              } else if (role == 'pharmacist') {
                                Navigator.pushNamed(context, '/pharmacy/edit-profile');
                              } else {
                                Navigator.pushNamed(context, '/patient/edit-profile');
                              }
                            },
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Konten scrollable (putih) ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  children: [
                    // Avatar + Nama + Email + Badge
                    FadeInUp(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 80),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.12),
                            child: CircleAvatar(
                              radius: 41,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                user?.name != null && user!.name.isNotEmpty
                                    ? user.name
                                        .split(' ')
                                        .where((e) => e.isNotEmpty)
                                        .map((e) => e[0])
                                        .take(2)
                                        .join()
                                        .toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.name ?? 'Nama Pasien',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'email@example.com',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Card Data Diri Pasien
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 180),
                      child: _buildInfoCard(
                        title: 'Data Diri Pasien',
                        rows: [
                          _CardRow(
                            icon: Icons.badge_outlined,
                            label: 'NIK (Nomor Induk Kependudukan)',
                            value: user?.nationalId ?? '-',
                          ),
                          _CardRow(
                            icon: Icons.phone_android_outlined,
                            label: 'Nomor WhatsApp/HP',
                            value: user?.phone ?? '-',
                          ),
                          _CardRow(
                            icon: Icons.location_on_outlined,
                            label: 'Alamat Provinsi / Rumah',
                            value: user?.address ?? '-',
                          ),
                          _CardRow(
                            icon: Icons.person_outline,
                            label: 'Jenis Kelamin',
                            value: user?.gender ?? '-',
                          ),
                          _CardRow(
                            icon: Icons.cake_outlined,
                            label: 'Tanggal Lahir',
                            value: user?.birthDate != null
                                ? DateFormat('dd MMMM yyyy', 'id_ID')
                                    .format(user!.birthDate!)
                                : '-',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card Akun
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 260),
                      child: _buildInfoCard(
                        title: 'Akun',
                        rows: [
                          _CardRow(
                            icon: Icons.security_outlined,
                            label: 'Role',
                            value: user?.role.toUpperCase() ?? '-',
                          ),
                          _CardRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Bergabung Sejak',
                            value: 'Mei 2024',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol logout
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 340),
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutConfirmation(context),
                        icon: const Icon(Icons.logout_rounded,
                            color: Colors.white),
                        label: Text(
                          'KELUAR DARI AKUN',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cancelColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity,
                              ResponsiveHelper.buttonHeight(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.radiusButton(context)),
                          ),
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

  Widget _buildInfoCard({
    required String title,
    required List<_CardRow> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF87),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            final row = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(row.icon, size: 18, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text(
                      row.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    row.value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
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

class _CardRow {
  final IconData icon;
  final String label;
  final String value;
  const _CardRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}
