import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_gender_button.dart';
import '../widgets/auth_submit_button.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nikController;
  String _gender = 'Laki-laki';
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _nikController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_selectedBirthDate == null) {
      AppDialogs.showNotificationDialog(
        context,
        'Registrasi Gagal',
        'Silakan pilih tanggal lahir Anda terlebih dahulu.',
        isError: true,
      );
      return;
    }

    try {
      await context.read<AuthProvider>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            nationalId: _nikController.text.trim(),
            gender: _gender,
            birthDate: DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
          );
      if (mounted) {
        AppDialogs.showSuccessDialog(
          context,
          'Berhasil',
          'Registrasi berhasil! Silakan login.',
          onOkPressed: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Registrasi Gagal',
          e.toString(),
          isError: true,
        );
      }
    }
  }
  
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = screenWidth >= 600;

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLarge ? 500 : double.infinity,
              ),
              padding: isLarge ? const EdgeInsets.all(32) : EdgeInsets.zero,
              decoration: isLarge
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    )
                  : null,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeInUp(
                      child: Text(
                        'Buat Akun Baru',
                        style: isLarge
                            ? GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'Silakan lengkapi data diri Anda untuk mendaftar',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isLarge
                              ? Colors.grey.shade600
                              : Colors.white.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 36),

                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: AuthTextField(
                        controller: _nikController,
                        label: 'NIK (16 Digit)',
                        hintText: 'Masukkan 16 digit NIK',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        hasBorder: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'NIK tidak boleh kosong';
                          if (!RegExp(r'^[0-9]{16}$').hasMatch(v)) {
                            return 'NIK harus berupa 16 digit angka';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: AuthTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        icon: Icons.person_outline,
                        hasBorder: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
                          if (v.trim().length < 3) return 'Nama minimal 3 karakter';
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) {
                            return 'Nama hanya boleh berisi huruf dan spasi';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Masukkan email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        hasBorder: true,
                        validator: Validators.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 16),

                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        children: [
                          Expanded(
                            child: AuthGenderButton(
                              label: _gender,
                              icon: Icons.arrow_drop_down_rounded,
                              isSelected: false,
                              onTap: () {
                                setState(() {
                                  _gender = _gender == 'Laki-laki' ? 'Perempuan' : 'Laki-laki';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: InkWell(
                              onTap: _selectBirthDate,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _selectedBirthDate == null
                                            ? 'Tanggal Lahir'
                                            : DateFormat('dd/MM/yyyy').format(_selectedBirthDate!),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _selectedBirthDate == null
                                              ? Colors.grey
                                              : AppTheme.primaryColor,
                                        ),
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
                    const SizedBox(height: 16),

                    FadeInUp(
                      delay: const Duration(milliseconds: 550),
                      child: AuthTextField(
                        controller: _phoneController,
                        label: 'Nomor WhatsApp',
                        hintText: 'Contoh: 081234567890',
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        hasBorder: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Nomor WhatsApp tidak boleh kosong';
                          }
                          final clean = v.replaceAll(RegExp(r'\s+'), '');
                          if (!RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$')
                              .hasMatch(clean)) {
                            return 'Format nomor WhatsApp tidak valid (contoh: 081234567890)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: AuthTextField(
                        controller: _addressController,
                        label: 'Alamat Lengkap',
                        hintText: 'Masukkan alamat lengkap',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                        hasBorder: true,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Alamat tidak boleh kosong'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    FadeInUp(
                      delay: const Duration(milliseconds: 650),
                      child: AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Minimal 8 karakter',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        hasBorder: true,
                        validator: (v) => v == null || v.length < 8
                            ? 'Minimal 8 karakter'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 32),

                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: AuthSubmitButton(
                        label: 'Daftar Sekarang',
                        isLoading: isLoading,
                        onPressed: _handleRegister,
                      ),
                    ),
                    const SizedBox(height: 16),

                    FadeInUp(
                      delay: const Duration(milliseconds: 750),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: 
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Kembali ke Halaman Login',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
    );
  }
}