part of 'attestation_bloc.dart';

sealed class AttestationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttestationInitial extends AttestationState {}

class AttestationLoading extends AttestationState {}

class AttestationLoaded extends AttestationState {
  final List<Attestation> attestations;

  AttestationLoaded(this.attestations);

  @override
  List<Object?> get props => [attestations];
}

class AttestationError extends AttestationState {
  final String message;

  AttestationError(this.message);

  @override
  List<Object?> get props => [message];
}
