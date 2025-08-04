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

class AddAttestation extends AttestationEvent {
  final Attestation attestation;

  AddAttestation({required this.attestation});

  @override
  List<Object?> get props => [attestation];
}

class UpdateAttestation extends AttestationEvent {
  final int attestationId;
  final Attestation updated;
  final int disciplineId;

  UpdateAttestation({
    required this.attestationId,
    required this.updated,
    required this.disciplineId,
  });

  @override
  List<Object?> get props => [attestationId, updated, disciplineId];
}

class DeleteAttestation extends AttestationEvent {
  final int attestationId;

  DeleteAttestation({required this.attestationId});

  @override
  List<Object?> get props => [attestationId];
}
