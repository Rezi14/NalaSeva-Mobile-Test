import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/medicine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';

class MedicineInventoryCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicineInventoryCard({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final lowStock = medicine.stock <= 20;
    
    final cardRadius = ResponsiveHelper.radiusCard(context);
    final cardPadding = ResponsiveHelper.paddingCard(context);
    final textBodySize = ResponsiveHelper.fontSizeBody(context);
    final textCaptionSize = ResponsiveHelper.fontSizeCaption(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: lowStock
                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_rounded,
              color: lowStock ? AppTheme.errorColor : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: textBodySize + 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Harga: ',
                      style: TextStyle(
                        color: Colors.grey[500], 
                        fontSize: textCaptionSize,
                      ),
                    ),
                    Text(
                      _formatCurrency(medicine.price),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                        fontSize: textCaptionSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${medicine.stock} ${medicine.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: textBodySize + 1,
                  color: lowStock ? AppTheme.errorColor : Colors.grey[800],
                ),
              ),
              if (lowStock)
                Text(
                  'Hampir Habis!',
                  style: TextStyle(
                    color: AppTheme.errorColor, 
                    fontSize: textCaptionSize - 2, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppTheme.editColor, size: 20),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.deleteColor, size: 20),
                    onPressed: onDelete,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
