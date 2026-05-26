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
    if (!_formKey.currentState!.validate()) return;
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
          onOkPressed: () {
            Navigator.pop(context);
          },
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
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Registrasi Pasien'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInDown(
                child: Text(
                  'Buat Akun Baru',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Silakan lengkapi data diri Anda untuk mendaftar',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: AuthTextField(
                  controller: _nikController,
                  label: 'NIK (16 Digit)',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  hasBorder: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'NIK tidak boleh kosong';
                    if (v.length != 16 || int.tryParse(v) == null) {
                      return 'NIK harus berupa 16 digit angka';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: AuthTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  hasBorder: true,
                  validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  hasBorder: true,
                  validator: Validators.validateEmail,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 550),
                child: Row(
                  children: [
                    Expanded(
                      child: AuthGenderButton(
                        label: 'Laki-laki',
                        icon: Icons.male_rounded,
                        isSelected: _gender == 'Laki-laki',
                        onTap: () => setState(() => _gender = 'Laki-laki'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthGenderButton(
                        label: 'Perempuan',
                        icon: Icons.female_rounded,
                        isSelected: _gender == 'Perempuan',
                        onTap: () => setState(() => _gender = 'Perempuan'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 575),
                child: FormField<DateTime>(
                  validator: (value) => _selectedBirthDate == null ? 'Tanggal lahir tidak boleh kosong' : null,
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            await _selectBirthDate();
                            state.didChange(_selectedBirthDate);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: state.hasError ? AppTheme.errorColor : Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedBirthDate == null 
                                      ? 'Tanggal Lahir' 
                                      : DateFormat('dd/MM/yyyy').format(_selectedBirthDate!),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: _selectedBirthDate == null ? Colors.grey[600] : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 16),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: AuthTextField(
                  controller: _phoneController,
                  label: 'Nomor WhatsApp',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  hasBorder: true,
                  validator: (v) => v == null || v.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: AuthTextField(
                  controller: _addressController,
                  label: 'Alamat Lengkap',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  hasBorder: true,
                  validator: (v) => v == null || v.isEmpty ? 'Alamat tidak boleh kosong' : null,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  hasBorder: true,
                  validator: (v) => v == null || v.length < 8 ? 'Minimal 8 karakter' : null,
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 900),
                child: AuthSubmitButton(
                  label: 'DAFTAR SEKARANG',
                  isLoading: isLoading,
                  onPressed: _handleRegister,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
