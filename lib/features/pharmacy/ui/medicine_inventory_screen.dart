import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/pharmacy_provider.dart';
import '../../../shared/models/medicine_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_dialogs.dart';

class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({super.key});

  @override
  State<MedicineInventoryScreen> createState() => _MedicineInventoryScreenState();
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

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  void _showAddEditMedicineDialog([MedicineModel? medicine]) {
    final isEdit = medicine != null;
    final nameController = TextEditingController(text: isEdit ? medicine.name : '');
    final stockController = TextEditingController(text: isEdit ? medicine.stock.toString() : '');
    final unitController = TextEditingController(text: isEdit ? medicine.unit : 'tablet');
    final priceController = TextEditingController(text: isEdit ? medicine.price.toInt().toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          constraints: const BoxConstraints(maxWidth: 520),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Ubah Informasi Obat' : 'Tambah Obat Baru',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
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
                        decoration: const InputDecoration(
                          labelText: 'Satuan (Unit)',
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
                  shouldShowConfirm = nameController.text.trim() != medicine.name ||
                      stockController.text.trim() != medicine.stock.toString() ||
                      unitController.text.trim() != medicine.unit ||
                      priceController.text.trim() != medicine.price.toInt().toString();
                } else {
                  shouldShowConfirm = nameController.text.trim().isNotEmpty ||
                      stockController.text.trim().isNotEmpty ||
                      (unitController.text.trim().isNotEmpty && unitController.text.trim() != 'tablet') ||
                      priceController.text.trim().isNotEmpty;
                }
                if (shouldShowConfirm) {
                  final confirm = await AppDialogs.showConfirmationDialog(
                    context,
                    'Batalkan Perubahan?',
                    'Apakah Anda yakin ingin membatalkan pengisian/perubahan data obat ini?',
                    confirmText: 'YA, BATALKAN',
                    cancelText: 'TETAP EDIT',
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
                textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final stock = int.tryParse(stockController.text) ?? 0;
                final unit = unitController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;

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
                      isEdit ? 'Informasi obat berhasil diupdate!' : 'Obat baru berhasil ditambahkan!',
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
                textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
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
      'Apakah Anda yakin ingin menghapus obat "$name"? Data akan di-softdelete.',
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
            'Obat berhasil dinonaktifkan (Soft Deleted)',
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
      appBar: AppBar(
        title: const Text('Inventaris Obat Puskesmas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Obat Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditMedicineDialog(),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama obat...',
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Inventory List
          Expanded(
            child: Consumer<PharmacyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.medicines.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = provider.medicines.where((m) {
                  return m.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty ? 'Katalog obat kosong' : 'Obat tidak ditemukan',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 84),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final med = filtered[index];
                    final lowStock = med.stock <= 20;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                                  med.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Harga: ',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                    ),
                                    Text(
                                      _formatCurrency(med.price),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondaryColor,
                                        fontSize: 13,
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
                                '${med.stock} ${med.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: lowStock ? AppTheme.errorColor : Colors.grey[800],
                                ),
                              ),
                              if (lowStock)
                                const Text(
                                  'Hampir Habis!',
                                  style: TextStyle(color: AppTheme.errorColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: AppTheme.editColor, size: 20),
                                    onPressed: () => _showAddEditMedicineDialog(med),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.deleteColor, size: 20),
                                    onPressed: () => _deleteMedicine(med.id, med.name),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
