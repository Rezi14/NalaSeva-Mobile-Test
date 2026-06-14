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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap pilih obat terlebih dahulu',
            style: GoogleFonts.poppins(),
          ),
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
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    final existIndex = widget.medicines
        .indexWhere((m) => m['medicine_id'] == _selectedMedicine!.id);
    if (existIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedMedicine!.name} sudah ada dalam resep obat!',
            style: GoogleFonts.poppins(),
          ),
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
    setState(() => widget.medicines.removeAt(index));
    widget.onMedicinesChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCEEE7)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_rounded,
                    color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'E-Prescribing (Resep Obat Digital)',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Daftar obat
          if (widget.medicines.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada obat yang ditambahkan.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.medication_liquid_rounded,
                            size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['name'] ?? '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Aturan: ${m['dose']}  •  Jumlah: ${m['qty']} Tab',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.white70, size: 20),
                        onPressed: () => _removeMedicine(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            'Tambah Resep Baru:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),

          Consumer<PharmacyProvider>(
            builder: (context, pharmacyProvider, child) {
              if (pharmacyProvider.isLoading &&
                  pharmacyProvider.medicines.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final availableMedicines =
                  pharmacyProvider.medicines.where((m) => m.stock > 0).toList();

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dropdown pilih obat
                    DropdownButtonFormField<MedicineModel>(
                      initialValue: _selectedMedicine,
                      hint: Text(
                        'Pilih Obat dari Database',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      isExpanded: true,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.accentColor,   
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFDCEEE7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFDCEEE7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.accentColor, width: 1.5),
                        ),
                      ),
                      items: availableMedicines.map((m) {
                        return DropdownMenuItem<MedicineModel>(
                          value: m,
                          child: Text(
                            '${m.name} (Stok: ${m.stock} ${m.unit})',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.accentColor, 
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedMedicine = val),
                      validator: (v) => v == null ? 'Pilih obat' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Field dosis
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _medDoseController,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Dosis (contoh: 3 x 1)',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFDCEEE7)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFDCEEE7)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppTheme.accentColor, width: 1.5),
                              ),
                              errorStyle: GoogleFonts.poppins(fontSize: 11),
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Isi dosis'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Field jumlah
                        Expanded(
                          child: TextFormField(
                            controller: _medQtyController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Jml (Tab)',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFDCEEE7)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFDCEEE7)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppTheme.accentColor, width: 1.5),
                              ),
                              errorStyle: GoogleFonts.poppins(fontSize: 11),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Isi jml';
                              }
                              final qty = int.tryParse(v);
                              if (qty == null || qty <= 0) {
                                return 'Tidak valid';
                              }
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
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white), 
            label: const Text('Tambah Obat Ke Daftar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, 
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}