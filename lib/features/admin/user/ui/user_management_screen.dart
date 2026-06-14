import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../logic/admin_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/responsive_helper.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red.shade600;
      case 'doctor':
        return AppTheme.primaryColor;
      case 'pharmacist':
        return Colors.teal.shade600;
      case 'patient':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'doctor':
        return 'Dokter';
      case 'pharmacist':
        return 'Apoteker';
      case 'patient':
        return 'Pasien';
      default:
        return role.toUpperCase();
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'doctor':
        return Icons.medical_services_rounded;
      case 'pharmacist':
        return Icons.local_pharmacy_rounded;
      case 'patient':
        return Icons.person_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _filterChip({required String label, required String? role}) {
    final isSelected = _selectedRoleFilter == role;
    return GestureDetector(
      onTap: () => setState(
          () => _selectedRoleFilter = isSelected ? null : role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: ResponsiveCenter(
          maxWidth: 950,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: () => _showUserForm(context),
              backgroundColor: AppTheme.primaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
              label: const Text(
                'Tambah Baru',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        body: Consumer<AdminProvider>(
          builder: (context, provider, child) {
            final filteredUsers = provider.users.where((user) {
              final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  user.email.toLowerCase().contains(_searchQuery.toLowerCase());
              
              final matchesRole = _selectedRoleFilter == null || user.role.toLowerCase() == _selectedRoleFilter;
              
              return matchesSearch && matchesRole;
            }).toList();

            return ResponsiveCenter(
              maxWidth: 950,
              child: Column(
                children: [
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.backgroundGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: AnimationLimiter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimationConfiguration.staggeredList(
                                position: 0,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 30.0,
                                  child: FadeInAnimation(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              } else {
                                                Navigator.pushReplacementNamed(context, '/admin/home');
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.arrow_back_ios_new_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Manajemen Pengguna',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Kelola akun, hak akses & profil pengguna sistem',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.white.withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Search 
                              AnimationConfiguration.staggeredList(
                                position: 1,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 30.0,
                                  child: FadeInAnimation(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            onChanged: (val) => setState(() => _searchQuery = val),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Cari nama atau email...',
                                              hintStyle: GoogleFonts.poppins(
                                                color: Colors.grey.shade400,
                                                fontSize: 14,
                                              ),
                                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                                              suffixIcon: _searchQuery.isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(Icons.clear_rounded, size: 20, color: Colors.grey),
                                                      onPressed: () {
                                                        _searchController.clear();
                                                        setState(() => _searchQuery = '');
                                                      },
                                                    )
                                                  : null,
                                              filled: true,
                                              fillColor: Colors.white.withValues(alpha: 0.9),
                                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Filter 
                              AnimationConfiguration.staggeredList(
                                position: 2,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 30.0,
                                  child: FadeInAnimation(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          _filterChip(label: 'Semua', role: null),
                                          const SizedBox(width: 8),
                                          _filterChip(label: 'Admin', role: 'admin'),
                                          const SizedBox(width: 8),
                                          _filterChip(label: 'Dokter', role: 'doctor'),
                                          const SizedBox(width: 8),
                                          _filterChip(label: 'Apoteker', role: 'pharmacist'),
                                          const SizedBox(width: 8),
                                          _filterChip(label: 'Pasien', role: 'patient'),
                                        ],
                                      ),
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
                  child: RefreshIndicator(
                    onRefresh: provider.fetchUsers,
                    child: Builder(
                      builder: (context) {
                        if (provider.isLoading && provider.users.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (provider.error != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.error!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => provider.fetchUsers(),
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (filteredUsers.isEmpty) {
                          final isFiltering = _selectedRoleFilter != null || _searchQuery.isNotEmpty;
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                              decoration: BoxDecoration(
                                gradient: AppTheme.backgroundGradient,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade50,
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFiltering ? Icons.search_off_rounded : Icons.people_outline_rounded,
                                      size: 64,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    isFiltering ? 'Hasil Tidak Ditemukan' : 'Tidak Ada Pengguna',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isFiltering
                                        ? 'Tidak ada data akun pengguna yang cocok dengan pencarian atau filter aktif Anda. Silakan coba atur ulang pencarian.'
                                        : 'Belum ada data akun pengguna yang terdaftar di dalam sistem saat ini.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isFiltering) ...[
                                    const SizedBox(height: 24),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                          _selectedRoleFilter = null;
                                        });
                                      },
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      label: Text(
                                        'Reset Pencarian & Filter',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.primaryColor,
                                        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }

                        return AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final roleColor = _getRoleColor(user.role);
                              final isSelf = user.id == currentUserId;

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 450),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.backgroundGradient,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: 
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              _getRoleIcon(user.role),
                                              color: roleColor,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        user.name,
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isSelf)
                                                      Transform.translate(
                                                        offset: const Offset(40, 0),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 10,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            'Anda',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 9,
                                                              fontWeight: FontWeight.w900,
                                                              color: AppTheme.primaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                
                                                Text(
                                                  user.email,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    _getRoleDisplayName(user.role),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                                                onPressed: () => _showUserForm(context, user: user),
                                                constraints: const BoxConstraints(),
                                                padding: const EdgeInsets.all(8),
                                              ),
                                              if (!isSelf)
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                                                  onPressed: () => _confirmDeleteUser(context, user),
                                                  constraints: const BoxConstraints(),
                                                  padding: const EdgeInsets.all(8),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserModel user) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Hapus Akun Pengguna',
      'Apakah Anda yakin ingin menghapus akun ${user.name}? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirm ?? false) {
      if (!context.mounted) return;
      final provider = context.read<AdminProvider>();
      await provider.deleteUser(user.id);
      
      if (!context.mounted) return;
      AppDialogs.showSuccessDialog(
        context,
        'Berhasil Dihapus',
        'Akun pengguna ${user.name} telah berhasil dihapus dari sistem.',
      );
    }
  }

  void _showUserForm(BuildContext context, {UserModel? user}) {
    final isEdit = user != null;
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final passwordController = TextEditingController();
    final phoneController = TextEditingController(text: user?.phone);
    final addressController = TextEditingController(text: user?.address);
    String selectedRole = user?.role.toLowerCase() ?? 'patient';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEdit ? 'Edit Akun Pengguna' : 'Tambah Pengguna Baru',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Alamat Email',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                if (!isEdit) ...[
                  TextFormField(
                    controller: passwordController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      labelStyle: GoogleFonts.poppins(fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 8 ? 'Password minimal 8 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: phoneController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nomor HP (Opsional)',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v != null && v.isNotEmpty && v.length < 9 ? 'Minimal 9 digit' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Alamat Lengkap (Opsional)',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Peran (Role)',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'doctor', child: Text('Dokter')),
                    DropdownMenuItem(value: 'pharmacist', child: Text('Apoteker')),
                    DropdownMenuItem(value: 'patient', child: Text('Pasien')),
                  ],
                  onChanged: (v) => selectedRole = v!,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final hasChanges = isEdit
                              ? (nameController.text.trim() != user.name ||
                                  emailController.text.trim() != user.email ||
                                  phoneController.text.trim() != (user.phone ?? '') ||
                                  addressController.text.trim() != (user.address ?? '') ||
                                  selectedRole != user.role.toLowerCase())
                              : (nameController.text.trim().isNotEmpty ||
                                  emailController.text.trim().isNotEmpty ||
                                  passwordController.text.isNotEmpty ||
                                  phoneController.text.trim().isNotEmpty ||
                                  addressController.text.trim().isNotEmpty);

                          if (hasChanges) {
                            final confirm = await AppDialogs.showConfirmationDialog(
                              context,
                              isEdit ? 'Batalkan Perubahan?' : 'Batalkan Tambah Pengguna?',
                              isEdit
                                  ? 'Apakah Anda yakin ingin membatalkan perubahan data pengguna? Perubahan yang belum disimpan akan hilang.'
                                  : 'Apakah Anda yakin ingin membatalkan pendaftaran pengguna baru? Data yang sudah dimasukkan akan hilang.',
                              confirmText: 'Batalkan',
                              cancelText: 'Kembali',
                              isDestructive: true,
                            );
                            if ((confirm ?? false) && context.mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final provider = context.read<AdminProvider>();
                          
                          final data = {
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'role': selectedRole,
                            'phone': phoneController.text.trim(),
                            'address': addressController.text.trim(),
                          };
                          if (!isEdit) data['password'] = passwordController.text;

                          if (isEdit) {
                            await provider.updateUser(user.id, data);
                          } else {
                            await provider.createUser(data);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            AppDialogs.showSuccessDialog(
                              context,
                              'Berhasil Disimpan',
                              isEdit 
                                  ? 'Data user ${nameController.text} telah berhasil diperbarui.'
                                  : 'User baru ${nameController.text} telah berhasil ditambahkan.',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: Size(double.infinity, ResponsiveHelper.buttonHeight(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.radiusButton(context)),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Perbarui' : 'Simpan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
