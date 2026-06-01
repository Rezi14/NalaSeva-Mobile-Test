import 'package:flutter_test/flutter_test.dart';

// Definisi Model Obat Lokal untuk testing
class MedicineModel {
  final int id;
  final String name;
  int stock;
  final String unit;
  final double price;

  MedicineModel({
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
    required this.price,
  });

  MedicineModel copyWith({
    String? name,
    int? stock,
    String? unit,
    double? price,
  }) {
    return MedicineModel(
      id: id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      price: price ?? this.price,
    );
  }
}

// Definisi Model Resep Apotek
class PharmacyQueueModel {
  final int id; // Payment ID
  final String transactionNumber;
  final String patientName;
  final String polyclinicName;
  final List<PharmacyItemModel> items;
  bool isDispensed;

  PharmacyQueueModel({
    required this.id,
    required this.transactionNumber,
    required this.patientName,
    required this.polyclinicName,
    required this.items,
    this.isDispensed = false,
  });
}

class PharmacyItemModel {
  final int medicineId;
  final String medicineName;
  final int quantity;
  final String instruction;

  PharmacyItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.instruction,
  });
}

// Interface Repository
abstract class PharmacyRepository {
  Future<List<PharmacyQueueModel>> getPharmacyQueues();
  Future<void> dispensePrescription(int paymentId);
  Future<List<MedicineModel>> getMedicines();
  Future<MedicineModel> addMedicine(Map<String, dynamic> data);
  Future<MedicineModel> updateMedicine(int id, Map<String, dynamic> data);
  Future<void> deleteMedicine(int id);
}

// Mock Repository
class MockPharmacyRepository implements PharmacyRepository {
  List<PharmacyQueueModel> queues = [];
  List<MedicineModel> medicines = [];
  bool shouldThrowError = false;
  String errorMessage = 'Error occurred';

  @override
  Future<List<PharmacyQueueModel>> getPharmacyQueues() async {
    if (shouldThrowError) throw errorMessage;
    return queues;
  }

  @override
  Future<void> dispensePrescription(int paymentId) async {
    if (shouldThrowError) throw errorMessage;

    final qIdx = queues.indexWhere((q) => q.id == paymentId);
    if (qIdx == -1) throw 'Prescription not found';

    final queue = queues[qIdx];

    // Validasi stok pada obat-obatan mock
    for (var item in queue.items) {
      final mIdx = medicines.indexWhere((m) => m.id == item.medicineId);
      if (mIdx == -1) throw 'Medicine not found';
      if (medicines[mIdx].stock < item.quantity) {
        throw "Stok obat '${medicines[mIdx].name}' tidak mencukupi.";
      }
    }

    // Kurangi stok
    for (var item in queue.items) {
      final mIdx = medicines.indexWhere((m) => m.id == item.medicineId);
      medicines[mIdx].stock -= item.quantity;
    }

    queue.isDispensed = true;
  }

  @override
  Future<List<MedicineModel>> getMedicines() async {
    if (shouldThrowError) throw errorMessage;
    return List<MedicineModel>.from(medicines);
  }

  @override
  Future<MedicineModel> addMedicine(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    final med = MedicineModel(
      id: medicines.length + 1,
      name: data['name'],
      stock: data['stock'],
      unit: data['unit'],
      price: data['price'],
    );
    medicines.add(med);
    return med;
  }

  @override
  Future<MedicineModel> updateMedicine(int id, Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    final idx = medicines.indexWhere((m) => m.id == id);
    if (idx != -1) {
      medicines[idx] = medicines[idx].copyWith(
        name: data['name'],
        stock: data['stock'],
        unit: data['unit'],
        price: data['price'],
      );
      return medicines[idx];
    }
    throw 'Medicine not found';
  }

  @override
  Future<void> deleteMedicine(int id) async {
    if (shouldThrowError) throw errorMessage;
    medicines.removeWhere((m) => m.id == id);
  }
}

// Provider Apotek
class PharmacyProvider {
  final PharmacyRepository _repository;
  List<PharmacyQueueModel> _queues = [];
  List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  String? _error;

  PharmacyProvider(this._repository);

  List<PharmacyQueueModel> get queues => _queues;
  List<MedicineModel> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPharmacyQueues() async {
    _isLoading = true;
    _error = null;
    try {
      _queues = await _repository.getPharmacyQueues();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> dispense(int paymentId) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.dispensePrescription(paymentId);
      _queues.removeWhere((q) => q.id == paymentId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> fetchMedicines() async {
    _isLoading = true;
    _error = null;
    try {
      _medicines = await _repository.getMedicines();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> createMedicine(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    try {
      final newMed = await _repository.addMedicine(data);
      _medicines.add(newMed);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> editMedicine(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    try {
      final updated = await _repository.updateMedicine(id, data);
      final idx = _medicines.indexWhere((m) => m.id == id);
      if (idx != -1) {
        _medicines[idx] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> removeMedicine(int id) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.deleteMedicine(id);
      _medicines.removeWhere((m) => m.id == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
}

void main() {
  late MockPharmacyRepository mockRepository;
  late PharmacyProvider pharmacyProvider;

  setUp(() {
    mockRepository = MockPharmacyRepository();
    pharmacyProvider = PharmacyProvider(mockRepository);
  });

  group('PharmacyProvider & Apotek Logic Tests', () {
    test('fetchPharmacyQueues sukses mengambil antrean resep obat apotek', () async {
      mockRepository.queues = [
        PharmacyQueueModel(
          id: 100,
          transactionNumber: 'NS-PAY-20260601-000999',
          patientName: 'Lansia Prioritas',
          polyclinicName: 'Poli Lansia',
          items: [
            PharmacyItemModel(medicineId: 1, medicineName: 'Paracetamol', quantity: 10, instruction: '3x1')
          ],
        )
      ];

      await pharmacyProvider.fetchPharmacyQueues();

      expect(pharmacyProvider.queues.length, 1);
      expect(pharmacyProvider.queues[0].patientName, 'Lansia Prioritas');
      expect(pharmacyProvider.error, null);
    });

    test('dispense sukses menyerahkan obat ke pasien dan mengurangi stok obat di mock db', () async {
      // Setup inventory stok
      mockRepository.medicines = [
        MedicineModel(id: 1, name: 'Paracetamol', stock: 100, unit: 'tablet', price: 500),
        MedicineModel(id: 2, name: 'Amoxicillin', stock: 50, unit: 'tablet', price: 1200),
      ];

      // Setup antrean obat
      final queue = PharmacyQueueModel(
        id: 100,
        transactionNumber: 'NS-PAY-20260601-000999',
        patientName: 'Lansia Prioritas',
        polyclinicName: 'Poli Lansia',
        items: [
          PharmacyItemModel(medicineId: 1, medicineName: 'Paracetamol', quantity: 10, instruction: '3x1'),
          PharmacyItemModel(medicineId: 2, medicineName: 'Amoxicillin', quantity: 5, instruction: '3x1 setelah makan')
        ],
      );
      mockRepository.queues = [queue];
      await pharmacyProvider.fetchPharmacyQueues();

      // Eksekusi dispense
      await pharmacyProvider.dispense(100);

      // Verifikasi stok berkurang
      expect(mockRepository.medicines[0].stock, 90); // 100 - 10
      expect(mockRepository.medicines[1].stock, 45);  // 50 - 5
      // Antrean diserahkan harus dihapus dari state aktif apoteker
      expect(pharmacyProvider.queues.isEmpty, true);
    });

    test('dispense melempar error dan membatalkan serah terima jika stok obat tidak mencukupi', () async {
      mockRepository.medicines = [
        MedicineModel(id: 1, name: 'Paracetamol', stock: 5, unit: 'tablet', price: 500),
      ];

      final queue = PharmacyQueueModel(
        id: 101,
        transactionNumber: 'NS-PAY-20260601-000998',
        patientName: 'Rian Reguler',
        polyclinicName: 'Poli Umum',
        items: [
          PharmacyItemModel(medicineId: 1, medicineName: 'Paracetamol', quantity: 10, instruction: '3x1'),
        ],
      );
      mockRepository.queues = [queue];
      await pharmacyProvider.fetchPharmacyQueues();

      // Eksekusi harus melempar error karena stok hanya 5, tetapi resep minta 10
      expect(
        () => pharmacyProvider.dispense(101),
        throwsA(contains("Stok obat 'Paracetamol' tidak mencukupi.")),
      );

      // Verifikasi stok tidak berkurang (DB Transaction Rollback simulation)
      expect(mockRepository.medicines[0].stock, 5);
    });

    test('Manajemen obat (CRUD) inventaris apotek bekerja sesuai hak akses', () async {
      mockRepository.medicines = [];
      await pharmacyProvider.fetchMedicines();

      // Test Create
      await pharmacyProvider.createMedicine({
        'name': 'Ibuprofen',
        'stock': 200,
        'unit': 'tablet',
        'price': 1000.0,
      });
      expect(pharmacyProvider.medicines.length, 1);
      expect(pharmacyProvider.medicines[0].name, 'Ibuprofen');

      // Test Update
      await pharmacyProvider.editMedicine(1, {
        'name': 'Ibuprofen Forte',
        'stock': 250,
        'unit': 'tablet',
        'price': 1200.0,
      });
      expect(pharmacyProvider.medicines[0].name, 'Ibuprofen Forte');
      expect(pharmacyProvider.medicines[0].stock, 250);

      // Test Delete
      await pharmacyProvider.removeMedicine(1);
      expect(pharmacyProvider.medicines.isEmpty, true);
    });
  });
}
