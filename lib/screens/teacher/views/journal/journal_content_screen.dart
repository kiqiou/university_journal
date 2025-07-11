import 'package:flutter/material.dart';
import 'package:university_journal/screens/teacher/views/journal/widgets/table_wrapper.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/models/session.dart';
import '../../../../bloc/services/user/models/user.dart';
import '../../../../components/journal_table.dart';
import 'widgets/journal_header.dart';

class JournalContentScreen extends StatelessWidget {
  final List<Session> sessions;
  final List<MyUser> students;
  final String selectedSessionsType;
  final int? selectedDisciplineIndex;
  final int? selectedGroupId;
  final int? selectedColumnIndex;
  final List<Discipline> disciplines;
  final GlobalKey tableKey;
  final String? token;
  final Function(int?) onColumnSelected;
  final Function(Session session) onDeleteSession;
  final Function(Session session) onEditSession;
  final VoidCallback onAddSession;
  final String Function() buildSessionStatsText;

  const JournalContentScreen({
    super.key,
    required this.sessions,
    required this.students,
    required this.selectedSessionsType,
    required this.selectedDisciplineIndex,
    required this.selectedGroupId,
    required this.selectedColumnIndex,
    required this.disciplines,
    required this.tableKey,
    required this.token,
    required this.onColumnSelected,
    required this.onDeleteSession,
    required this.onEditSession,
    required this.onAddSession,
    required this.buildSessionStatsText,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedGroupId == null) {
      return const Center(child: Text('Выберите группу'));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onColumnSelected(null),
      child: Column(
        children: [
          const SizedBox(height: 40),
          JournalHeader(
            selectedSessionsType: selectedSessionsType,
            selectedColumnIndex: selectedColumnIndex,
            buildSessionStatsText: buildSessionStatsText,
            getSelectedSession: _getSelectedSession,
            onAddSession: onAddSession,
            onEditSession: onEditSession,
            onDeleteSession: onDeleteSession,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: JournalTableWrapper(
              key: tableKey,
              students: students,
              sessions: sessions,
              selectedColumnIndex: selectedColumnIndex,
              onColumnSelected: onColumnSelected,
              token: token,
            ),
          ),
        ],
      ),
    );
  }

  Session? _getSelectedSession() {
    final filtered = selectedSessionsType == 'Все'
        ? sessions
        : sessions.where((s) => s.type == selectedSessionsType).toList();

    final dates = extractUniqueDateTypes(filtered);
    if (selectedColumnIndex == null || selectedColumnIndex! >= dates.length) {
      return null;
    }

    final key = dates[selectedColumnIndex!];
    return filtered.firstWhere((s) => '${s.date} ${s.type} ${s.id}' == key);
  }
}
