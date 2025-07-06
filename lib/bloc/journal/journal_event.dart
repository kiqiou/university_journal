part of 'journal_bloc.dart';

@immutable
sealed class JournalEvent {}

class LoadSessions extends JournalEvent {
  final int disciplineId;
  final int groupId;

  LoadSessions({required this.disciplineId, required this.groupId});
}

class AddSession extends JournalEvent {
  final Session session;
  final int groupId;

  AddSession({required this.session, required this.groupId});
}

class UpdateSession extends JournalEvent {
  final Session session;
  final int groupId;

  UpdateSession(this.session, this.groupId);
}

class DeleteSession extends JournalEvent {
  final int sessionId;
  final int disciplineId;
  final int groupId;

  DeleteSession({
    required this.sessionId,
    required this.disciplineId,
    required this.groupId,
  });
}