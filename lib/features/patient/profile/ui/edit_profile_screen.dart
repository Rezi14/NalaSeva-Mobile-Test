import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/responsive_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nikController;
  String _gender = 'Laki-laki';
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phone);
    _addressController = TextEditingController(text: user?.address);
    _nikController = TextEditingController(text: user?.nationalId);
    _gender = user?.gender ?? 'Laki-laki';
    _selectedBirthDate = user?.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await context.read<AuthProvider>().updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            nationalId: _nikController.text.trim(),
            gender: _gender,
            birthDate: _selectedBirthDate != null
                ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
                : null,
          );
      if (mounted) {
        AppDialogs.showSuccessDialog(
          context,
          'Berhasil',
          'Profil berhasil diperbarui',
          onOkPressed: () {
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal',
          e.toString(),
          isError: true,
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveCenter(
        maxWidth: 700,
        child: Column(
          children: [
            // ── Header gradient hijau ──
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
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: 20),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Edit Profil Saya',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Perbarui data profesi dan kontak Anda',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.warningColor
                                  .withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppTheme.warningColor, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Untuk keamanan data, Nomor NIK tidak dapat diubah secara mandiri.',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.warningColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // NIK (read-only)
                      _buildSectionLabel('NIK (Nomor Induk Kependudukan)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nikController,
                        label: 'NIK (Tidak dapat diubah)',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),

                      // Nama Lengkap
                      _buildSectionLabel('Nama Lengkap'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildSectionLabel('Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 20),

                      // Jenis Kelamin
                      Text(
                        'Jenis Kelamin',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Laki-laki', 'Perempuan'].map((v) {
                          final isSelected = _gender == v;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: v == 'Laki-laki' ? 12.0 : 0),
                              child: InkWell(
                                onTap: () => setState(() => _gender = v),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                            .withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    v,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Tanggal Lahir
                      Text(
                        'Tanggal Lahir',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectBirthDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cake_outlined,
                                      color: Colors.grey, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedBirthDate == null
                                        ? 'Pilih Tanggal Lahir'
                                        : DateFormat('dd MMMM yyyy', 'id_ID')
                                            .format(_selectedBirthDate!),
                                    style: GoogleFonts.poppins(
                                      color: _selectedBirthDate == null
                                          ? Colors.grey
                                          : Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.calendar_today_outlined,
                                  color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nomor WhatsApp
                      _buildSectionLabel('Nomor WhatsApp (Opsional)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Nomor WhatsApp (Opsional)',
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 9) {
                            return 'Nomor HP minimal 9 digit';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Alamat
                      _buildSectionLabel('Alamat Rumah / Praktek (Opsional)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Alamat Rumah / Praktek (Opsional)',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleUpdate,
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'SIMPAN PERUBAHAN',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: GoogleFonts.poppins(
        color: readOnly ? Colors.grey.shade600 : Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            fontSize: 14, color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
      validator: validator,
    );
  }
}
