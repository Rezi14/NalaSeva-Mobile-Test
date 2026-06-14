import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';
import '../logic/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_submit_button.dart';
import '../../../core/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/providers/puskesmas_profile_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await context.read<AuthProvider>().login(
            _emailController.text,
            _passwordController.text,
          );
      if (mounted) {
        context.read<PuskesmasProfileProvider>().fetchPuskesmasProfile();
        final provider = context.read<AuthProvider>();
        if (provider.user != null) {
          final role = provider.user?.role;
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin/home');
          } else if (role == 'doctor') {
            Navigator.pushReplacementNamed(context, '/doctor/home');
          } else if (role == 'patient') {
            Navigator.pushReplacementNamed(context, '/patient/home');
          } else if (role == 'pharmacist') {
            Navigator.pushReplacementNamed(context, '/pharmacy/home');
          } else {
            throw Exception('Peran pengguna tidak dikenal: $role');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showNotificationDialog(
          context,
          'Gagal Login',
          e.toString(),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Center(
                        child: SizedBox(
                          width: isLarge ? 120 : 150,
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          Text(
                            'Selamat Datang',
                            textAlign: TextAlign.center,
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
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan masuk untuk melanjutkan layanan kesehatan Anda.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isLarge
                                  ? Colors.grey.shade600
                                  : Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            hintText: 'Masukkan email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            hasBorder: true,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Masukkan password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            hasBorder: true,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Password tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: 
                            TextButton(
                              onPressed: () => Navigator.of(context).pushNamed(AppRouter.forgotPassword),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Lupa Password?',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Consumer<AuthProvider>(
                            builder: (context, auth, child) {
                              return AuthSubmitButton(
                                label: 'Masuk',
                                isLoading: auth.isLoading,
                                onPressed: _handleLogin,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun?',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/register'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  'Daftar Sekarang',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold,),
                                ),
                              ),
                            ],
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