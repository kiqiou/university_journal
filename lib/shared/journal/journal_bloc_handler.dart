import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/journal/journal_bloc.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/models/session.dart';
import '../utils/session_utils.dart';
import 'widgets/journal_table.dart';
import 'journal_content_screen.dart';

class JournalBlocHandler extends StatelessWidget {
  final String? token;
  final String selectedSessionsType;
  final int? selectedDisciplineIndex;
  final bool isEditable;
  final bool? isHeadman;
  final List<Discipline> disciplines;
  final int selectedGroupId;
  final int? selectedColumnIndex;
  final int? selectedColumnIndexFirst;
  final int? selectedColumnIndexSecond;
  final Function(int?)? onColumnSelectedFirst;
  final Function(int?)? onColumnSelectedSecond;
  final Function(int?)? onColumnSelected;
  final Function(Session)? onDeleteSession;
  final Function(Session)? onEditSession;
  final VoidCallback? onAddSession;
  final GlobalKey<JournalTableState> tableKey;

  const JournalBlocHandler({
    super.key,
    required this.selectedGroupId,
    required this.selectedSessionsType,
    required this.selectedDisciplineIndex,
    required this.disciplines,
    required this.token,
    required this.onDeleteSession,
    required this.onEditSession,
    required this.onAddSession,
    required this.tableKey,
    required this.selectedColumnIndex,
    required this.onColumnSelected,
    required this.isEditable,
    this.isHeadman,
    this.selectedColumnIndexFirst,
    this.selectedColumnIndexSecond,
    this.onColumnSelectedFirst,
    this.onColumnSelectedSecond,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        if (state is JournalLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JournalError) {
          return Center(child: Text('Ошибка: ${state.message}'));
        }

        if (state is JournalLoaded) {
          final filteredSessions = selectedSessionsType == 'Все'
              ? state.sessions
              : state.sessions
                  .where((s) => s.type == selectedSessionsType)
                  .toList();

          String buildSessionStatsText() {
            if (selectedSessionsType == 'Все') return '';

            final currentDiscipline = disciplines[selectedDisciplineIndex!];

            if (currentDiscipline.isGroupSplit) {
              return SessionUtils().buildSessionStatsTextWithSubgroups(
                selectedType: selectedSessionsType,
                discipline: currentDiscipline,
                sessions: filteredSessions,
              );
            } else {
              return SessionUtils().buildSessionStatsText(
                selectedType: selectedSessionsType,
                discipline: currentDiscipline,
                sessions: filteredSessions,
              );
            }
          }

          return JournalContentScreen(
            sessions: filteredSessions,
            students: state.students,
            selectedSessionsType: selectedSessionsType,
            selectedDisciplineIndex: selectedDisciplineIndex,
            selectedGroupId: selectedGroupId,
            selectedColumnIndex: selectedColumnIndex,
            selectedColumnIndexFirst: selectedColumnIndexFirst,
            selectedColumnIndexSecond: selectedColumnIndexSecond,
            disciplines: disciplines,
            tableKey: tableKey,
            token: token,
            onColumnSelected: onColumnSelected,
            onColumnSelectedFirst: onColumnSelectedFirst,
            onColumnSelectedSecond: onColumnSelectedSecond,
            onDeleteSession: onDeleteSession,
            onEditSession: onEditSession,
            onAddSession: onAddSession,
            buildSessionStatsText: buildSessionStatsText,
            isEditable: isEditable,
            isHeadman: isHeadman,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
