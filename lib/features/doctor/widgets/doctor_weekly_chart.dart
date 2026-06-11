import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/examination_model.dart';

class DoctorWeeklyChart extends StatelessWidget {
  final List<ExaminationModel> medicalRecords;

  const DoctorWeeklyChart({
    super.key,
    required this.medicalRecords,
  });

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryColor,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<double> weekdayCounts = List.filled(7, 0.0);
    final now = DateTime.now();
    // Monday of the current week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    // Sunday of the current week (inclusive)
    final endOfWeekOnly = startOfWeekOnly.add(const Duration(days: 7));

    for (var exam in medicalRecords) {
      final parsedDate = exam.createdAt;
      if (parsedDate != null) {
        final dateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        if (dateOnly.isAtSameMomentAs(startOfWeekOnly) || 
            (dateOnly.isAfter(startOfWeekOnly) && dateOnly.isBefore(endOfWeekOnly))) {
          final weekdayIndex = parsedDate.weekday - 1; // 0 (Mon) to 6 (Sun)
          if (weekdayIndex >= 0 && weekdayIndex < 7) {
            weekdayCounts[weekdayIndex] += 1.0;
          }
        }
      }
    }
    final List<double> finalCounts = weekdayCounts;
    final double maxVal = finalCounts.reduce((a, b) => a > b ? a : b);
    final double dynamicMaxY = maxVal > 5 ? (maxVal * 1.25).ceilToDouble() : 10.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kunjungan Pasien',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Mingguan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.assessment_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: dynamicMaxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.primaryColor.withValues(alpha: 0.95),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} Pasien',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, finalCounts[0]),
                  _makeGroupData(1, finalCounts[1]),
                  _makeGroupData(2, finalCounts[2]),
                  _makeGroupData(3, finalCounts[3]),
                  _makeGroupData(4, finalCounts[4]),
                  _makeGroupData(5, finalCounts[5]),
                  _makeGroupData(6, finalCounts[6]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
