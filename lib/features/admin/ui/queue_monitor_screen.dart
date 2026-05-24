import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/utils/tts_helper.dart';
import '../logic/admin_provider.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/admin_polyclinic_card.dart';

class QueueMonitorScreen extends StatefulWidget {
  const QueueMonitorScreen({super.key});

  @override
  State<QueueMonitorScreen> createState() => _QueueMonitorScreenState();
}

class _QueueMonitorScreenState extends State<QueueMonitorScreen> {
  Timer? _pollingTimer;
  Timer? _clockTimer;
  String _currentTime = '';
  String _currentDate = '';
  
  // Track last examining queue per polyclinic
  final Map<int, int> _lastExaminingQueueIds = {};
  bool _isFirstLoad = true;

  // Visual Overlay State
  bool _showCallOverlay = false;
  QueueModel? _calledQueue;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _startClock();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadData();
      
      // Start periodic polling every 5 seconds
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (!mounted) return;
        _loadData();
      });
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = context.read<AdminProvider>();
    
    if (provider.polyclinics.isEmpty) {
      await provider.fetchPolyclinics();
      if (provider.error != null) {
        _handleLoadError(provider.error!);
        return;
      }
    }
    
    await provider.fetchQueues();
    if (provider.error != null) {
      _handleLoadError(provider.error!);
      return;
    }
    
    // Sukses memuat data
    _detectAndTriggerCall(provider.queues);
    if (mounted && _errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
    _isFirstLoad = false;
  }

  void _handleLoadError(String error) {
    debugPrint("Monitor load error from provider: $error");
    if (mounted) {
      setState(() {
        _errorMessage = error.contains('Unauthenticated')
            ? 'Akses Ditolak: Anda belum masuk sebagai Admin di perangkat ini. Silakan login sebagai Admin terlebih dahulu.'
            : 'Gagal memuat antrean: $error';
      });
    }
    _isFirstLoad = false;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _clockTimer?.cancel();
    TtsHelper.stop().catchError((e) => debugPrint("TTS stop error: $e"));
    super.dispose();
  }

  void _startClock() {
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (!mounted) return;
    final now = DateTime.now();
    String dateStr;
    try {
      dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
    } catch (_) {
      // Manual Indonesian Date Fallback jika data locale intl tidak terinisialisasi
      final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final dayName = days[now.weekday % 7];
      final monthName = months[now.month - 1];
      dateStr = "$dayName, ${now.day.toString().padLeft(2, '0')} $monthName ${now.year}";
    }
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = dateStr;
    });
  }

  void _detectAndTriggerCall(List<QueueModel> queues) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    for (final q in queues) {
      // Hanya proses antrean hari ini yang sedang diperiksa (examining)
      if (q.status == QueueStatus.examining && q.date == todayStr) {
        final polyId = q.polyclinic.id;
        final currentExaminingId = q.id;
        
        // Deteksi jika id antrean berbeda dari yang dipanggil sebelumnya
        if (_lastExaminingQueueIds[polyId] != currentExaminingId) {
          _lastExaminingQueueIds[polyId] = currentExaminingId;
          
          // Jangan panggil suara saat halaman baru pertama kali dimuat
          if (!_isFirstLoad) {
            _speakCall(q);
          }
        }
      }
    }
  }

  Future<void> _speakCall(QueueModel q) async {
    if (!mounted) return;
    setState(() {
      _calledQueue = q;
      _showCallOverlay = true;
    });

    // Ubah format A-01 menjadi A spasi 01 agar dibaca natural "A nol satu" oleh mesin suara
    final cleanQueueNum = q.queueNumber.replaceAll('-', ' ');
    final text = "Panggilan untuk nomor antrean $cleanQueueNum, atas nama ${q.patient.fullName}, silahkan menuju ke ruang ${q.polyclinic.name}.";
    
    try {
      await TtsHelper.speak(text);
    } catch (e) {
      debugPrint("TTS speak failed: $e");
    }

    // Hilangkan visual overlay secara otomatis setelah 6 detik
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _showCallOverlay = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Tampilan responsive grid (3 kolom jika landscape TV, 1 kolom jika mobile/portrait)
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 3 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Theme (Deep Slate)
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header TV
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo & Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tv_rounded,
                              color: AppTheme.primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NALASEVA MONITOR ANTREAN',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isLandscape ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Monitoring antrean real-time & otomatis',
                                style: GoogleFonts.inter(
                                  fontSize: isLandscape ? 12 : 10,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Clock & Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _currentTime,
                            style: GoogleFonts.shareTechMono(
                              fontSize: isLandscape ? 26 : 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '$_currentDate WIB',
                            style: GoogleFonts.inter(
                              fontSize: isLandscape ? 12 : 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Grid Poliklinik
                Expanded(
                  child: provider.isLoading && provider.polyclinics.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                      : GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: isLandscape ? 1.15 : 1.25,
                          ),
                          itemCount: provider.polyclinics.length,
                          itemBuilder: (context, index) {
                            final poly = provider.polyclinics[index];
                            
                            // Ambil antrean hari ini untuk poli ini
                            final polyQueues = provider.queues.where((q) => 
                              q.polyclinic.id == poly.id && q.date == todayStr
                            ).toList();

                            // Cari antrean yang SEDANG DIPERIKSA (Examining)
                            final examiningQueue = polyQueues.firstWhere(
                              (q) => q.status == QueueStatus.examining,
                              orElse: () => QueueModel(
                                id: 0,
                                queueNumber: '-',
                                status: QueueStatus.booked,
                                date: todayStr,
                                patient: PatientModel(id: 0, userId: 0, fullNameFromDb: 'Tidak Ada Pasien'),
                                polyclinic: poly,
                              ),
                            );

                            // Ambil daftar antrean yang SEDANG MENUNGGU (Waiting)
                            final waitingQueues = polyQueues.where((q) => 
                              q.status == QueueStatus.waiting
                            ).toList();

                            return FadeInUp(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              child: AdminPolyclinicCard(
                                index: index,
                                polyclinic: poly, 
                                examiningQueue: examiningQueue,
                                waitingList: waitingQueues,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // Premium Fullscreen Voice Call Overlay
            if (_showCallOverlay && _calledQueue != null)
              _buildCallOverlay(_calledQueue!),

            // Premium Fullscreen Error / Authentication Overlay
            if (_errorMessage != null)
              _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }


  Widget _buildCallOverlay(QueueModel q) {
    return Container(
      color: Colors.black.withValues(alpha: 0.95), // Gelap total agar pop-up sangat stand out
      child: Center(
        child: ZoomIn(
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: AppTheme.primaryColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseSpeaker(),
                const SizedBox(height: 36),
                Text(
                  'PANGGILAN PASIEN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  q.queueNumber,
                  style: GoogleFonts.orbitron(
                    fontSize: 84,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  q.patient.fullName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Text(
                    q.polyclinic.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: isLandscape ? 500 : double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: Colors.redAccent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AUTENTIKASI DIPERLUKAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _loadData(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('COBA LAGI'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('MASUK ADMIN'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _PulseSpeaker extends StatefulWidget {
  @override
  State<_PulseSpeaker> createState() => _PulseSpeakerState();
}

class _PulseSpeakerState extends State<_PulseSpeaker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08 + (_controller.value * 0.08)),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2 + (_controller.value * 0.3)),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.volume_up_rounded,
            size: 80,
            color: AppTheme.primaryColor,
          ),
        );
      },
    );
  }
}
