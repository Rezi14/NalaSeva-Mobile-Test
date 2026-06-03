import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/logic/auth_provider.dart';
import '../../core/router/app_router.dart';

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
    if (authProvider.user != null) {
      await authProvider.logout();
      // Redirect to login screen
      AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi Anda telah berakhir karena tidak ada aktivitas.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleUserInteraction() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
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
