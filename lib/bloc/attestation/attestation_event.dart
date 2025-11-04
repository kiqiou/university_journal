part of 'attestation_bloc.dart';

sealed class AttestationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAttestations extends AttestationEvent {
  final int groupId;
  final int disciplineId;

  LoadAttestations({required this.groupId, required this.disciplineId});

  @override
  List<Object?> get props => [groupId];
}

class UpdateAttestation extends AttestationEvent {
  final int id;
  final double? averageScore;
  final String? result;
  final int groupId;
  final int disciplineId;

  UpdateAttestation({
    required this.id,
    this.averageScore,
    this.result,
    required this.groupId,
    required this.disciplineId,
  });

  @override
  List<Object?> get props => [id, groupId, disciplineId];
}

class AddUSR extends AttestationEvent {
  final int groupId;
  final int disciplineId;

  AddUSR({required this.groupId, required this.disciplineId, });

  @override
  List<Object?> get props => [];
}

class UpdateUSR extends AttestationEvent {
  final int id;
  final int grade;
  final int groupId;
  final int disciplineId;

  UpdateUSR({
    required this.id,
    required this.grade,
    required this.groupId,
    required this.disciplineId,
  });

  @override
  List<Object?> get props => [id, groupId, disciplineId];
}

class DeleteUSR extends AttestationEvent {
  final int position;
  final int groupId;
  final int disciplineId;

  DeleteUSR({required this.position, required this.groupId, required this.disciplineId,});

  @override
  List<Object?> get props => [];
}
