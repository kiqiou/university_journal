import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:university_journal/bloc/journal/journal_repository.dart';
import 'package:university_journal/screens/teacher/home_screen/components/teacher_side_navigation_menu.dart';

import '../../../../bloc/journal/journal.dart';
import '../../../../components/colors/colors.dart';
import '../../../../components/journal_table.dart';
import '../../account_screen/account_screen.dart';
import '../components/add_classes_dialog.dart';

enum TeacherContentScreen {
  journal,
  account,
}

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  TeacherContentScreen currentScreen = TeacherContentScreen.journal;

  DateTime? _selectedDate;
  String? _selectedEventType;
  bool isLoading = true;
  String selectedSessionsType = 'Все';
  late List<Session> sessions;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    log("Загрузка данных сессий...");
    final journalRepository = JournalRepository();
    sessions = await journalRepository.journalData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tableKey.currentState?.updateDataSource(sessions);
    });

    setState(() {
      isLoading = false;
    });
  }

  void _filterBySessionType(String type) {
    setState(() {
      selectedSessionsType = type;
      currentScreen = TeacherContentScreen.journal;
    });

    final filtered = type == 'Все'
        ? sessions
        : sessions.where((s) => s.sessionType == type).toList();

    tableKey.currentState?.updateDataSource(filtered);
  }

  void _showAccountScreen() {
    setState(() {
      currentScreen = TeacherContentScreen.account;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          TeacherSideNavigationMenu(
            onSelectType: _filterBySessionType,
            onProfileTap: _showAccountScreen,
          ),
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
                  child: currentScreen == TeacherContentScreen.account
                      ? const AccountScreen()
                      : JournalTable(key: tableKey, isLoading: isLoading, sessions: sessions,),
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
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
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
                    sessions = newSessions;
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
