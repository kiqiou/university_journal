import 'package:flutter/material.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/models/session.dart';
import '../../../../bloc/services/user/models/user.dart';
import 'widgets/journal_table.dart';
import 'widgets/journal_header.dart';

class JournalContentScreen extends StatelessWidget {
  final List<Session> sessions;
  final List<MyUser> students;
  final String selectedSessionsType;
  final int? selectedDisciplineIndex;
  final int? selectedGroupId;
  final List<Discipline> disciplines;
  final GlobalKey tableKey;
  final String? token;
  final bool isEditable;
  final bool? isHeadman;
  final int? selectedColumnIndex;
  final int? selectedColumnIndexFirst;
  final int? selectedColumnIndexSecond;
  final Function(int?)? onColumnSelectedFirst;
  final Function(int?)? onColumnSelectedSecond;
  final Function(int?)? onColumnSelected;
  final Function(Session session)? onDeleteSession;
  final Function(Session session)? onEditSession;
  final VoidCallback? onAddSession;
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
    required this.isEditable,
    this.isHeadman,
    this.selectedColumnIndexFirst,
    this.selectedColumnIndexSecond,
    this.onColumnSelectedFirst,
    this.onColumnSelectedSecond,
  });

  List<Session> sessionsForSubgroup(int subgroupId) {
    final isSplit = disciplines[selectedDisciplineIndex ?? 0].isGroupSplit;

    if (!isSplit) {
      return sessions;
    }

    return sessions.where((s) {
      final isStudentInSubgroup = s.student.subGroup == subgroupId;
      final isSessionForThisGroup =
          s.subGroup == null || s.subGroup == subgroupId;

      return isStudentInSubgroup && isSessionForThisGroup;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedGroupId == null) {
      return const Center(child: Text('Выберите группу'));
    }
    List<MyUser> firstSubgroup = [];
    List<MyUser> secondSubgroup = [];

    final isSplit = disciplines[selectedDisciplineIndex ?? 0].isGroupSplit;

    if (isSplit) {
      firstSubgroup = students.where((s) => s.subGroup == 1).toList();
      secondSubgroup = students.where((s) => s.subGroup == 2).toList();
    } else {
      firstSubgroup = students;
      secondSubgroup = [];
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isEditable && onColumnSelected != null) {
          onColumnSelected!(null);
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 40),
          JournalHeader(
            selectedSessionsType: selectedSessionsType,
            selectedColumnIndex: selectedColumnIndexFirst ??
                selectedColumnIndexSecond ??
                selectedColumnIndex,
            buildSessionStatsText: buildSessionStatsText,
            getSelectedSession: _getSelectedSession,
            onAddSession: onAddSession,
            onEditSession: onEditSession,
            onDeleteSession: onDeleteSession,
            isEditable: isEditable,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: disciplines[selectedDisciplineIndex ?? 0].isGroupSplit &&
                    selectedSessionsType != 'Лекция'
                ? Column(
                    children: [
                      Expanded(
                        child: JournalTable(
                          students: firstSubgroup,
                          sessions: sessionsForSubgroup(1),
                          isEditable: isEditable,
                          isHeadman: isHeadman,
                          isLoading: false,
                          token: token,
                          selectedColumnIndex: selectedColumnIndexFirst,
                          onColumnSelected: onColumnSelectedFirst,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Expanded(
                        child: JournalTable(
                          students: secondSubgroup,
                          sessions: sessionsForSubgroup(2),
                          isEditable: isEditable,
                          isHeadman: isHeadman,
                          isLoading: false,
                          token: token,
                          selectedColumnIndex: selectedColumnIndexSecond,
                          onColumnSelected: onColumnSelectedSecond,
                        ),
                      ),
                    ],
                  )
                : JournalTable(
                    students: students,
                    sessions: sessions,
                    isEditable: isEditable,
                    isHeadman: isHeadman,
                    isLoading: false,
                    token: token,
                    selectedColumnIndex: selectedColumnIndex,
                    onColumnSelected: onColumnSelected,
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
    final key = dates[selectedColumnIndexFirst ??
        selectedColumnIndexSecond ??
        selectedColumnIndex!];
    return filtered.firstWhere((s) => '${s.date} ${s.type} ${s.id}' == key);
  }
}
