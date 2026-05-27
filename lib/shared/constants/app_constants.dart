enum QueueStatus {
  booked,
  waiting,
  examining,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case QueueStatus.booked: return 'booked';
      case QueueStatus.waiting: return 'waiting';
      case QueueStatus.examining: return 'examining';
      case QueueStatus.completed: return 'completed';
      case QueueStatus.cancelled: return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case QueueStatus.booked: return 'Dipesan';
      case QueueStatus.waiting: return 'Menunggu';
      case QueueStatus.examining: return 'Pemeriksaan';
      case QueueStatus.completed: return 'Selesai';
      case QueueStatus.cancelled: return 'Batal';
    }
  }

  static QueueStatus fromString(String status) {
    return QueueStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => QueueStatus.cancelled,
    );
  }
}
