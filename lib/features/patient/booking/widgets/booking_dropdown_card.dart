import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class BookingDropdownCard extends StatelessWidget {
  final String hint;
  final int? value;
  final List<DropdownMenuItem<int>> items;
  final ValueChanged<int?> onChanged;
  final IconData icon;
  final bool enabled;

  const BookingDropdownCard({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: enabled ? AppTheme.backgroundGradient : null,
        color: enabled ? null : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: value,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: enabled ? Colors.white : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: enabled ? AppTheme.primaryColor : Colors.grey, size: 18),
            ),
          ),
          hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14)),
          items: items,
          onChanged: enabled ? onChanged : null,
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
