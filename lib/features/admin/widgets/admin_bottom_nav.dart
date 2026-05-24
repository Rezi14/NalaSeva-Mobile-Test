import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminBottomNav extends StatelessWidget {
  final int activeIndex;

  const AdminBottomNav({
    super.key,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.dashboard_rounded, 0, '/admin/home'),
              _navItem(context, Icons.medical_services_rounded, 1, '/admin/doctors'),
              _navItem(context, Icons.calendar_month_rounded, 2, '/admin/schedules'),
              _navItem(context, Icons.local_hospital_rounded, 3, '/admin/polyclinics'),
              _navItem(context, Icons.settings_rounded, 4, '/admin/settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, int index, String route) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: isActive
          ? null
          : () => Navigator.pushReplacementNamed(context, route),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive ? AppTheme.primaryColor : Colors.grey.shade400,
          size: 24,
        ),
      ),
    );
  }
}
