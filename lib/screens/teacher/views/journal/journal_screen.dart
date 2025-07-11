import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/journal/journal_bloc.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/journal_repository.dart';
import '../../../../bloc/services/journal/models/session.dart';
import '../../../../bloc/services/user/user_repository.dart';
import '../../../../components/journal_table.dart';
import 'journal_bloc_handler.dart';

class JournalScreen extends StatefulWidget {
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
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late JournalBloc _journalBloc;

  @override
  void initState() {
    super.initState();
    _journalBloc = JournalBloc(
      journalRepository: JournalRepository(),
      userRepository: UserRepository(),
    );

    if (widget.selectedDisciplineIndex != null && widget.selectedGroupId != null) {
      _journalBloc.add(LoadSessions(
        disciplineId: widget.disciplines[widget.selectedDisciplineIndex!].id,
        groupId: widget.selectedGroupId!,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant JournalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDisciplineIndex != oldWidget.selectedDisciplineIndex ||
        widget.selectedGroupId != oldWidget.selectedGroupId) {
      if (widget.selectedDisciplineIndex != null && widget.selectedGroupId != null) {
        _journalBloc.add(LoadSessions(
          disciplineId: widget.disciplines[widget.selectedDisciplineIndex!].id,
          groupId: widget.selectedGroupId!,
        ));
      }
    }
  }

  @override
  void dispose() {
    _journalBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _journalBloc,
      child: JournalBlocHandler(
        selectedGroupId: widget.selectedGroupId!,
        selectedSessionsType: widget.selectedSessionsType,
        selectedDisciplineIndex: widget.selectedDisciplineIndex,
        disciplines: widget.disciplines,
        token: widget.token,
        tableKey: widget.tableKey,
        selectedColumnIndex: widget.selectedColumnIndex,
        onColumnSelected: widget.onColumnSelected,
        onDeleteSession: widget.onDeleteSession,
        onEditSession: widget.onEditSession,
        onAddSession: widget.onAddSession,
        buildSessionStatsText: widget.buildSessionStatsText,
      ),
    );
  }
}

