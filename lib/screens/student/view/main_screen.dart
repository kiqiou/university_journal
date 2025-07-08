import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth/authentication_bloc.dart';
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

enum StudentContentScreen { journal, theme }

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  final _formKey = GlobalKey<FormState>();
  StudentContentScreen currentScreen = StudentContentScreen.journal;

  bool? isHeadman;
  bool isLoading = true;
  bool isMenuExpanded = false;
  bool showDisciplineSelect = false;
  String? token;
  int? selectedDisciplineIndex;
  int? selectedGroupId;
  String selectedSessionsType = 'Все';
  List<Session> sessions = [];
  List<MyUser> students = [];
  List<MyUser> teachers = [];
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
    final authState = context.read<AuthenticationBloc>().state;
    isHeadman = authState.user!.isHeadman;
    selectedGroupId = authState.user!.groupId;

    final userRepository = UserRepository();
    userRepository.getAccessToken().then((value) {
      setState(() {
        token = value;
      });
    });
  }


  Future<Map<String, dynamic>> loadJournalData() async {
    final userRepository = UserRepository();
    final journalRepository = JournalRepository();
    print('$selectedGroupId');

    final students = await userRepository.getStudentsByGroupList(selectedGroupId!);
    final sessions = await journalRepository.journalData(
      disciplineId: disciplines[selectedDisciplineIndex!].id,
      groupId: selectedGroupId!,
    );

    return {
      'students': students ?? [],
      'sessions': sessions,
    };
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
      currentScreen = StudentContentScreen.journal;
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

  void _showThemeScreen() {
    setState(() {
      currentScreen = StudentContentScreen.theme;
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
                onProfileTap: () {},
                onThemeTap: _showThemeScreen,
                onToggle: () {
                  setState(() {
                    isMenuExpanded = !isMenuExpanded;
                  });
                },
                isExpanded: isMenuExpanded,
                showGroupSelect: showDisciplineSelect,
                onGroupSelect: () async {
                  setState(() {
                    showDisciplineSelect = true;
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
                      case StudentContentScreen.theme:
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
                          isEditable: false,
                        );
                      case StudentContentScreen.journal:
                        return selectedDisciplineIndex != null
                            ? Scaffold(
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
                                    FutureBuilder<Map<String, dynamic>>(
                                      future: journalDataFuture,
                                      builder: (context, snapshot) {
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
                                            isEditable: false,
                                            isLoading: false,
                                            token: token,
                                            isHeadman: isHeadman,
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
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : Center(child: Text('Выберите дисциплину'));
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
          if (showDisciplineSelect)
            GroupSelectDialog(
              show: showDisciplineSelect,
              disciplines: disciplines,
              selectedDisciplineIndex: selectedDisciplineIndex,
              selectedGroupId: selectedGroupId,
              showGroupSelect: false,
              formKey: _formKey,
              onDisciplineChanged: (value) {
                setState(() {
                  selectedDisciplineIndex = value;
                });
              },
              onClose: () {
                setState(() {
                  showDisciplineSelect = false;
                });
              },
              onSubmit: (groupId) async {
                setState(() {
                  showDisciplineSelect = false;
                  isLoading = true;
                  context.read<JournalBloc>().add(LoadSessions(
                    disciplineId: disciplines[selectedDisciplineIndex!].id,
                    groupId: selectedGroupId!,));
                });
              },
            ),
        ],
      ),
    );
  }
}
