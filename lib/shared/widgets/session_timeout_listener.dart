import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/logic/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class SessionTimeoutListener extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutListener({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  void _handleTimeout() async {
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null && user.role == 'patient') {
      await authProvider.logout();
      // Redirect to login screen
      AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sesi Telah Berakhir',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sesi Anda telah berakhir karena tidak ada aktivitas.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.warningColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleUserInteraction() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null && user.role == 'patient') {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleUserInteraction(),
      onPointerSignal: (_) => _handleUserInteraction(),
      child: widget.child,
    );
  }
}
