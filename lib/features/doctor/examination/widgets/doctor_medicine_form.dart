import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../pharmacy/logic/pharmacy_provider.dart';
import '../../../../shared/models/medicine_model.dart';

class DoctorMedicineForm extends StatefulWidget {
  final List<Map<String, dynamic>> medicines;
  final VoidCallback onMedicinesChanged;

  const DoctorMedicineForm({
    super.key,
    required this.medicines,
    required this.onMedicinesChanged,
  });

  @override
  State<DoctorMedicineForm> createState() => _DoctorMedicineFormState();
}

class _DoctorMedicineFormState extends State<DoctorMedicineForm> {
  MedicineModel? _selectedMedicine;
  final _medDoseController = TextEditingController();
  final _medQtyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmacyProvider>().fetchMedicines();
    });
  }

  @override
  void dispose() {
    _medDoseController.dispose();
    _medQtyController.dispose();
    super.dispose();
  }

  void _addMedicine() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih obat terlebih dahulu'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final qty = int.tryParse(_medQtyController.text) ?? 0;
    if (qty > _selectedMedicine!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok tidak mencukupi! Stok ${_selectedMedicine!.name} saat ini hanya ${_selectedMedicine!.stock} ${_selectedMedicine!.unit}',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Cek apakah obat sudah ada di list
    final existIndex = widget.medicines.indexWhere((m) => m['medicine_id'] == _selectedMedicine!.id);
    if (existIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedMedicine!.name} sudah ada dalam resep obat!'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      widget.medicines.add({
        'medicine_id': _selectedMedicine!.id,
        'name': _selectedMedicine!.name,
        'dose': _medDoseController.text.trim(),
        'qty': _medQtyController.text.trim(),
      });
      _selectedMedicine = null;
      _medDoseController.clear();
      _medQtyController.clear();
    });
    widget.onMedicinesChanged();
  }

  void _removeMedicine(int index) {
    setState(() {
      widget.medicines.removeAt(index);
    });
    widget.onMedicinesChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text(
                'E-Prescribing (Resep Obat Digital)',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Added Medicines List
          if (widget.medicines.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada obat yang ditambahkan.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.medicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final m = widget.medicines[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['name'] ?? '',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor),
                            ),
                            Text(
                              'Aturan Pakai: ${m['dose']}  •  Jumlah: ${m['qty']} Tab',
                              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryColor.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.deleteColor, size: 18),
                        onPressed: () => _removeMedicine(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          // Add Medicine Inline Form Fields
          Text(
            'Tambah Resep Baru:',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          
          Consumer<PharmacyProvider>(
            builder: (context, pharmacyProvider, child) {
              if (pharmacyProvider.isLoading && pharmacyProvider.medicines.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Hanya tampilkan obat yang stoknya > 0
              final availableMedicines = pharmacyProvider.medicines.where((m) => m.stock > 0).toList();

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Medicine Picker Dropdown
                    DropdownButtonFormField<MedicineModel>(
                      initialValue: _selectedMedicine,
                      hint: Text('Pilih Obat dari Database', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: availableMedicines.map((m) {
                        return DropdownMenuItem<MedicineModel>(
                          value: m,
                          child: Text(
                            '${m.name} (Stok: ${m.stock} ${m.unit})',
                            style: GoogleFonts.inter(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMedicine = val;
                        });
                      },
                      validator: (v) => v == null ? 'Pilih obat' : null,
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dosage input
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _medDoseController,
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Dosis (contoh: 3 x 1)',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Isi dosis' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Quantity input
                        Expanded(
                          child: TextFormField(
                            controller: _medQtyController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Jml (Tab)',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Isi jml';
                              final qty = int.tryParse(v);
                              if (qty == null || qty <= 0) return 'Tidak valid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          
          ElevatedButton.icon(
            onPressed: _addMedicine,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('TAMBAH OBAT KE DAFTAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              foregroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

