import 'package:flutter/cupertino.dart';
import '../../../../bloc/services/discipline/models/discipline.dart';
import '../../../../bloc/services/journal/models/session.dart';
import 'widgets/journal_table.dart';
import 'journal_bloc_handler.dart';

class JournalScreen extends StatefulWidget {
  final int? selectedGroupId;
  final String selectedSessionsType;
  final int? selectedDisciplineIndex;
  final List<Discipline> disciplines;
  final String? token;
  final bool isEditable;
  final bool? isHeadman;
  final GlobalKey<JournalTableState> tableKey;
  final int? selectedColumnIndex;
  final int? selectedColumnIndexFirst;
  final int? selectedColumnIndexSecond;
  final Function(int?)? onColumnSelectedFirst;
  final Function(int?)? onColumnSelectedSecond;
  final Function(int?)? onColumnSelected;
  final Function(Session)? onDeleteSession;
  final Function(Session)? onEditSession;
  final VoidCallback? onAddSession;
  final String Function() buildSessionStatsText;

  const JournalScreen({
    super.key,
    required this.selectedGroupId,
    required this.selectedSessionsType,
    required this.selectedDisciplineIndex,
    required this.disciplines,
    required this.tableKey,
    this.token,
    this.selectedColumnIndex,
    this.onColumnSelected,
    this.onDeleteSession,
    this.onEditSession,
    this.onAddSession,
    required this.buildSessionStatsText,
    required this.isEditable,
    this.isHeadman,
    this.selectedColumnIndexFirst,
    this.selectedColumnIndexSecond,
    this.onColumnSelectedFirst,
    this.onColumnSelectedSecond,
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
      selectedColumnIndexFirst: widget.selectedColumnIndexFirst,
      selectedColumnIndexSecond: widget.selectedColumnIndexSecond,
      onColumnSelectedFirst: widget.onColumnSelectedFirst,
      onColumnSelectedSecond: widget.onColumnSelectedSecond,
      onColumnSelected: widget.onColumnSelected,
      onDeleteSession: widget.onDeleteSession,
      onEditSession: widget.onEditSession,
      onAddSession: widget.onAddSession,
      buildSessionStatsText: widget.buildSessionStatsText,
      isEditable: widget.isEditable,
      isHeadman: widget.isHeadman,
    );
  }
}
