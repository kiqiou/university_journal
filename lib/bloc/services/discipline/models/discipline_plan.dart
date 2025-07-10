class PlanItem {
  final String type;
  final int hoursAllocated;
  final int hoursPerSession;

  PlanItem({
    required this.type,
    required this.hoursAllocated,
    required this.hoursPerSession,
  });

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    return PlanItem(
      type: json['type'],
      hoursAllocated: json['hours_allocated'],
      hoursPerSession: json['hours_per_session'],
    );
  }
}
