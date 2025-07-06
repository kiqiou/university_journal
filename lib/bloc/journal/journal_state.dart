part of 'journal_bloc.dart';

@immutable
sealed class JournalState {}

final class JournalInitial extends JournalState {}

class JournalLoading extends JournalState {}

class JournalLoaded extends JournalState {
  final List<Session> sessions;
  final List<MyUser> students;

  JournalLoaded({required this.sessions, required this.students});
}

class JournalError extends JournalState {
  final String message;

  JournalError(this.message);
}