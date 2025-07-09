class PlanItem {
  final String type;
  final int hoursAllocated;
  final int hoursPerSession;
  final bool isGroupSplit;

  PlanItem({
    required this.type,
    required this.isGroupSplit,
    required this.hoursAllocated,
    required this.hoursPerSession,
  });

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    return PlanItem(
      type: json['type'],
      isGroupSplit: json['is_group_split'],
      hoursAllocated: json['hours_allocated'],
      hoursPerSession: json['hours_per_session'],
    );
  }
}
