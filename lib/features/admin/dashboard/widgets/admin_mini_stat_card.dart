import 'package:flutter/material.dart';

class AdminMiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color textColor;
  final bool border;
  final double? width;

  const AdminMiniStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.bgColor,
    required this.textColor,
    this.border = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: border
            ? Border.all(color: const Color(0xFFDCEEE7))
            : null,
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}