import 'package:flutter/cupertino.dart';
import 'package:university_journal/shared/theme_table/theme_bloc_handler.dart';

class ThemeScreen extends StatefulWidget{
  final bool isEditable;
  final bool isGroupSplit;
  final Function()? onTopicChanged;
  const ThemeScreen({super.key, required this.isEditable, this.onTopicChanged, required this.isGroupSplit,});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen>{
  @override
  Widget build(BuildContext context) {
    return ThemeBlocHandler(isEditable: widget.isEditable, onTopicChanged: widget.onTopicChanged, isGroupSplit: widget.isGroupSplit,);
  }
}