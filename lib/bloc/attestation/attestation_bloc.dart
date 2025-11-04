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
    on<UpdateAttestation>(_onAttestationUpdate);
    on<AddUSR>(_onAdd);
    on<UpdateUSR>(_onUSRUpdate);
    on<DeleteUSR>(_onDelete);
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

  Future<void> _onAttestationUpdate(
      UpdateAttestation event,
      Emitter<AttestationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! AttestationLoaded) return;

    try {
      final success = await repository.updateAttestation(
        attestationId: event.id,
        averageScore: event.averageScore,
        result: event.result,
      );

      if (success) {
        final updatedList = currentState.attestations.map((att) {
          if (att.id == event.id) {
            return Attestation(
              id: att.id,
              student: att.student,
              discipline: att.discipline,
              group: att.group,
              averageScore: event.averageScore ?? att.averageScore,
              result: event.result ?? att.result,
              updatedAt: DateTime.now(),
              usrItems: att.usrItems,
            );
          }
          return att;
        }).toList();

        emit(AttestationLoaded(updatedList));
      } else {
        emit(AttestationError('Не удалось обновить аттестацию'));
      }
    } catch (e) {
      emit(AttestationError('Ошибка при обновлении аттестации: $e'));
    }
  }

  Future<void> _onAdd(
      AddUSR event,
      Emitter<AttestationState> emit,
      ) async {
    try {
      final success = await repository.addUSR(event.disciplineId, event.groupId, );
      if (success) {
        add(LoadAttestations(groupId: event.groupId, disciplineId: event.disciplineId));
      } else {
        emit(AttestationError('Не удалось добавить USR'));
      }
    } catch (e) {
      emit(AttestationError('Ошибка при добавлении USR: $e'));
    }
  }

  Future<void> _onUSRUpdate(
      UpdateUSR event,
      Emitter<AttestationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! AttestationLoaded) return;

    try {
      final success = await repository.updateUSR(
        usrId: event.id,
        grade: event.grade,
      );

      if (success) {
        final updatedAttestations = currentState.attestations.map((attestation) {
          final updatedUsrItems = attestation.usrItems.map((usrItem) {
            if (usrItem.id == event.id) {
              return USRItem(id: usrItem.id, grade: event.grade);
            }
            return usrItem;
          }).toList();

          return Attestation(
            id: attestation.id,
            student: attestation.student,
            discipline: attestation.discipline,
            group: attestation.group,
            averageScore: attestation.averageScore,
            result: attestation.result,
            updatedAt: attestation.updatedAt,
            usrItems: updatedUsrItems,
          );
        }).toList();

        emit(AttestationLoaded(updatedAttestations));
      } else {
        emit(AttestationError('Не удалось обновить USR'));
      }
    } catch (e) {
      emit(AttestationError('Ошибка при обновлении USR: $e'));
    }
  }

  Future<void> _onDelete(
      DeleteUSR event,
      Emitter<AttestationState> emit,
      ) async {
    try {
      final success = await repository.deleteUSR(event.disciplineId, event.groupId, event.position,);
      if (success) {
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

