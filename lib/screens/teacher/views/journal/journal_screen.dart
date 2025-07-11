import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/journal/journal_bloc.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/journal_repository.dart';
import '../../../../bloc/services/journal/models/session.dart';
import '../../../../bloc/services/user/user_repository.dart';
import '../../../../components/journal_table.dart';
import 'journal_bloc_handler.dart';

class JournalScreen extends StatelessWidget {
  final int? selectedGroupId;
  final String selectedSessionsType;
  final int? selectedDisciplineIndex;
  final List<Discipline> disciplines;
  final String? token;
  final GlobalKey<JournalTableState> tableKey;
  final int? selectedColumnIndex;

  final Function(int?) onColumnSelected;
  final Function(Session) onDeleteSession;
  final Function(Session) onEditSession;
  final VoidCallback onAddSession;
  final String Function() buildSessionStatsText;

  const JournalScreen({
    super.key,
    required this.selectedGroupId,
    required this.selectedSessionsType,
    required this.selectedDisciplineIndex,
    required this.disciplines,
    required this.token,
    required this.tableKey,
    required this.selectedColumnIndex,
    required this.onColumnSelected,
    required this.onDeleteSession,
    required this.onEditSession,
    required this.onAddSession,
    required this.buildSessionStatsText,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JournalBloc(
        journalRepository: JournalRepository(),
        userRepository: UserRepository(),
      )..add(LoadSessions(disciplineId: disciplines[selectedDisciplineIndex!].id, groupId: selectedGroupId!)),
      child: JournalBlocHandler(
        selectedGroupId: selectedGroupId!,
        selectedSessionsType: selectedSessionsType,
        selectedDisciplineIndex: selectedDisciplineIndex,
        disciplines: disciplines,
        token: token,
        tableKey: tableKey,
        selectedColumnIndex: selectedColumnIndex,
        onColumnSelected: onColumnSelected,
        onDeleteSession: onDeleteSession,
        onEditSession: onEditSession,
        onAddSession: onAddSession,
        buildSessionStatsText: buildSessionStatsText,
      ),
    );
  }
}
