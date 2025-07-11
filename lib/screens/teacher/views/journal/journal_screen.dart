import 'package:flutter/cupertino.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/models/session.dart';
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
  @override
  Widget build(BuildContext context) {
    return JournalBlocHandler(
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
    );
  }
}
