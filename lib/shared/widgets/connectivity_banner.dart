import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/theme/app_theme.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  StreamSubscription? _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final isConnected = _checkConnection(result);
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    final isConnected = _checkConnection(result);
    if (mounted) {
      setState(() {
        _isOffline = !isConnected;
      });
    }
  }

  bool _checkConnection(dynamic result) {
    if (result is List) {
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } else {
      return result != ConnectivityResult.none;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Koneksi Terputus',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Menampilkan data offline. Periksa kembali internet Anda.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: () {
                        _checkInitialConnectivity();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
