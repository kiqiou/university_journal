import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../components/journal_table.dart';
import '../components/session_button.dart';

class JournalContentScreen extends StatefulWidget {
  final List<Session> sessions;
  final List<MyUser> students;
  final String selectedSessionsType;
  final int? selectedDisciplineIndex;
  final int? selectedGroupId;
  final int? selectedColumnIndex;
  final List<Discipline> disciplines;
  final GlobalKey<JournalTableState> tableKey;
  final String? token;
  final Function(int?) onColumnSelected;
  final Function(Session session) onDeleteSession;
  final Function(Session session) onEditSession;
  final VoidCallback onAddSession;
  final String Function() buildSessionStatsText;

  const JournalContentScreen({
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
    super.key,
  });

  @override
  State<JournalContentScreen> createState() => _JournalContentScreenState();
}

class _JournalContentScreenState extends State<JournalContentScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onColumnSelected(null),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              Text(
                widget.selectedSessionsType == 'Все'
                    ? 'Журнал'
                    : widget.selectedSessionsType,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.selectedSessionsType != 'Все')
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    widget.buildSessionStatsText(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              const Spacer(),
              if (widget.selectedColumnIndex != null) ...[
                SessionButton(
                  onChange: () {
                    final session = _getSelectedSession();
                    if (session != null) widget.onDeleteSession(session);
                  },
                  buttonName: 'Удалить занятие',
                ),
                SessionButton(
                  onChange: () {
                    final session = _getSelectedSession();
                    if (session != null) widget.onEditSession(session);
                  },
                  buttonName: 'Редактировать занятие',
                ),
              ],
              SessionButton(
                onChange: widget.onAddSession,
                buttonName: 'Добавить занятие',
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: JournalTable(
              key: widget.tableKey,
              students: widget.students,
              sessions: widget.sessions,
              isEditable: true,
              isLoading: false,
              token: widget.token,
              selectedColumnIndex: widget.selectedColumnIndex,
              onColumnSelected: widget.onColumnSelected,
              onSessionsChanged: (updatedSessions) {
                print('Сессии изменились: $updatedSessions');
              },
            ),
          ),
        ],
      ),
    );
  }

  Session? _getSelectedSession() {
    final filtered = widget.selectedSessionsType == 'Все'
        ? widget.sessions
        : widget.sessions
        .where((s) => s.type == widget.selectedSessionsType)
        .toList();

    final dates = extractUniqueDateTypes(filtered);
    if (widget.selectedColumnIndex == null || widget.selectedColumnIndex! >= dates.length) {
      return null;
    }

    final key = dates[widget.selectedColumnIndex!];
    return filtered.firstWhere(
            (s) => '${s.date} ${s.type} ${s.id}' == key);
  }
}
