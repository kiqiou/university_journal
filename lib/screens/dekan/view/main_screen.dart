import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/journal/journal_bloc.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/models/discipline_plan.dart';
import '../../../bloc/services/discipline/discipline_repository.dart';
import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/journal_table.dart';
import '../../../components/side_navigation_menu.dart';
import '../../../components/theme_table.dart';
import '../../../components/widgets/discipline_and_group_select.dart';
import '../../../components/widgets/menu_arrow.dart';

enum DeanContentScreen { journal, theme }

class DeanMainScreen extends StatefulWidget {
  const DeanMainScreen({super.key});

  @override
  State<DeanMainScreen> createState() => _DeanMainScreenState();
}

class _DeanMainScreenState extends State<DeanMainScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  final _formKey = GlobalKey<FormState>();
  DeanContentScreen currentScreen = DeanContentScreen.journal;
  Future<Map<String, dynamic>>? journalDataFuture;

  bool isLoading = true;
  bool isMenuExpanded = false;
  bool showTeacherDisciplineGroupSelect = false;
  int? selectedDisciplineIndex;
  int? selectedGroupId;
  String selectedSessionsType = 'Все';
  List<Session> sessions = [];
  List<Session> filteredSessions = [];
  List<MyUser> students = [];
  List<MyUser> teachers = [];
  List<Discipline> disciplines = [];

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

  Future<void> loadDisciplines() async {
    try {
      final disciplinesRepository = DisciplineRepository();
      final list = await disciplinesRepository.getDisciplinesList();
      setState(() {
        disciplines = list!;
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке преподавателей: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterBySessionType(String type) {
    setState(() {
      selectedSessionsType = type;
      currentScreen = DeanContentScreen.journal;
    });

    final filtered = type == 'Все'
        ? sessions
        : sessions.where((s) => s.type == type).toList();

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
        .where(
            (s) => s.type.toLowerCase() == selectedSessionsType.toLowerCase())
        .fold<Map<int, Session>>({}, (map, session) {
          map[session.id] = session;
          return map;
        })
        .values
        .toList();

    print(
        'Total sessions matching type "$selectedSessionsType": ${actualSessions.length}');
    for (var s in actualSessions) {
      print(' - ${s.type} (${s.date})');
    }

    final conductedHours = actualSessions.length * 2;

    return '$plannedHours ч. запланировано / $conductedHours ч. проведено';
  }

  void _showThemeScreen() {
    setState(() {
      currentScreen = DeanContentScreen.theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JournalBloc(
        journalRepository: JournalRepository(),
        userRepository: UserRepository(),
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          body: Stack(
            children: [
              Row(
                children: [
                  SideNavigationMenu(
                    onSelectType: _filterBySessionType,
                    onProfileTap: () {},
                    onThemeTap: _showThemeScreen,
                    onToggle: () {
                      setState(() {
                        isMenuExpanded = !isMenuExpanded;
                      });
                    },
                    isExpanded: isMenuExpanded,
                    showGroupSelect: showTeacherDisciplineGroupSelect,
                    onGroupSelect: () async {
                      setState(() {
                        showTeacherDisciplineGroupSelect = true;
                        isLoading = true;
                      });
                      loadDisciplines();
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
                          case DeanContentScreen.theme:
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
                                    isEditable: false,
                                  );
                                } else if (state is JournalError) {
                                  return Center(
                                      child: Text('Ошибка: ${state.message}'));
                                } else {
                                  return const SizedBox();
                                }
                              },
                            );
                          case DeanContentScreen.journal:
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
                                      child: Text('Ошибка: ${state.message}'));
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

                                  return Scaffold(
                                    body: Column(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            selectedSessionsType == 'Все'
                                                ? 'Журнал'
                                                : selectedSessionsType,
                                            style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (selectedSessionsType != 'Все') ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
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
                                        SizedBox(
                                          height: 40,
                                        ),
                                        Expanded(
                                          child: JournalTable(
                                            key: tableKey,
                                            students: students,
                                            sessions: sessions,
                                            isEditable: false,
                                            isLoading: false,
                                            onColumnSelected: (int index) {},
                                            onSessionsChanged:
                                                (updatedSessions) {
                                              print(
                                                  'Загружено занятий: $updatedSessions');
                                              sessions = updatedSessions;
                                              _filterBySessionType(
                                                  selectedSessionsType);
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
                  ? MenuArrow(
                      onTap: () {
                        setState(() {
                          isMenuExpanded = !isMenuExpanded;
                        });
                      },
                      top: 40,
                      left: 220,
                    )
                  : SizedBox(),
              if (showTeacherDisciplineGroupSelect)
                GroupSelectDialog(
                  showGroupSelect: true,
                  show: showTeacherDisciplineGroupSelect,
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
                      showTeacherDisciplineGroupSelect = false;
                    });
                  },
                  onSubmit: (groupId) async {
                    setState(() {
                      showTeacherDisciplineGroupSelect = false;
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
      }),
    );
  }
}
