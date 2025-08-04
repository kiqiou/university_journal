import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../services/attestation/attestation_repository.dart';
import '../services/attestation/model/attestation.dart';

part 'attestation_event.dart';
part 'attestation_state.dart';

class AttestationBloc extends Bloc<AttestationEvent, AttestationState> {
  final USRRepository repository;

  AttestationBloc({required this.repository}) : super(AttestationInitial()) {
    on<LoadAttestations>(_onLoad);
    on<AddAttestation>(_onAdd);
    on<UpdateAttestation>(_onUpdate);
    on<DeleteAttestation>(_onDelete);
  }

  Future<void> _onLoad(
      LoadAttestations event,
      Emitter<AttestationState> emit,
      ) async {
    emit(AttestationLoading());
    try {
      final attestations = await repository.getAttestations(disciplineId: event.disciplineId, groupId: event.groupId);
      if (attestations != null) {
        emit(AttestationLoaded(attestations.cast<Attestation>()));
      } else {
        emit(AttestationError('Не удалось загрузить аттестации'));
      }
    } catch (e) {
      emit(AttestationError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onAdd(
      AddAttestation event,
      Emitter<AttestationState> emit,
      ) async {
    try {
      final success = await repository.addUSR(event.attestation.id);
      if (success) {
        add(LoadAttestations(groupId: event.attestation.group.id, disciplineId: event.attestation.discipline.id));
      } else {
        emit(AttestationError('Не удалось добавить USR'));
      }
    } catch (e) {
      emit(AttestationError('Ошибка при добавлении USR: $e'));
    }
  }

  Future<void> _onUpdate(
      UpdateAttestation event,
      Emitter<AttestationState> emit,
      ) async {
    try {
      final usrItem = event.updated.usrItems.firstWhere(
            (u) => u.attestationId == event.attestationId,
        orElse: () => throw Exception('USR не найден'),
      );

      final success = await repository.updateUSR(
        usrId: usrItem.id!,
        attestationId: event.attestationId,
        grade: usrItem.grade!,
      );

      if (success) {
        add(LoadAttestations(groupId: event.updated.group.id, disciplineId: event.updated.discipline.id));
      } else {
        emit(AttestationError('Не удалось обновить USR'));
      }
    } catch (e) {
      emit(AttestationError('Ошибка при обновлении USR: $e'));
    }
  }

  Future<void> _onDelete(
      DeleteAttestation event,
      Emitter<AttestationState> emit,
      ) async {
    try {
      final success = await repository.deleteUSR(event.attestationId);
      if (success) {
        // Неизвестно какой groupId, но можно хранить его в состоянии
        final currentState = state;
        if (currentState is AttestationLoaded) {
          add(LoadAttestations(groupId: currentState.attestations.first.group.id, disciplineId: currentState.attestations.first.discipline.id));
        } else {
          emit(AttestationInitial());
        }
      } else {
        emit(AttestationError('Не удалось удалить USR'));
      }
    } catch (e) {
      emit(AttestationError('Ошибка при удалении USR: $e'));
    }
  }
}

