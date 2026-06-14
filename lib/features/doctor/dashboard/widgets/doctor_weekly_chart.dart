import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/examination_model.dart';

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
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF87), Color(0xFF1B5E42)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 14,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<double> weekdayCounts = List.filled(7, 0.0);
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekOnly = DateTime(
        startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeekOnly =
        startOfWeekOnly.add(const Duration(days: 7));

    for (var exam in medicalRecords) {
      final parsedDate = exam.createdAt;
      if (parsedDate != null) {
        final dateOnly = DateTime(
            parsedDate.year, parsedDate.month, parsedDate.day);
        if (dateOnly.isAtSameMomentAs(startOfWeekOnly) ||
            (dateOnly.isAfter(startOfWeekOnly) &&
                dateOnly.isBefore(endOfWeekOnly))) {
          final weekdayIndex = parsedDate.weekday - 1;
          if (weekdayIndex >= 0 && weekdayIndex < 7) {
            weekdayCounts[weekdayIndex] += 1.0;
          }
        }
      }
    }

    final double maxVal =
        weekdayCounts.reduce((a, b) => a > b ? a : b);
    final double dynamicMaxY =
        maxVal > 5 ? (maxVal * 1.25).ceilToDouble() : 10.0;

    final List<String> dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final int todayIndex = now.weekday - 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCEEE7)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kunjungan Pasien',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Mingguan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.assessment_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chart body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: dynamicMaxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          AppTheme.primaryColor.withValues(alpha: 0.95),
                      getTooltipItem:
                          (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} Pasien',
                          GoogleFonts.poppins(
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
                          final i = value.toInt() % 7;
                          final isToday = i == todayIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              dayLabels[i],
                              style: GoogleFonts.poppins(
                                color: isToday
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade400,
                                fontSize: 11,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        reservedSize: 28,
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: dynamicMaxY / 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    7,
                    (i) => _makeGroupData(i, weekdayCounts[i]),
                  ),
                ),
              ),
            ),
          ),

          // Total summary
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCEEE7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total minggu ini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${weekdayCounts.reduce((a, b) => a + b).toInt()} Pasien',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}