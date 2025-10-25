import 'package:equatable/equatable.dart';
import '../../group/models/group.dart';
import '../../user/models/user.dart';
import 'discipline_plan.dart';

class Discipline extends Equatable {
  final int id;
  final String name;
  final String attestationType;
  final bool isGroupSplit;
  final List<GroupSimple> groups;
  final List<MyUser> teachers;
  final List<PlanItem> planItems;

  const Discipline({required this.id, required this.name, required this.groups, required this.teachers, required this.planItems, required this.isGroupSplit, required this.attestationType,});

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['id'],
      isGroupSplit: json['is_group_split'],
      name: json['name'],
      attestationType: json['attestation_type'],
      groups: (json['groups'] as List<dynamic>)
          .map((g) => GroupSimple.fromJson(g as Map<String, dynamic>))
          .toList(),
      teachers: (json['teachers'] as List<dynamic>)
          .map((e) => MyUser.fromJson(e))
          .toList(),
      planItems: (json['plan_items'] as List<dynamic>)
        .map((e) => PlanItem.fromJson(e))
        .toList(),
    );
  }

  @override
  List<Object> get props => [id, name];
}
