import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../widgets/doctor_info_row.dart';
import '../widgets/doctor_profile_info_card.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final initials = (user?.name ?? '').isNotEmpty
      ? user!.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
      : 'DR';

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(
          children: [
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
                                        color: Colors.white,
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
                                            'Data profesi dan lisensi medis Anda',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () => Navigator.pushNamed(context, '/doctor/edit-profile'),
                                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
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
                    initials,
                    style: GoogleFonts.poppins(
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
                user?.name ?? 'Nama Dokter',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: Text(
                user?.email ?? 'doctor@nalaseva.com',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (user?.specialization != null && user!.specialization!.isNotEmpty)
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.specialization!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            
            // Personal Information Card
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 300),
              child: DoctorProfileInfoCard(
                title: 'Data Diri Dokter',
                items: [
                  DoctorInfoRow(icon: Icons.badge_outlined, label: 'NIK (Nomor Induk Kependudukan)', value: user?.nationalId ?? '-'),
                  DoctorInfoRow(icon: Icons.phone_android_outlined, label: 'Nomor WhatsApp', value: user?.phone ?? '-'),
                  DoctorInfoRow(icon: Icons.location_on_outlined, label: 'Alamat Praktek / Rumah', value: user?.address ?? '-'),
                  DoctorInfoRow(icon: Icons.wc_outlined, label: 'Jenis Kelamin', value: user?.gender ?? '-'),
                  DoctorInfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Tanggal Lahir',
                    value: user?.birthDate != null 
                        ? DateFormat('dd MMMM yyyy', 'id_ID').format(user!.birthDate!) 
                        : '-',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Account Information Card
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 400),
              child: DoctorProfileInfoCard(
                title: 'Informasi Akun & Profesi',
                items: [
                  DoctorInfoRow(icon: Icons.local_hospital_outlined, label: 'Spesialisasi', value: user?.specialization ?? '-'),
                  DoctorInfoRow(icon: Icons.badge_outlined, label: 'Nomor SIP / Lisensi', value: user?.licenseNumber ?? '-'),
                  DoctorInfoRow(icon: Icons.security_outlined, label: 'Hak Akses Portal', value: user?.role.toUpperCase() ?? 'DOKTER'),
                  DoctorInfoRow(icon: Icons.check_circle_outline_rounded, label: 'Status Keaktifan', value: 'Aktif Praktek'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Logout Button
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 500),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: Text('Keluar dari Akun', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cancelColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



  void _showLogoutConfirmation(BuildContext context) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Konfirmasi Keluar',
      'Apakah Anda yakin ingin keluar dari akun Dokter Anda?',
      confirmText: 'Keluar',
      isDestructive: true,
    );

    if ((confirm ?? false) && context.mounted) {
      context.read<AuthProvider>().logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}
