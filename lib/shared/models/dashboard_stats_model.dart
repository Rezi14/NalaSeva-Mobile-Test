class PolyclinicStat {
  final int polyclinicId;
  final String name;
  final int activeQueueCount;
  final int waitingQueueCount;

  PolyclinicStat({
    required this.polyclinicId,
    required this.name,
    required this.activeQueueCount,
    required this.waitingQueueCount,
  });

  factory PolyclinicStat.fromJson(Map<String, dynamic> json) {
    return PolyclinicStat(
      polyclinicId: _parseInt(json['polyclinic_id']),
      name: json['name'] ?? 'Unknown',
      activeQueueCount: _parseInt(json['active_queue_count']),
      waitingQueueCount: _parseInt(json['waiting_queue_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polyclinic_id': polyclinicId,
      'name': name,
      'active_queue_count': activeQueueCount,
      'waiting_queue_count': waitingQueueCount,
    };
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value.trim()) ?? 0;
  }
  return 0;
}

class DashboardStatsModel {
  final int totalPatients;
  final int totalDoctors;
  final int activeQueuesToday;
  final int completedQueuesToday;
  final int cancelledQueuesToday;
  final List<PolyclinicStat> polyclinicStats;

  DashboardStatsModel({
    required this.totalPatients,
    required this.totalDoctors,
    required this.activeQueuesToday,
    required this.completedQueuesToday,
    required this.cancelledQueuesToday,
    required this.polyclinicStats,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    var polyList = json['polyclinic_stats'] as List? ?? [];
    return DashboardStatsModel(
      totalPatients: _parseInt(json['total_patients']),
      totalDoctors: _parseInt(json['total_doctors']),
      activeQueuesToday: _parseInt(json['active_queues_today']),
      completedQueuesToday: _parseInt(json['completed_queues_today']),
      cancelledQueuesToday: _parseInt(json['cancelled_queues_today']),
      polyclinicStats: polyList.map((e) => PolyclinicStat.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_patients': totalPatients,
      'total_doctors': totalDoctors,
      'active_queues_today': activeQueuesToday,
      'completed_queues_today': completedQueuesToday,
      'cancelled_queues_today': cancelledQueuesToday,
      'polyclinic_stats': polyclinicStats.map((e) => e.toJson()).toList(),
    };
  }
}
