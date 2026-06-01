import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminSettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  const AdminSettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
