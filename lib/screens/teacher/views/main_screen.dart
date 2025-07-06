import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:university_journal/components/side_navigation_menu.dart';
import 'package:university_journal/screens/teacher/components/session_button.dart';

import '../../../../bloc/auth/authentication_bloc.dart';
import '../../../../components/journal_table.dart';
import '../../../bloc/journal/journal_bloc.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/models/discipline_plan.dart';
import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/widgets/discipline_and_group_select.dart';
import 'account_screen.dart';
import '../components/add_session_dialog.dart';
import '../../../../components/theme_table.dart';

enum TeacherContentScreen { journal, account, theme }

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  final _formKey = GlobalKey<FormState>();
  final userRepository = UserRepository;
  TeacherContentScreen currentScreen = TeacherContentScreen.journal;

  DateTime? _selectedDate;
  String? _selectedEventType;
  String? token;
  bool isLoading = true;
  bool isMenuExpanded = false;
  bool showDisciplineAndGroupSelect = false;
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
    final userRepository = UserRepository();
    userRepository.getAccessToken().then((value) {
      setState(() {
        token = value;
      });
    });
  }

  Future<void> loadSessions() async {
    log("Загрузка данных сессий...");
    final journalRepository = JournalRepository();
    final list = await journalRepository.journalData(
      disciplineId: disciplines[selectedDisciplineIndex!].id,
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

  Future<Map<String, dynamic>> loadJournalData(int groupId) async {
    final userRepository = UserRepository();
    final journalRepository = JournalRepository();

    final studentsFuture = userRepository.getStudentsByGroupList(groupId);
    final sessionsFuture = journalRepository.journalData(
      disciplineId: disciplines[selectedDisciplineIndex!].id,
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

    final selectedKey = selectedTypeMap['key'];

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
        .where((s) =>
            s.sessionType.toLowerCase() == selectedSessionsType.toLowerCase())
        .fold<Map<int, Session>>({}, (map, session) {
          map[session.id] = session;
          return map;
        })
        .values
        .toList();

    print(
        'Total sessions matching type "$selectedSessionsType": ${actualSessions.length}');
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
    return BlocProvider(
      create: (context) => JournalBloc(
          journalRepository: JournalRepository(),
          userRepository: UserRepository())
        ..add(
          LoadSessions(
            disciplineId: disciplines[selectedDisciplineIndex!].id,
            groupId: selectedGroupId!,
          ),
        ),
      child: Scaffold(
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
                  showGroupSelect: showDisciplineAndGroupSelect,
                  onGroupSelect: () async {
                    setState(() {
                      showDisciplineAndGroupSelect = true;
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
                            onTopicChanged: loadSessions,
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
                                            if (selectedSessionsType !=
                                                'Все') ...[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      _buildSessionStatsText(),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            Spacer(),
                                            if (_selectedColumnIndex !=
                                                null) ...[
                                              SessionButton(
                                                onChange: () async {
                                                  final filteredSessions =
                                                      selectedSessionsType ==
                                                              'Все'
                                                          ? sessions
                                                          : sessions
                                                              .where((s) =>
                                                                  s.sessionType ==
                                                                  selectedSessionsType)
                                                              .toList();

                                                  final dates =
                                                      extractUniqueDateTypes(
                                                          filteredSessions);
                                                  final toRemove = dates[
                                                      _selectedColumnIndex!];

                                                  final session =
                                                      filteredSessions
                                                          .firstWhere(
                                                    (s) =>
                                                        '${s.date} ${s.sessionType} ${s.id}' ==
                                                        toRemove,
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
                                                      _selectedColumnIndex =
                                                          null;
                                                      sessions =
                                                          updatedSessions;
                                                    });
                                                    _filterBySessionType(
                                                        selectedSessionsType);
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
                                                buttonName: 'Удалить занятие',
                                              ),
                                              SessionButton(
                                                onChange: () {
                                                  final filteredSessions =
                                                      selectedSessionsType ==
                                                              'Все'
                                                          ? sessions
                                                          : sessions
                                                              .where((s) =>
                                                                  s.sessionType ==
                                                                  selectedSessionsType)
                                                              .toList();

                                                  final dates =
                                                      extractUniqueDateTypes(
                                                          filteredSessions);
                                                  final toRemove = dates[
                                                      _selectedColumnIndex!];

                                                  final session =
                                                      filteredSessions
                                                          .firstWhere(
                                                    (s) =>
                                                        '${s.date} ${s.sessionType} ${s.id}' ==
                                                        toRemove,
                                                  );
                                                  _showAddEventDialog(
                                                    context,
                                                    true,
                                                    dateToEdit: DateFormat(
                                                            'dd.MM.yyyy')
                                                        .parse(session.date),
                                                    typeToEdit:
                                                        session.sessionType,
                                                  );
                                                },
                                                buttonName:
                                                    'Редактировать занятие',
                                              ),
                                            ],
                                            SessionButton(
                                              onChange: () =>
                                                  _showAddEventDialog(
                                                      context, false),
                                              buttonName: 'Добавить занятие',
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
                                                  child:
                                                      Text('Выберите группу'));
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            if (snapshot.hasError) {
                                              return Center(
                                                  child:
                                                      Text('Ошибка загрузки'));
                                            }
                                            if (!snapshot.hasData) {
                                              return Center(
                                                  child: Text('Нет данных'));
                                            }

                                            final students =
                                                snapshot.data!['students']
                                                    as List<MyUser>;

                                            return Expanded(
                                              child: JournalTable(
                                                key: tableKey,
                                                students: students,
                                                sessions: sessions,
                                                isEditable: true,
                                                isLoading: false,
                                                token: token,
                                                selectedColumnIndex:
                                                    _selectedColumnIndex,
                                                onColumnSelected: (int index) {
                                                  setState(() {
                                                    _selectedColumnIndex =
                                                        index;
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
            if (showDisciplineAndGroupSelect)
              GroupSelectDialog(
                showGroupSelect: true,
                show: showDisciplineAndGroupSelect,
                disciplines: disciplines,
                selectedDisciplineIndex: selectedDisciplineIndex,
                selectedGroupId: selectedGroupId,
                formKey: _formKey,
                onDisciplineChanged: (value) {
                  setState(() {
                    selectedDisciplineIndex = value;
                  });
                },
                onGroupChanged: (value) {
                  setState(() {
                    selectedGroupId = value;
                  });
                  print('Выбрана группа с ID: $value');
                },
                onClose: () {
                  setState(() {
                    showDisciplineAndGroupSelect = false;
                  });
                },
                onSubmit: (groupId) async {
                  setState(() {
                    showDisciplineAndGroupSelect = false;
                    isLoading = true;
                    journalDataFuture = loadJournalData(groupId);
                  });

                  final data = await journalDataFuture!;
                  setState(() {
                    students = data['students'] as List<MyUser>;
                    sessions = data['sessions'] as List<Session>;
                    isLoading = false;
                  });

                  return data;
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, bool isEditing,
      {DateTime? dateToEdit, String? typeToEdit}) async {
    _selectedDate ??= DateTime.now();
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
                      disciplineId: disciplines[selectedDisciplineIndex!].id,
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
                      disciplineId: disciplines[selectedDisciplineIndex!].id,
                      groupId: selectedGroupId!,
                    );

                    final newSessions = await journalRepository.journalData(
                      disciplineId: disciplines[selectedDisciplineIndex!].id,
                      groupId: selectedGroupId!,
                    );

                    print('Загружено занятий: ${newSessions.length}');
                    sessions = newSessions;
                    _filterBySessionType(selectedSessionsType);
                  }
                }
              },
              isEditing: isEditing,
              initialDate: dateToEdit,
              initialEventType: typeToEdit,
            ),
          ),
        );
      },
    );
  }
}
