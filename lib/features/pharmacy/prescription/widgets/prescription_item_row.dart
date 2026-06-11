import 'package:flutter/material.dart';
import '../../../../shared/models/prescription_item_model.dart';
import '../../../../core/theme/app_theme.dart';

class PrescriptionItemRow extends StatelessWidget {
  final PrescriptionItemModel item;

  const PrescriptionItemRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final name = item.medicine?.name ?? 'Obat';
    final qty = item.quantity;
    final unit = item.medicine?.unit ?? 'tablet';
    final instruction = item.instruction;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosis: $instruction',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '$qty $unit',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
