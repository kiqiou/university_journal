import 'package:flutter/cupertino.dart';
import 'package:university_journal/shared/theme_table/theme_bloc_handler.dart';

class ThemeScreen extends StatefulWidget{
  final bool isEditable;
  final bool isGroupSplit;
  final Function()? onTopicChanged;
  final Future<void> Function(int sessionId, String topic)? onUpdate;
  const ThemeScreen({super.key, required this.isEditable, this.onTopicChanged, required this.isGroupSplit, this.onUpdate,});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen>{
  @override
  Widget build(BuildContext context) {
    return ThemeBlocHandler(isEditable: widget.isEditable, onTopicChanged: widget.onTopicChanged, isGroupSplit: widget.isGroupSplit, onUpdate: widget.onUpdate,);
  }
}