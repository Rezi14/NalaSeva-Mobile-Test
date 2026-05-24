import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/patient/edit-profile'),
            icon: const Icon(Icons.edit_outlined, color: AppTheme.editColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FadeInDown(
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text(
                user?.name ?? 'Nama Pengguna',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: Text(
                user?.email ?? 'email@example.com',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
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
              delay: const Duration(milliseconds: 200),
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
              delay: const Duration(milliseconds: 400),
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('KELUAR DARI AKUN', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
