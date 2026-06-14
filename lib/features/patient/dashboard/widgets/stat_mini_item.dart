import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatMiniItem extends StatelessWidget {
  final String label;
  final String value;

  const StatMiniItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.7), 
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white, 
            fontSize: 15, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}