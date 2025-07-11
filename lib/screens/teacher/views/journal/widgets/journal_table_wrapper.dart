import 'package:flutter/material.dart';
import '../../../../../bloc/services/journal/models/session.dart';
import '../../../../../bloc/services/user/models/user.dart';
import '../../../../../components/journal_table.dart';

class JournalTableWrapper extends StatelessWidget {
  final List<MyUser> students;
  final List<Session> sessions;
  final int? selectedColumnIndex;
  final Function(int?) onColumnSelected;
  final String? token;

  const JournalTableWrapper({
    super.key,
    required this.students,
    required this.sessions,
    required this.selectedColumnIndex,
    required this.onColumnSelected,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return JournalTable(
      students: students,
      sessions: sessions,
      isEditable: true,
      isLoading: false,
      token: token,
      selectedColumnIndex: selectedColumnIndex,
      onColumnSelected: onColumnSelected,
      onSessionsChanged: (updatedSessions) {
        print('Сессии изменились: $updatedSessions');
      },
    );
  }
}
