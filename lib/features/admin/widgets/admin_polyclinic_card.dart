import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../../../core/theme/app_theme.dart';

class AdminPolyclinicCard extends StatelessWidget {
  final int index;
  final PolyclinicModel polyclinic;
  final QueueModel examiningQueue;
  final List<QueueModel> waitingList;

  const AdminPolyclinicCard({
    super.key,
    required this.index,
    required this.polyclinic,
    required this.examiningQueue,
    required this.waitingList,
  });

  @override
  Widget build(BuildContext context) {
    final hasPatient = examiningQueue.id != 0;

    // Premium Color Palette by index (Emerald Green, Royal Blue, Accent Blue solid theme)
    final List<List<Color>> themeColors = [
      // [Primary Accent, Secondary Bright Accent, Deep Card BG, Glow Shadow]
      [AppTheme.primaryColor, AppTheme.accentColor, const Color(0xFF1E293B), AppTheme.primaryColor.withValues(alpha: 0.2)], // Emerald Green
      [AppTheme.secondaryColor, AppTheme.accentColor, const Color(0xFF1E293B), AppTheme.secondaryColor.withValues(alpha: 0.2)], // Royal Blue
      [AppTheme.accentColor, AppTheme.secondaryColor, const Color(0xFF1E293B), AppTheme.accentColor.withValues(alpha: 0.2)], // Blue
    ];

    final colorSet = themeColors[index % themeColors.length];
    final primaryColor = colorSet[0];
    final accentColor = colorSet[1];
    final cardBg = colorSet[2];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasPatient ? primaryColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21.5),
        child: Column(
          children: [
            // Header Card Poliklinik - Elegant Solid BG
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon + Name
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getPolyIcon(polyclinic.name),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            polyclinic.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Pulse Status Dot
                  if (hasPatient)
                    _PulseDot(color: accentColor)
                  else
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),

            // Body Card - Antrean Sekarang
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: hasPatient ? primaryColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasPatient ? primaryColor.withValues(alpha: 0.25) : Colors.white12,
                        ),
                      ),
                      child: Text(
                        'ANTREAN SEKARANG',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasPatient ? accentColor : Colors.grey.shade500,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      examiningQueue.queueNumber,
                      style: GoogleFonts.orbitron(
                        fontSize: 54,
                        fontWeight: FontWeight.bold,
                        color: hasPatient ? Colors.white : Colors.grey.shade700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasPatient ? examiningQueue.patient.fullName.toUpperCase() : 'BELUM ADA PASIEN',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasPatient ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFF334155)),

            // Footer Card - Antrean Berikutnya (Waiting List)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
              ),
              child: Row(
                children: [
                  Text(
                    'Berikutnya: ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, 
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: waitingList.isEmpty
                        ? Text(
                            'Tidak ada antrean menunggu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: waitingList.map((q) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  q.queueNumber,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get poly icon dynamically based on name
  IconData _getPolyIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('umum')) {
      return Icons.local_hospital_rounded;
    } else if (lowerName.contains('gigi')) {
      return Icons.health_and_safety_rounded;
    } else if (lowerName.contains('anak') || lowerName.contains('kia')) {
      return Icons.child_care_rounded;
    } else if (lowerName.contains('kandungan')) {
      return Icons.pregnant_woman_rounded;
    } else if (lowerName.contains('mata')) {
      return Icons.visibility_rounded;
    } else if (lowerName.contains('tht')) {
      return Icons.hearing_rounded;
    }
    return Icons.medical_services_rounded;
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.3 + (_controller.value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
