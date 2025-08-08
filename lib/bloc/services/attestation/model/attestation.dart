import '../../discipline/models/discipline.dart';
import '../../group/models/group.dart';
import '../../user/models/user.dart';

class Attestation {
  final int id;
  final MyUser student;
  final Discipline discipline;
  final Group group;
  final double averageScore;
  final String? result;
  DateTime? updatedAt;
  final List<USRItem> usrItems;

  Attestation({
    required this.id,
    required this.student,
    required this.discipline,
    required this.group,
    required this.averageScore,
    required this.result,
    this.updatedAt,
    required this.usrItems,
  });

  factory Attestation.fromJson(Map<String, dynamic> json) {
    return Attestation(
      id: json['id'] ?? 0,
      discipline: Discipline.fromJson(json['discipline']),
      group: Group.fromJson(json['group']),
      averageScore: json['average_score'] ?? 0,
      result: json['result'],
      student: MyUser(
        username: json['student']['username'] ?? '',
        role: json['student']['role']['role'] ?? '',
        id: json['student']['id'] ?? 0,
        subGroup: json['student']['subGroup'] ?? 0,
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      usrItems: (json['usr_items'] as List<dynamic>)
          .map((e) => USRItem.fromJson(e))
          .toList(),
    );
  }

  List<Object?> get props => [
        id,
        student,
        discipline,
        group,
        averageScore,
        result,
        updatedAt,
        usrItems,
      ];
}

class USRItem {
  final int id;
  final int? grade;

  USRItem({
    required this.id,
    this.grade,
  });

  factory USRItem.fromJson(Map<String, dynamic> json) {
    return USRItem(
      id: json['id'],
      grade: json['grade'],
    );
  }
}
