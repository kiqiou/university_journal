import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:university_journal/bloc/journal/journal_repository.dart';
import 'package:university_journal/screens/teacher/home_screen/components/teacher_side_navigation_menu.dart';

import '../../../../bloc/journal/journal.dart';
import '../../../../components/colors/colors.dart';
import '../../../../components/journal_table.dart';
import '../components/add_classes_dialog.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();

  DateTime? _selectedDate;
  String? _selectedEventType;
  bool isLoading = true;
  String selectedSessionsType = 'Все';
  late List<Session> allSessions;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    log("Загрузка данных сессий...");
    final journalRepository = JournalRepository();
    allSessions = await journalRepository.journalData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tableKey.currentState?.updateDataSource(allSessions);
    });

    setState(() {
      isLoading = false;
    });
  }

  void _filterBySessionType(String type) {
    final filtered = type == 'Все'
        ? allSessions
        : allSessions.where((s) => s.sessionType == type).toList();
    tableKey.currentState?.updateDataSource(filtered);

    setState(() {
      selectedSessionsType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          TeacherSideNavigationMenu(onSelectType: _filterBySessionType,),
          SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35.0, right: 50.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddEventDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.blueJournal,
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 23),
                        textStyle: TextStyle(fontSize: 18),
                        minimumSize: Size(170, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Добавить занятие',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: JournalTable(key: tableKey, isLoading: isLoading),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) async {

    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        final screenHeight = MediaQuery
            .of(context)
            .size
            .height;
        return Dialog(
          insetPadding: EdgeInsets.only(
            left: screenWidth * 0.7,
            top: 20,
            right: 20,
            bottom: 20,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: screenWidth * 0.25,
            height: screenHeight * 0.85,
            padding: EdgeInsets.all(20),
            child: AddEventDialogContent(
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              onEventTypeSelected: (eventType) {
                setState(() {
                  _selectedEventType = eventType;
                });
              },
                onSavePressed: () async {
                  if (_selectedDate != null && _selectedEventType != null) {
                    final journalRepository = JournalRepository();
                    String formattedDate =
                        "${_selectedDate?.year}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.day.toString().padLeft(2, '0')}";
                    await journalRepository.addSession(
                      type: _selectedEventType!,
                      date: formattedDate,
                      courseId: 1,
                    );

                    final newSessions = await journalRepository.journalData();
                    allSessions = newSessions;
                    _filterBySessionType(selectedSessionsType);
                  }
                }
            ),
          ),
        );
      },
    );
  }
}
