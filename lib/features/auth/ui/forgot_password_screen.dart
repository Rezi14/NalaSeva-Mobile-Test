import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/validators.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hasRequestedOtp = false;
  String? _otpTestingCode;

  @override
  void dispose() {
    _emailController.dispose();
    _nationalIdController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _requestOtp() async {
    if (_emailController.text.isEmpty || _nationalIdController.text.isEmpty) {
      AppDialogs.showNotificationDialog(
        context,
        'Info',
        'Silakan masukkan Email dan NIK terlebih dahulu.',
        isError: true,
      );
      return;
    }
    try {
      final otp = await context.read<AuthProvider>().requestPasswordResetOtp(
            _emailController.text,
            _nationalIdController.text,
          );
      setState(() {
        _hasRequestedOtp = true;
        _otpTestingCode = otp;
      });
      if (mounted) {
        AppDialogs.showSuccessDialog(
          context,
          'OTP Terkirim',
          'Kode OTP berhasil dikirim ke email Anda.\n${otp != null ? "\n[Demo Mode] Kode OTP Anda: $otp" : ""}',
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

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_hasRequestedOtp) {
      AppDialogs.showNotificationDialog(
        context,
        'Info',
        'Silakan minta kode OTP terlebih dahulu.',
        isError: true,
      );
      return;
    }
    try {
      await context.read<AuthProvider>().forgotPassword(
            _emailController.text,
            _nationalIdController.text,
            _otpController.text,
            _newPasswordController.text,
          );
      if (mounted) {
        AppDialogs.showSuccessDialog(
          context,
          'Berhasil',
          'Password berhasil diubah. Silakan login.',
          onOkPressed: () => Navigator.pop(context),
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
                        'Reset Password',
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
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'Masukkan email dan NIK Anda untuk memverifikasi identitas, lalu masukkan kode OTP untuk merubah password.',
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
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Masukkan email terdaftar',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_hasRequestedOtp,
                        hasBorder: true,
                        validator: Validators.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 20),

                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: AuthTextField(
                        controller: _nationalIdController,
                        label: 'NIK',
                        hintText: 'Masukkan 16 digit NIK',
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        enabled: !_hasRequestedOtp,
                        hasBorder: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NIK tidak boleh kosong';
                          }
                          if (value.length != 16) return 'NIK harus 16 digit';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!_hasRequestedOtp)
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _requestOtp,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Kirim Kode OTP'),
                          ),
                        ),
                      ),

                    if (_hasRequestedOtp) ...[
                      if (_otpTestingCode != null)
                        FadeInUp(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              '[Demo Mode] Kode OTP Anda: $_otpTestingCode',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ),

                      FadeInUp(
                        child: AuthTextField(
                          controller: _otpController,
                          label: 'Kode OTP',
                          hintText: 'Masukkan 6 digit kode OTP',
                          icon: Icons.domain_verification_rounded,
                          keyboardType: TextInputType.number,
                          hasBorder: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kode OTP tidak boleh kosong';
                            }
                            if (value.length != 6) return 'OTP harus 6 digit';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      FadeInUp(
                        child: AuthTextField(
                          controller: _newPasswordController,
                          label: 'Password Baru',
                          hintText: 'Minimal 8 karakter',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          hasBorder: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 8) {
                              return 'Password minimal 8 karakter';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      FadeInUp(
                        child: AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'Konfirmasi Password Baru',
                          hintText: 'Ulangi password baru',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          hasBorder: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Kata sandi tidak cocok';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 36),

                    FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_hasRequestedOtp) ...[
                            ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Simpan Password Baru',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    ),
                            ),
                            const SizedBox(height: 16),
                          ],
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
                        ],
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