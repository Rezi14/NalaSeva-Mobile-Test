import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../logic/pharmacy_provider.dart';
import '../../../../shared/models/medicine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/medicine_inventory_card.dart';

class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({super.key});

  @override
  State<MedicineInventoryScreen> createState() =>
      _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends State<MedicineInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmacyProvider>().fetchMedicines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditMedicineDialog([MedicineModel? medicine]) {
    final isEdit = medicine != null;
    final nameController =
        TextEditingController(text: isEdit ? medicine.name : '');
    final stockController = TextEditingController(
        text: isEdit ? medicine.stock.toString() : '');
    final unitController =
        TextEditingController(text: isEdit ? medicine.unit : 'tablet');
    final priceController = TextEditingController(
        text: isEdit ? medicine.price.toInt().toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        final radius = ResponsiveHelper.radiusDialog(context);
        final maxW = ResponsiveHelper.dialogMaxWidth(context);
        return AlertDialog(
          constraints: BoxConstraints(maxWidth: maxW),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          title: Text(
            isEdit ? 'Ubah Informasi Obat' : 'Tambah Obat Baru',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppTheme.primaryColor),
                  decoration: const InputDecoration(
                    labelText: 'Nama Obat',
                    prefixIcon: Icon(Icons.medication_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.primaryColor),
                        decoration: const InputDecoration(
                          labelText: 'Stok',
                          prefixIcon: Icon(Icons.storage_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.primaryColor),
                        decoration: const InputDecoration(
                          labelText: 'Satuan',
                          hintText: 'tablet/botol',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppTheme.primaryColor),
                  decoration: const InputDecoration(
                    labelText: 'Harga (Satuan)',
                    prefixIcon: Icon(Icons.payments_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool shouldShowConfirm = false;
                if (isEdit) {
                  shouldShowConfirm =
                      nameController.text.trim() != medicine.name ||
                          stockController.text.trim() !=
                              medicine.stock.toString() ||
                          unitController.text.trim() != medicine.unit ||
                          priceController.text.trim() !=
                              medicine.price.toInt().toString();
                } else {
                  shouldShowConfirm =
                      nameController.text.trim().isNotEmpty ||
                          stockController.text.trim().isNotEmpty ||
                          (unitController.text.trim().isNotEmpty &&
                              unitController.text.trim() != 'tablet') ||
                          priceController.text.trim().isNotEmpty;
                }
                if (shouldShowConfirm) {
                  final confirm = await AppDialogs.showConfirmationDialog(
                    context,
                    'Batalkan Perubahan?',
                    'Apakah Anda yakin ingin membatalkan perubahan data obat ini?',
                    confirmText: 'Batalkan',
                    cancelText: 'Tetap Edit',
                    isDestructive: true,
                  );
                  if ((confirm ?? false) && context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                textStyle:
                    GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final stock =
                    int.tryParse(stockController.text) ?? 0;
                final unit = unitController.text.trim();
                final price =
                    double.tryParse(priceController.text) ?? 0.0;

                if (name.isEmpty || unit.isEmpty) {
                  AppDialogs.showNotificationDialog(
                    context,
                    'Gagal Menyimpan',
                    'Semua field wajib diisi!',
                    isError: true,
                  );
                  return;
                }

                final payload = {
                  'name': name,
                  'stock': stock,
                  'unit': unit,
                  'price': price,
                };

                try {
                  final provider = context.read<PharmacyProvider>();
                  if (isEdit) {
                    await provider.editMedicine(medicine.id, payload);
                  } else {
                    await provider.createMedicine(payload);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppDialogs.showSuccessDialog(
                      context,
                      'Berhasil',
                      isEdit
                          ? 'Informasi obat berhasil diupdate!'
                          : 'Obat baru berhasil ditambahkan!',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppDialogs.showNotificationDialog(
                      context,
                      'Gagal Menyimpan',
                      'Gagal menyimpan: $e',
                      isError: true,
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                textStyle:
                    GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMedicine(int id, String name) async {
    final confirm = await AppDialogs.showConfirmationDialog(
      context,
      'Konfirmasi Hapus',
      'Apakah Anda yakin ingin menghapus obat "$name"?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirm ?? false) {
      if (!mounted) return;
      try {
        await context.read<PharmacyProvider>().removeMedicine(id);
        if (mounted) {
          AppDialogs.showSuccessDialog(
            context,
            'Berhasil',
            'Obat berhasil dinonaktifkan.',
          );
        }
      } catch (e) {
        if (mounted) {
          AppDialogs.showNotificationDialog(
            context,
            'Gagal Menghapus',
            'Gagal menghapus: $e',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showAddEditMedicineDialog(),
        icon: const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Tambah Obat', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, 
          ),
        ),
      ),

      body: Column(
        children: [
          FadeIn(
            duration: const Duration(milliseconds: 400),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(
                                      context, '/admin/home');
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inventaris Obat',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Kelola stok & harga obat puskesmas',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val.toLowerCase()),
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Cari nama obat...',
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Colors.grey),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Consumer<PharmacyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.medicines.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = provider.medicines
                    .where((m) =>
                        m.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color: AppTheme.primaryColor
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Katalog obat kosong'
                              : 'Obat tidak ditemukan',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<PharmacyProvider>().fetchMedicines(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final med = filtered[index];
                      return MedicineInventoryCard(
                        medicine: med,
                        onEdit: () => _showAddEditMedicineDialog(med),
                        onDelete: () =>
                            _deleteMedicine(med.id, med.name),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}