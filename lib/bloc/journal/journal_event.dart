part of 'journal_bloc.dart';

@immutable
sealed class JournalEvent {}

class LoadSessions extends JournalEvent {
  final int disciplineId;
  final int groupId;

  LoadSessions({required this.disciplineId, required this.groupId});
}

class AddSession extends JournalEvent {
  final String date;
  final String sessionType;
  final int disciplineId;
  final int groupId;

  AddSession({required this.date, required this.sessionType, required this.disciplineId, required this.groupId});
}

class UpdateSession extends JournalEvent {
  final int groupId;
  final String? date;
  final String? sessionType;
  final String? topic;
  final int disciplineId;
  final int sessionId;

  UpdateSession({required this.groupId, required this.date, required this.sessionType, required this.disciplineId, required this.sessionId, this.topic,});
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