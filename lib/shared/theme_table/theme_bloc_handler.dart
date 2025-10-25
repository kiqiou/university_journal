import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/shared/theme_table/theme_table.dart';

import '../../bloc/journal/journal_bloc.dart';

class ThemeBlocHandler extends StatelessWidget {
  final bool isEditable;
  final bool isGroupSplit;
  final Function()? onTopicChanged;
  final Future<void> Function(int sessionId, String topic)? onUpdate;

  const ThemeBlocHandler({super.key, required this.isEditable, this.onTopicChanged, required this.isGroupSplit, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(builder: (context, state) {
      if (state is JournalLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is JournalLoaded) {
        final sessions = state.sessions;

        return ThemeTable(sessions: sessions, isEditable: isEditable, onTopicChanged: onTopicChanged, isGroupSplit: isGroupSplit, onUpdate: onUpdate,);
      } else {
        return Text('Выберите группу');
      }
    });
  }
}

