import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/journal/journal_bloc.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/models/session.dart';
import '../../../../components/journal_table.dart';
import 'journal_content_screen.dart';

class JournalBlocHandler extends StatelessWidget {
  final int selectedGroupId;
  final String selectedSessionsType;
  final int? selectedDisciplineIndex;
  final List<Discipline> disciplines;
  final String? token;
  final Function(Session) onDeleteSession;
  final Function(Session) onEditSession;
  final VoidCallback onAddSession;
  final String Function() buildSessionStatsText;
  final GlobalKey<JournalTableState> tableKey;
  final int? selectedColumnIndex;
  final Function(int?) onColumnSelected;

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
    required this.buildSessionStatsText,
    required this.tableKey,
    required this.selectedColumnIndex,
    required this.onColumnSelected,
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

          return JournalContentScreen(
            sessions: filteredSessions,
            students: state.students,
            selectedSessionsType: selectedSessionsType,
            selectedDisciplineIndex: selectedDisciplineIndex,
            selectedGroupId: selectedGroupId,
            selectedColumnIndex: selectedColumnIndex,
            disciplines: disciplines,
            tableKey: tableKey,
            token: token,
            onColumnSelected: onColumnSelected,
            onDeleteSession: onDeleteSession,
            onEditSession: onEditSession,
            onAddSession: onAddSession,
            buildSessionStatsText: buildSessionStatsText,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
