enum QueueStatus {
  booked,
  waiting,
  examining,
  completed,
  cancelled,
  unknown;

  String get value {
    switch (this) {
      case QueueStatus.booked: return 'booked';
      case QueueStatus.waiting: return 'waiting';
      case QueueStatus.examining: return 'examining';
      case QueueStatus.completed: return 'completed';
      case QueueStatus.cancelled: return 'cancelled';
      case QueueStatus.unknown: return 'unknown';
    }
  }

  String get displayName {
    switch (this) {
      case QueueStatus.booked: return 'Dipesan';
      case QueueStatus.waiting: return 'Menunggu';
      case QueueStatus.examining: return 'Pemeriksaan';
      case QueueStatus.completed: return 'Selesai';
      case QueueStatus.cancelled: return 'Batal';
      case QueueStatus.unknown: return 'Tidak Dikenal';
    }
  }

  static QueueStatus fromString(String status) {
    return QueueStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => QueueStatus.unknown,
    );
  }

  bool get isActive {
    switch (this) {
      case QueueStatus.booked:
      case QueueStatus.waiting:
      case QueueStatus.examining:
        return true;
      case QueueStatus.completed:
      case QueueStatus.cancelled:
      case QueueStatus.unknown:
        return false;
    }
  }

  bool get isTerminal {
    switch (this) {
      case QueueStatus.completed:
      case QueueStatus.cancelled:
      case QueueStatus.unknown:
        return true;
      case QueueStatus.booked:
      case QueueStatus.waiting:
      case QueueStatus.examining:
        return false;
    }
  }
}
