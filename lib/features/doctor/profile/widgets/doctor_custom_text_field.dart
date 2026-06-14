import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorCustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final String? Function(String?)? validator;

  const DoctorCustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: GoogleFonts.poppins(
        color: readOnly ? Colors.grey.shade600 : Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
      validator: validator,
    );
  }
}
