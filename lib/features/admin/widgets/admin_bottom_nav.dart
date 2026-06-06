import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';

class AdminBottomNav extends StatelessWidget {
  final int activeIndex;

  const AdminBottomNav({
    super.key,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final paddingV   = ResponsiveHelper.bottomNavPaddingV(context);
    final iconSz     = ResponsiveHelper.navIconSize(context);
    final centerPad  = ResponsiveHelper.bottomNavFabPadding(context);
    final centerIconSz = ResponsiveHelper.iconSize(context, base: 26);

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
          padding: EdgeInsets.symmetric(vertical: paddingV),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.dashboard_rounded,     0, '/admin/home',     iconSz: iconSz),
              _navItem(context, Icons.people_alt_rounded,    1, '/admin/queues',   iconSz: iconSz),
              _navItemCenter(context, Icons.qr_code_scanner_rounded, 2, '/admin/scan',
                  iconSz: centerIconSz, fabPad: centerPad),
              _navItem(context, Icons.payment_rounded,       3, '/payment/list',   iconSz: iconSz),
              _navItem(context, Icons.settings_rounded,      4, '/admin/settings', iconSz: iconSz),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    int index,
    String route, {
    required double iconSz,
  }) {
    final isActive = index == activeIndex;
    final hPad = ResponsiveHelper.isLandscape(context) ? 12.0 : 16.0;

    return GestureDetector(
      onTap: isActive
          ? null
          : () => Navigator.pushReplacementNamed(context, route),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive ? AppTheme.primaryColor : Colors.grey.shade400,
          size: iconSz,
        ),
      ),
    );
  }

  Widget _navItemCenter(
    BuildContext context,
    IconData icon,
    int index,
    String route, {
    required double iconSz,
    required double fabPad,
  }) {
    final isActive = index == activeIndex;

    return GestureDetector(
      onTap: isActive
          ? null
          : () => Navigator.pushReplacementNamed(context, route),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(fabPad),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppTheme.primaryColor,
          size: iconSz,
        ),
      ),
    );
  }
}
