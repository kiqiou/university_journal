import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../services/journal/journal_repository.dart';
import '../services/journal/models/session.dart';
import '../services/user/models/user.dart';
import '../services/user/user_repository.dart';

part 'journal_event.dart';
part 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository journalRepository;
  final UserRepository userRepository;

  JournalBloc({
    required this.journalRepository,
    required this.userRepository,
  }) : super(JournalInitial()) {
    on<LoadSessions>(_onLoadSessions);
    on<AddSession>(_onAddSession);
    on<UpdateSession>(_onUpdateSession);
    on<DeleteSession>(_onDeleteSession);
  }

  Future<void> _onLoadSessions(
      LoadSessions event,
      Emitter<JournalState> emit,
      ) async {
    emit(JournalLoading());
    try {
      final students = await userRepository.getStudentsByGroupList(event.groupId);
      final sessions = await journalRepository.journalData(
        groupId: event.groupId,
        disciplineId: event.disciplineId,
      );

      emit(JournalLoaded(
        sessions: sessions ?? [],
        students: students ?? [],
      ));
    } catch (e) {
      emit(JournalError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _reloadSessions(int disciplineId, int groupId, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    try {
      final students = await userRepository.getStudentsByGroupList(groupId);
      final sessions = await journalRepository.journalData(
        groupId: groupId,
        disciplineId: disciplineId,
      );
      emit(JournalLoaded(
        sessions: sessions ?? [],
        students: students ?? [],
      ));
    } catch (e) {
      emit(JournalError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onAddSession(AddSession event, Emitter<JournalState> emit) async {
    try {
      final newSession = await journalRepository.addSession(
        type: event.sessionType,
        date: event.date,
        disciplineId: event.disciplineId,
        groupId: event.groupId,
      );

      if (newSession == null) throw Exception('Сессия не была создана');

      await _reloadSessions(event.disciplineId, event.groupId, emit);
    } catch (e) {
      emit(JournalError('Ошибка при добавлении: $e'));
    }
  }

  Future<void> _onUpdateSession(UpdateSession event, Emitter<JournalState> emit) async {
    try {
      final success = await journalRepository.updateSession(
        id: event.sessionId,
        date: event.date,
        type: event.sessionType,
        topic: event.topic,
      );
      if (!success) throw Exception('Ошибка обновления');

      await _reloadSessions(event.disciplineId, event.groupId, emit);
    } catch (e) {
      emit(JournalError('Ошибка при обновлении: $e'));
    }
  }

  Future<void> _onDeleteSession(DeleteSession event, Emitter<JournalState> emit) async {
    try {
      final success = await journalRepository.deleteSession(sessionId: event.sessionId);
      if (!success) throw Exception('Ошибка удаления');

      await _reloadSessions(event.disciplineId, event.groupId, emit);
    } catch (e) {
      emit(JournalError('Ошибка при удалении: $e'));
    }
  }

}
