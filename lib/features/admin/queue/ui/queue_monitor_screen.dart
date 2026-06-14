import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../logic/admin_provider.dart';
import '../../../../shared/models/queue_model.dart';
import '../../../../shared/models/patient_model.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import '../../polyclinic/widgets/admin_polyclinic_card.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../pharmacy/logic/pharmacy_provider.dart';
import '../../../../shared/models/payment_model.dart';

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
    
    // Muat data antrean apotek secara paralel tanpa menghambat
    if (mounted) {
      context.read<PharmacyProvider>().fetchPharmacyQueues().catchError((e) => debugPrint("Error loading pharmacy queues on TV: $e"));
    }

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
    } catch (e) {
      AppLogger.warning('Locale intl id_ID belum siap. Menggunakan fallback tanggal manual.', tag: 'QueueMonitorScreen');
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
    
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;
    
    // Dynamic column counting based on screen width
    int crossAxisCount = 1;
    if (screenWidth >= 1200) {
      crossAxisCount = 3;
    } else if (screenWidth >= 768) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    // Dynamic aspect ratio calculation to prevent vertical/horizontal overlaps
    double childAspectRatio = 1.25;
    if (isLandscape) {
      if (screenWidth >= 1200) {
        childAspectRatio = 1.3;
      } else {
        childAspectRatio = 1.4;
      }
    } else {
      if (screenWidth >= 600) {
        childAspectRatio = 1.6;
      } else {
        childAspectRatio = 1.3;
      }
    }

    final isCompactHeader = screenWidth < 680;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), 
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header TV - Highly responsive layout
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
                  child: isCompactHeader
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pushReplacementNamed(context, '/admin/home');
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.tv_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NALASEVA MONITOR ANTREAN',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        'Monitoring antrean real-time & otomatis',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$_currentDate WIB',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                Text(
                                  _currentTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.pushReplacementNamed(context, '/admin/home');
                                      }
                                    },
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 16),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NALASEVA MONITOR ANTREAN',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          'Monitoring antrean real-time & otomatis',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Clock & Date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _currentTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  '$_currentDate WIB',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
 
                // Grid Poliklinik & Antrean Apotek (Split Screen Layout)
                Expanded(
                  child: provider.isLoading && provider.polyclinics.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // LEFT SIDE: Polyclinic Grid
                            Expanded(
                              flex: 2,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(24),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount == 3 ? 2 : 1, // dynamically shrink layout on TV split
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: childAspectRatio,
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

                            // VERTICAL DIVIDER
                            VerticalDivider(
                              color: const Color(0xFF334155), 
                              width: 2,
                              thickness: 2,
                            ),

                            // RIGHT SIDE: Pharmacy (Apotek) Queues
                            Expanded(
                              flex: 1,
                              child: Consumer<PharmacyProvider>(
                                builder: (context, pharmacyProvider, child) {
                                  final pharmacyList = pharmacyProvider.queues;
                                  
                                  return Container(
                                    padding: const EdgeInsets.all(24),
                                    color: const Color(0xFF0F172A),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        Row(
                                          children: [
                                            const Icon(Icons.local_pharmacy_rounded, color: AppTheme.successColor, size: 28),
                                            const SizedBox(width: 12),
                                            Text(
                                              'ANTREAN APOTEK',
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // Column Headers & Lists
                                        Expanded(
                                          child: ListView(
                                            children: [
                                              // 1. Sedang Disiapkan
                                              _buildPharmacySectionHeader(
                                                'SEDANG DISIAPKAN', 
                                                Colors.orange, 
                                                Icons.hourglass_empty_rounded,
                                              ),
                                              const SizedBox(height: 12),
                                              if (pharmacyList.isEmpty)
                                                _buildPharmacyEmptyState('Tidak ada obat diracik')
                                              else
                                                ...pharmacyList.map((p) => _buildPharmacyQueueTile(p, Colors.orange)),
                                                
                                              const SizedBox(height: 32),
                                              
                                              // 2. Siap Diambil
                                              _buildPharmacySectionHeader(
                                                'SIAP DIAMBIL', 
                                                AppTheme.successColor, 
                                                Icons.check_circle_outline_rounded,
                                              ),
                                              const SizedBox(height: 12),
                                              _buildPharmacyEmptyState('Menunggu resep selesai'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),

            // Fullscreen Voice Call Overlay
            if (_showCallOverlay && _calledQueue != null)
              _buildCallOverlay(_calledQueue!),

            // Fullscreen Error / Authentication Overlay
            if (_errorMessage != null)
              _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }


  Widget _buildCallOverlay(QueueModel q) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      color: Colors.black.withValues(alpha: 0.95), 
      child: Center(
        child: ZoomIn(
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: isLandscape ? 600 : double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: EdgeInsets.all(isLandscape ? 32 : 24),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulse Speaker
                  SizedBox(
                    height: (screenHeight * 0.2).clamp(60.0, 120.0),
                    child: FittedBox(child: _PulseSpeaker()),
                  ),
                  SizedBox(height: (screenHeight * 0.05).clamp(12.0, 36.0)),
                  Text(
                    'PANGGILAN PASIEN',
                    style: GoogleFonts.poppins(
                      fontSize: (screenHeight * 0.035).clamp(12.0, 18.0),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      letterSpacing: 4.0,
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.03).clamp(8.0, 24.0)),
                  Text(
                    q.queueNumber,
                    style: GoogleFonts.poppins(
                      fontSize: (screenHeight * 0.15).clamp(48.0, 84.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.02).clamp(6.0, 16.0)),
                  Text(
                    q.patient.fullName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: (screenHeight * 0.05).clamp(18.0, 28.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.04).clamp(12.0, 32.0)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Text(
                      q.polyclinic.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: (screenHeight * 0.035).clamp(14.0, 20.0),
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
      ),
    );
  }

  Widget _buildErrorOverlay() {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: isLandscape ? 500 : double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: EdgeInsets.all(isLandscape ? 32 : 24),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_rounded,
                    color: Colors.redAccent,
                    size: (screenHeight * 0.08).clamp(36.0, 56.0),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.03).clamp(12.0, 24.0)),
                Text(
                  'AUTENTIKASI DIPERLUKAN',
                  style: GoogleFonts.poppins(
                    fontSize: (screenHeight * 0.035).clamp(16.0, 20.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: (screenHeight * 0.025).clamp(8.0, 16.0)),
                Text(
                  _errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: (screenHeight * 0.024).clamp(12.0, 14.0),
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: (screenHeight * 0.04).clamp(16.0, 32.0)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _loadData(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }

  Widget _buildPharmacySectionHeader(String title, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPharmacyEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPharmacyQueueTile(PaymentModel payment, Color color) {
    final patientName = payment.queue?.patient.name ?? 'Pasien';
    final qNumber = payment.queue?.queueNumber ?? '-';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              patientName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              qNumber,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
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
