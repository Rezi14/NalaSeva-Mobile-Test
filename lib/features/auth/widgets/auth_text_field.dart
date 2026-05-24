import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final bool hasBorder;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.hasBorder = false,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey.shade600,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    final decoration = widget.hasBorder
        ? InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: Icon(widget.icon),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          )
        : InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: Icon(widget.icon),
            suffixIcon: suffix,
          );

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      readOnly: widget.readOnly,
      style: GoogleFonts.plusJakartaSans(
        color: widget.readOnly ? Colors.grey.shade600 : Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: decoration,
      validator: widget.validator,
    );
  }
}
