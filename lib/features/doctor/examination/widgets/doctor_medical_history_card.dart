import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/examination_model.dart';
import 'doctor_history_row.dart';

class DoctorMedicalHistoryCard extends StatelessWidget {
  final ExaminationModel examination;
  final String formattedDate;

  const DoctorMedicalHistoryCard({
    super.key,
    required this.examination,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEEE7)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Poli: ${examination.queue?.polyclinic.name ?? "-"}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),
          DoctorHistoryRow(
              label: 'Keluhan:', value: examination.complaint),
          const SizedBox(height: 12),
          DoctorHistoryRow(
              label: 'Diagnosa:', value: examination.diagnosis),
          const SizedBox(height: 12),
          DoctorHistoryRow(
              label: 'Tindakan & Resep:',
              value: examination.treatment),
          const SizedBox(height: 14),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Status Obat:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: examination.medicineDeliveryStatus == 'Obat Diterima'
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : (examination.medicineDeliveryStatus ==
                                'Resep Kadaluwarsa/Tidak Ditebus'
                            ? AppTheme.errorColor.withValues(alpha: 0.1)
                            : AppTheme.warningColor.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    examination.medicineDeliveryStatus,
                    style: GoogleFonts.poppins(
                      color: examination.medicineDeliveryStatus == 'Obat Diterima'
                          ? AppTheme.successColor
                          : (examination.medicineDeliveryStatus ==
                                  'Resep Kadaluwarsa/Tidak Ditebus'
                              ? AppTheme.errorColor
                              : AppTheme.warningColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,  
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}