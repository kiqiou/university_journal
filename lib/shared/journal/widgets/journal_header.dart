import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';
import '../../../../../bloc/services/journal/models/session.dart';

class JournalHeader extends StatelessWidget {
  final String selectedSessionsType;
  final int? selectedColumnIndex;
  final bool isEditable;
  final String Function() buildSessionStatsText;
  final Session? Function() getSelectedSession;
  final Function(Session)? onEditSession;
  final Function(Session)? onDeleteSession;
  final VoidCallback? onAddSession;

  const JournalHeader({
    super.key,
    required this.selectedSessionsType,
    required this.selectedColumnIndex,
    required this.buildSessionStatsText,
    required this.getSelectedSession,
    required this.onEditSession,
    required this.onDeleteSession,
    required this.onAddSession,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          selectedSessionsType == 'Все' ? 'Журнал' : selectedSessionsType,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (selectedSessionsType != 'Все')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              buildSessionStatsText(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        const Spacer(),
        if (selectedColumnIndex != null && isEditable) ...[
          MyButton(
            onChange: () {
              final session = getSelectedSession();
              if (session != null) onDeleteSession!(session);
            },
            buttonName: 'Удалить занятие',
          ),
          MyButton(
            onChange: () {
              final session = getSelectedSession();
              if (session != null) onEditSession!(session);
            },
            buttonName: 'Редактировать занятие',
          ),

        ],
        if(isEditable) ...[
          MyButton(
            onChange: onAddSession!,
            buttonName: 'Добавить занятие',
          ),
        ]
      ],
    );
  }
}
