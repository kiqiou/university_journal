import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/discipline/discipline.dart';
import 'package:university_journal/bloc/journal/journal_repository.dart';
import 'package:university_journal/bloc/user/user_repository.dart';
import 'package:university_journal/components/side_navigation_menu.dart';

import '../../../../bloc/auth/authentication_bloc.dart';
import '../../../../bloc/discipline/discipline_plan.dart';
import '../../../../bloc/journal/journal.dart';
import '../../../../bloc/user/user.dart';
import '../../../../components/colors/colors.dart';
import '../../../../components/journal_table.dart';
import '../../account_screen/account_screen.dart';
import '../components/add_session_dialog.dart';
import '../../../../components/theme_table.dart';

enum TeacherContentScreen { journal, account, theme }

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  final _formKey = GlobalKey<FormState>();
  final userRepository = UserRepository;
  TeacherContentScreen currentScreen = TeacherContentScreen.journal;

  DateTime? _selectedDate;
  String? _selectedEventType;
  bool isLoading = true;
  bool isMenuExpanded = false;
  bool showGroupSelect = false;
  int? selectedDisciplineIndex;
  int? selectedGroupId;
  int? _selectedColumnIndex;
  String selectedSessionsType = 'Все';
  List<Session> sessions = [];
  List<MyUser> students = [];
  List<Discipline> disciplines = [];

  Future<Map<String, dynamic>>? journalDataFuture;

  final List<Map<String, String>> lessonTypeOptions = [
    {'key': 'lecture', 'label': 'Лекция'},
    {'key': 'seminar', 'label': 'Семинар'},
    {'key': 'practice', 'label': 'Практика'},
    {'key': 'lab', 'label': 'Лабораторная'},
    {'key': 'current', 'label': 'Текущая аттестация'},
    {'key': 'final', 'label': 'Промежуточная аттестация'},
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadSessions() async {
    log("Загрузка данных сессий...");
    final journalRepository = JournalRepository();
    final list = await journalRepository.journalData(
      courseId: disciplines[selectedDisciplineIndex!].id,
      groupId: selectedGroupId!,
    );
    setState(() {
      sessions = list;
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tableKey.currentState?.updateDataSource(sessions, students);
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadStudents(groupId) async {
    try {
      final userRepository = UserRepository();
      final list = await userRepository.getStudentsByGroupList(groupId);
      setState(() {
        students = list!;
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке преподавателей: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> loadJournalData(int groupId) async {
    final userRepository = UserRepository();
    final journalRepository = JournalRepository();

    final studentsFuture = userRepository.getStudentsByGroupList(groupId);
    final sessionsFuture = journalRepository.journalData(
      courseId: disciplines[selectedDisciplineIndex!].id,
      groupId: groupId,
    );

    final students = await studentsFuture;
    final sessions = await sessionsFuture;

    return {
      'students': students ?? [],
      'sessions': sessions ?? [],
    };
  }

  void loadTeacherDisciplines() {
    final authState = context.read<AuthenticationBloc>().state;

    if (authState.status == AuthenticationStatus.authenticated) {
      final teacher = authState.user;
      setState(() {
        disciplines = teacher!.disciplines;
        isLoading = false;
      });
    }
  }

  void _filterBySessionType(String type) {
    setState(() {
      selectedSessionsType = type;
      currentScreen = TeacherContentScreen.journal;
    });

    final filtered = type == 'Все'
        ? sessions
        : sessions.where((s) => s.sessionType == type).toList();

    tableKey.currentState?.updateDataSource(filtered, students);
  }

  String _buildSessionStatsText() {
    if (selectedSessionsType == 'Все') return '';

    final currentDiscipline = disciplines[selectedDisciplineIndex!];

    final selectedTypeMap = lessonTypeOptions.firstWhere(
          (type) => type['label'] == selectedSessionsType,
      orElse: () => {},
    );

    final selectedKey = selectedTypeMap['key']; // 'lecture', 'seminar' и т.д.

    if (selectedKey == null) return '';

    PlanItem? planItem;
    try {
      planItem = currentDiscipline.planItems.firstWhere(
            (item) => item.type.toLowerCase() == selectedKey.toLowerCase(),
      );
    } catch (_) {
      planItem = null;
    }

    final plannedHours = planItem?.hoursAllocated ?? 0;

    final actualSessions = sessions
        .where((s) => s.sessionType.toLowerCase() == selectedSessionsType.toLowerCase())
        .fold<Map<int, Session>>({}, (map, session) {
      map[session.id] = session;
      return map;
    })
        .values
        .toList();

    print('Total sessions matching type "$selectedSessionsType": ${actualSessions.length}');
    for (var s in actualSessions) {
      print(' - ${s.sessionType} (${s.date})');
    }

    final conductedHours = actualSessions.length * 2;

    return '$plannedHours ч. запланировано / $conductedHours ч. проведено';
  }

  void _showAccountScreen() {
    setState(() {
      currentScreen = TeacherContentScreen.account;
    });
  }

  void _showThemeScreen() {
    setState(() {
      currentScreen = TeacherContentScreen.theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              SideNavigationMenu(
                onSelectType: _filterBySessionType,
                onProfileTap: _showAccountScreen,
                onThemeTap: _showThemeScreen,
                onToggle: () {
                  setState(() {
                    isMenuExpanded = !isMenuExpanded;
                  });
                },
                isExpanded: isMenuExpanded,
                showGroupSelect: showGroupSelect,
                onGroupSelect: () async {
                  setState(() {
                    showGroupSelect = true;
                    isLoading = true;
                  });
                  loadTeacherDisciplines();
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
              SizedBox(width: 30),
              Expanded(
                child: Builder(
                  builder: (context) {
                    switch (currentScreen) {
                      case TeacherContentScreen.account:
                        return const AccountScreen();
                      case TeacherContentScreen.theme:
                        return ThemeTable(
                          sessions: sessions,
                          onUpdate: (sessionId, date, type, topic) async {
                            final repository = JournalRepository();
                            final success = await repository.updateSession(
                              id: sessionId,
                              date: date,
                              type: type,
                              topic: topic,
                            );

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Не удалось обновить данные')),
                              );
                            }
                            return success;
                          },
                          isEditable: true,
                        );
                      case TeacherContentScreen.journal:
                        return selectedGroupId != null
                            ? Scaffold(
                                body: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _selectedColumnIndex = null;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            selectedSessionsType == 'Все'
                                                ? 'Журнал'
                                                : selectedSessionsType,
                                            style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedSessionsType != 'Все') ...[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    _buildSessionStatsText(),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          Spacer(),
                                          if (_selectedColumnIndex != null) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0, right: 20.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    final filteredSessions = selectedSessionsType == 'Все'
                                                        ? sessions
                                                        : sessions.where((s) => s.sessionType == selectedSessionsType).toList();

                                                    final dates = extractUniqueDateTypes(filteredSessions);
                                                    final toRemove = dates[_selectedColumnIndex!];

                                                    final session = filteredSessions.firstWhere(
                                                          (s) => '${s.date} ${s.sessionType} ${s.id}' == toRemove,
                                                    );

                                                    final repository =
                                                        JournalRepository();
                                                    final success =
                                                        await repository
                                                            .deleteSession(
                                                                sessionId:
                                                                    session.id);

                                                    if (success) {
                                                      final updatedSessions =
                                                          List<Session>.from(
                                                              sessions)
                                                            ..removeWhere((s) =>
                                                                s.id ==
                                                                session.id);

                                                      setState(() {
                                                        _selectedColumnIndex = null;
                                                        sessions = updatedSessions;
                                                      });
                                                      _filterBySessionType(selectedSessionsType);
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Ошибка при удалении занятия')),
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        MyColors.blueJournal,
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 23),
                                                    textStyle:
                                                        TextStyle(fontSize: 18),
                                                    minimumSize: Size(170, 50),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Удалить занятие',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0, right: 20.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      _showAddEventDialog(
                                                          context, true),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        MyColors.blueJournal,
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 23),
                                                    textStyle:
                                                        TextStyle(fontSize: 18),
                                                    minimumSize: Size(170, 50),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Редактировать занятие',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0, right: 20.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _showAddEventDialog(
                                                        context, false),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      MyColors.blueJournal,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 23),
                                                  textStyle:
                                                      TextStyle(fontSize: 18),
                                                  minimumSize: Size(170, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Добавить занятие',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 40,
                                      ),
                                      FutureBuilder<Map<String, dynamic>>(
                                        future: journalDataFuture,
                                        builder: (context, snapshot) {
                                          if (journalDataFuture == null) {
                                            return Center(
                                                child: Text('Выберите группу'));
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (snapshot.hasError) {
                                            return Center(
                                                child: Text('Ошибка загрузки'));
                                          }
                                          if (!snapshot.hasData) {
                                            return Center(
                                                child: Text('Нет данных'));
                                          }

                                          final students = snapshot
                                              .data!['students'] as List<MyUser>;

                                          return Expanded(
                                            child: JournalTable(
                                              key: tableKey,
                                              students: students,
                                              sessions: sessions,
                                              isEditable: true,
                                              isLoading: false,
                                              selectedColumnIndex: _selectedColumnIndex,
                                              onColumnSelected: (int index) {
                                                setState(() {
                                                  _selectedColumnIndex = index;
                                                });
                                              },
                                              onSessionsChanged:
                                                  (updatedSessions) {
                                                print(
                                                    'Загружено занятий: $updatedSessions');
                                                sessions = updatedSessions;
                                                _filterBySessionType(
                                                    selectedSessionsType);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text('Выберите группу'),
                              );
                    }
                  },
                ),
              ),
            ],
          ),
          isMenuExpanded
              ? Positioned(
                  top: 40,
                  left: 220,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isMenuExpanded = !isMenuExpanded;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(blurRadius: 4, color: Colors.black26)
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          if (showGroupSelect)
            Positioned(
              top: 32,
              right: 32,
              child: Builder(
                builder: (context) {
                  final media = MediaQuery.of(context).size;
                  final double dialogWidth =
                      (media.width - 32 - 80).clamp(320, 600);
                  (media.height - 64).clamp(480, 1100);
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;

                  if (screenWidth < 500 || screenHeight < 500) {
                    return const SizedBox.shrink();
                  }

                  return Material(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 60),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: dialogWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Заголовок и кнопка закрытия ---
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Выберите дисциплину и группу',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            size: 28, color: Colors.black54),
                                        splashRadius: 24,
                                        onPressed: () {
                                          setState(() {
                                            showGroupSelect = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  // --- Форма ---
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Название группы
                                        Text(
                                          'Выберите дисциплину*',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        DropdownButtonFormField<int>(
                                          value: selectedDisciplineIndex,
                                          decoration: _inputDecoration(
                                              'Выберите дисциплину'),
                                          items: List.generate(
                                              disciplines.length, (index) {
                                            return DropdownMenuItem<int>(
                                              value: index,
                                              child: Text(
                                                disciplines[index].name,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF6B7280)),
                                              ),
                                            );
                                          }),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedDisciplineIndex = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Выберите дисциплину';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        if (selectedDisciplineIndex != null)
                                          DropdownButtonFormField<int>(
                                            decoration: _inputDecoration(
                                                'Выберите группу'),
                                            items: disciplines[
                                                    selectedDisciplineIndex!]
                                                .groups
                                                .map((group) {
                                              return DropdownMenuItem<int>(
                                                value: group.id,
                                                child: Text(group.name),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedGroupId = value;
                                              });
                                              print(
                                                  'Выбрана группа с ID: $value');
                                            },
                                            validator: (value) {
                                              if (value == null)
                                                return 'Выберите группу';
                                              return null;
                                            },
                                          ),
                                        const SizedBox(height: 18),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }

                                            setState(() {
                                              showGroupSelect = false;
                                              isLoading = true;
                                              journalDataFuture =
                                                  loadJournalData(
                                                      selectedGroupId!);
                                            });

                                            try {
                                              final data =
                                                  await journalDataFuture!;
                                              setState(() {
                                                students = data['students']
                                                    as List<MyUser>;
                                                sessions = data['sessions']
                                                    as List<Session>;
                                                isLoading = false;
                                              });
                                            } catch (e) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Ошибка при загрузке данных')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF4068EA),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 28, vertical: 12),
                                            minimumSize:
                                                const Size.fromHeight(55),
                                          ),
                                          child: const Text('Сохранить',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, bool isEditing) async {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: screenWidth * 0.25,
            height: screenHeight * 0.85,
            padding: EdgeInsets.all(20),
            child: AddEventDialogContent(onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            }, onEventTypeSelected: (eventType) {
              setState(() {
                _selectedEventType = eventType;
              });
            }, onSavePressed: () async {
              if (isEditing) {
                final journalRepository = JournalRepository();
                final dates = extractUniqueDateTypes(sessions);
                final toRemove = dates[_selectedColumnIndex!];
                final session = sessions.firstWhere(
                  (s) => '${s.date} ${s.sessionType} ${s.id}' == toRemove,
                );

                bool success = await journalRepository.updateSession(
                  id: session.id,
                  type: _selectedEventType,
                  date: _selectedDate != null
                ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                  : null,
                );

                if (success) {
                  final updatedSessions = await journalRepository.journalData(
                    courseId: disciplines[selectedDisciplineIndex!].id,
                    groupId: selectedGroupId!,
                  );

                  setState(() {
                    _selectedColumnIndex = null;
                    sessions = updatedSessions;
                  });

                  tableKey.currentState
                      ?.updateDataSource(updatedSessions, students);
                  sessions = updatedSessions;
                  _filterBySessionType(selectedSessionsType);
                }
              } else {
                if (_selectedDate != null && _selectedEventType != null) {
                  final journalRepository = JournalRepository();
                  String formattedDate =
                      "${_selectedDate?.year}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.day.toString().padLeft(2, '0')}";

                  await journalRepository.addSession(
                    type: _selectedEventType!,
                    date: formattedDate,
                    courseId: disciplines[selectedDisciplineIndex!].id,
                    groupId: selectedGroupId!,
                  );

                  final newSessions = await journalRepository.journalData(
                    courseId: disciplines[selectedDisciplineIndex!].id,
                    groupId: selectedGroupId!,
                  );

                  print('Загружено занятий: ${newSessions.length}');
                  sessions = newSessions;
                  _filterBySessionType(selectedSessionsType);
                }
              }
            }, isEditing: isEditing,),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
    );
  }
}
