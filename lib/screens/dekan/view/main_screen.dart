import 'package:flutter/material.dart';

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
  bool showGroupSelect = false;
  int? selectedDisciplineIndex;
  int? selectedGroupId;
  String selectedSessionsType = 'Все';
  List<Session> sessions = [];
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
      currentScreen = DeanContentScreen.theme;
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
                showGroupSelect: showGroupSelect,
                onGroupSelect: () async {
                  setState(() {
                    showGroupSelect = true;
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
                      case DeanContentScreen.journal:
                        return selectedGroupId != null
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
                                            isEditable: false,
                                            isLoading: false,
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
                            : Center(child: Text('Выберите группу'));
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
            GroupSelectDialog(
              show: showGroupSelect,
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
                  showGroupSelect = false;
                });
              },
              onSubmit: (groupId) async {
                setState(() {
                  showGroupSelect = false;
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
              }, showGroupSelect: true,
            ),
        ],
      ),
    );
  }
}
