import 'package:equatable/equatable.dart';
import '../../group/models/group.dart';
import '../../user/models/user.dart';
import 'discipline_plan.dart';

class Discipline extends Equatable {
  final int id;
  final String name;
  final bool isGroupSplit;
  final List<Group> groups;
  final List<MyUser> teachers;
  final List<PlanItem> planItems;

  const Discipline({required this.id, required this.name, required this.groups, required this.teachers, required this.planItems, required this.isGroupSplit, });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['id'],
      isGroupSplit: json['is_group_split'],
      name: json['name'],
      groups: (json['groups'] as List<dynamic>)
          .map((g) => Group.fromJson(g as Map<String, dynamic>))
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
