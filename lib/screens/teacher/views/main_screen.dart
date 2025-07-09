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
  List<Session> filteredSessions = [];
  List<MyUser> students = [];
  List<Discipline> disciplines = [];
  late Map<String, List<Session>> groupedSessions;

  final List<Map<String, String>> lessonTypeOptions = [
    {'key': 'lecture', 'label': 'Лекция'},
    {'key': 'seminar', 'label': 'Семинар'},
    {'key': 'practice', 'label': 'Практика'},
    {'key': 'lab', 'label': 'Лабораторная'},
  ];

  @override
  void initState() {
    super.initState();
    groupedSessions = {
      'Все': sessions,
      for (final type in {'Лекция', 'Семинар', 'Практика', 'Лабораторная'})
        type: sessions.where((s) => s.type == type).toList(),
    };
    filteredSessions = groupedSessions['Все']!;
    final userRepository = UserRepository();
    userRepository.getAccessToken().then((value) {
      setState(() {
        token = value;
      });
    });
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

      filteredSessions = groupedSessions[type] ?? [];
    });
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
            s.type.toLowerCase() == selectedSessionsType.toLowerCase())
        .fold<Map<int, Session>>({}, (map, session) {
          map[session.id] = session;
          return map;
        })
        .values
        .toList();
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
        userRepository: UserRepository(),
      ),
      child: Builder(
        builder: (context) {
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
                              return BlocBuilder<JournalBloc, JournalState>(
                                builder: (context, state) {
                                  if (state is JournalLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (state is JournalLoaded) {
                                    final sessions = state.sessions;

                                    return ThemeTable(
                                      sessions: sessions,
                                      onUpdate:
                                          (sessionId, date, type, topic) async {
                                        final repository = JournalRepository();
                                        final success =
                                            await repository.updateSession(
                                          id: sessionId,
                                          date: date,
                                          type: type,
                                          topic: topic,
                                        );

                                        if (!success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Не удалось обновить данные')),
                                          );
                                        }
                                        return success;
                                      },
                                      isEditable: true,
                                      onTopicChanged: () {
                                        context.read<JournalBloc>().add(
                                              LoadSessions(
                                                disciplineId: disciplines[
                                                        selectedDisciplineIndex!]
                                                    .id,
                                                groupId: selectedGroupId!,
                                              ),
                                            );
                                      },
                                    );
                                  } else if (state is JournalError) {
                                    return Center(
                                        child:
                                            Text('Ошибка: ${state.message}'));
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              );
                            case TeacherContentScreen.journal:
                              return BlocBuilder<JournalBloc, JournalState>(
                                builder: (context, state) {
                                  if (selectedGroupId == null) {
                                    return const Center(
                                        child: Text('Выберите группу'));
                                  }

                                  if (state is JournalLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (state is JournalError) {
                                    return Center(
                                        child:
                                            Text('Ошибка: ${state.message}'));
                                  }

                                  if (state is JournalLoaded) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      setState(() {
                                        sessions = state.sessions;
                                        students = state.students;

                                        filteredSessions =
                                            selectedSessionsType == 'Все'
                                                ? sessions
                                                : sessions
                                                    .where((s) =>
                                                        s.type ==
                                                        selectedSessionsType)
                                                    .toList();
                                      });
                                    });

                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          _selectedColumnIndex = null;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 40),
                                          Row(
                                            children: [
                                              Text(
                                                selectedSessionsType == 'Все'
                                                    ? 'Журнал'
                                                    : selectedSessionsType,
                                                style: TextStyle(
                                                  color: Colors.grey.shade800,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (selectedSessionsType != 'Все')
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20,
                                                    vertical: 8,
                                                  ),
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
                                              const Spacer(),
                                              if (_selectedColumnIndex !=
                                                  null) ...[
                                                SessionButton(
                                                  onChange: () {
                                                    final filteredSessions =
                                                        selectedSessionsType ==
                                                                'Все'
                                                            ? sessions
                                                            : sessions
                                                                .where((s) =>
                                                                    s.type ==
                                                                    selectedSessionsType)
                                                                .toList();

                                                    final dates =
                                                        extractUniqueDateTypes(
                                                            filteredSessions);
                                                    final toRemove = dates[
                                                        _selectedColumnIndex!];

                                                    final session = filteredSessions
                                                        .firstWhere((s) =>
                                                            '${s.date} ${s.type} ${s.id}' ==
                                                            toRemove);

                                                    context
                                                        .read<JournalBloc>()
                                                        .add(DeleteSession(
                                                            sessionId:
                                                                session.id,
                                                            disciplineId:
                                                                disciplines[
                                                                        selectedDisciplineIndex!]
                                                                    .id,
                                                            groupId:
                                                                selectedGroupId!));

                                                    setState(() {
                                                      _selectedColumnIndex =
                                                          null;
                                                    });
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
                                                                    s.type ==
                                                                    selectedSessionsType)
                                                                .toList();

                                                    final dates =
                                                        extractUniqueDateTypes(
                                                            filteredSessions);
                                                    final toEdit = dates[
                                                        _selectedColumnIndex!];

                                                    final session = filteredSessions
                                                        .firstWhere((s) =>
                                                            '${s.date} ${s.type} ${s.id}' ==
                                                            toEdit);

                                                    _showAddEventDialog(
                                                      context,
                                                      true,
                                                      dateToEdit: DateFormat(
                                                              'dd.MM.yyyy')
                                                          .parse(session.date),
                                                      typeToEdit:
                                                          session.type,
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
                                          const SizedBox(height: 40),
                                          Expanded(
                                            child: JournalTable(
                                              key: tableKey,
                                              students: students,
                                              sessions: filteredSessions,
                                              isEditable: true,
                                              isLoading: false,
                                              token: token,
                                              selectedColumnIndex:
                                                  _selectedColumnIndex,
                                              onColumnSelected: (int index) {
                                                setState(() {
                                                  _selectedColumnIndex = index;
                                                });
                                              },
                                              onSessionsChanged:
                                                  (updatedSessions) {
                                                print(
                                                    'Сессии изменились: $updatedSessions');
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
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
                        selectedGroupId = groupId;
                      });

                      context.read<JournalBloc>().add(
                            LoadSessions(
                              disciplineId:
                                  disciplines[selectedDisciplineIndex!].id,
                              groupId: groupId,
                            ),
                          );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddEventDialog(
      BuildContext parentContext,
      bool isEditing, {
        DateTime? dateToEdit,
        String? typeToEdit,
      }) async {

    if (!isEditing && _selectedDate == null) {
      _selectedDate = DateTime.now();
    }

    if (isEditing && dateToEdit != null) {
      _selectedDate = dateToEdit;
    }

    if (isEditing && typeToEdit != null) {
      _selectedEventType = typeToEdit;
    }

    await showDialog<bool>(
      context: parentContext,
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
                  final filteredSessions = selectedSessionsType == 'Все'
                      ? sessions
                      : sessions
                          .where((s) => s.type == selectedSessionsType)
                          .toList();
                  final dates = extractUniqueDateTypes(filteredSessions);
                  final toUpdate = dates[_selectedColumnIndex!];
                  final session = filteredSessions.firstWhere(
                    (s) => '${s.date} ${s.type} ${s.id}' == toUpdate,
                  );

                  parentContext
                      .read<JournalBloc>()
                      .add(
                    UpdateSession(
                      disciplineId: disciplines[selectedDisciplineIndex!].id,
                      groupId: selectedGroupId!,
                      sessionId: session.id,
                      date: _selectedDate != null
                          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                          : null,
                      type: _selectedEventType,
                    ),
                  );

                  setState(() {
                    _selectedColumnIndex = null;
                  });

                } else {
                  if (_selectedDate != null && _selectedEventType != null) {
                    String formattedDate =
                        "${_selectedDate?.year}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.day.toString().padLeft(2, '0')}";

                    parentContext
                        .read<JournalBloc>()
                        .add(
                      AddSession(
                        disciplineId: disciplines[selectedDisciplineIndex!].id,
                        groupId: selectedGroupId!,
                        date: formattedDate,
                        type: _selectedEventType!,
                      ),
                    );
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
