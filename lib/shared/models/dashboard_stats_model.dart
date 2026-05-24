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
      polyclinicId: json['polyclinic_id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      activeQueueCount: json['active_queue_count'] ?? 0,
      waitingQueueCount: json['waiting_queue_count'] ?? 0,
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
      totalPatients: json['total_patients'] ?? 0,
      totalDoctors: json['total_doctors'] ?? 0,
      activeQueuesToday: json['active_queues_today'] ?? 0,
      completedQueuesToday: json['completed_queues_today'] ?? 0,
      cancelledQueuesToday: json['cancelled_queues_today'] ?? 0,
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
