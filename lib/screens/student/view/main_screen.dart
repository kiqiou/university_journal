import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/components/widgets/menu_arrow.dart';

import '../../../bloc/auth/authentication_bloc.dart';
import '../../../bloc/journal/journal_bloc.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/models/discipline_plan.dart';
import '../../../bloc/services/discipline/discipline_repository.dart';
import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/constants/constants.dart';
import '../../../components/journal_table.dart';
import '../../../components/side_navigation_menu.dart';
import '../../../components/theme_table.dart';
import '../../../components/widgets/discipline_and_group_select.dart';
import '../../../utils/session_utils.dart';

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
  List<Session> filteredSessions = [];
  List<MyUser> students = [];
  List<MyUser> teachers = [];
  List<Discipline> disciplines = [];
  late Map<String, List<Session>> groupedSessions;

  Future<Map<String, dynamic>>? journalDataFuture;

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

    final students =
        await userRepository.getStudentsByGroupList(selectedGroupId!);
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
    final newFilteredSessions = groupedSessions[type] ?? [];

    setState(() {
      selectedSessionsType = type;
      currentScreen = StudentContentScreen.journal;
      filteredSessions = newFilteredSessions;
    });

    tableKey.currentState?.updateDataSource(newFilteredSessions, students);
  }

  String _buildSessionStatsText() {
    if (selectedSessionsType == 'Все') return '';

    final currentDiscipline = disciplines[selectedDisciplineIndex!];

    return SessionUtils().buildSessionStatsText(
      selectedType: selectedSessionsType,
      discipline: currentDiscipline,
      sessions: sessions,
      lessonTypeOptions: lessonTypeOptions,
    );
  }

  void _showThemeScreen() {
    setState(() {
      currentScreen = StudentContentScreen.theme;
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
                          case StudentContentScreen.journal:
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
                      left: 220)
                  : SizedBox(),
              if (showDisciplineSelect)
                GroupSelectDialog(
                  showGroupSelect: false,
                  show: showDisciplineSelect,
                  disciplines: disciplines,
                  selectedDisciplineIndex: selectedDisciplineIndex,
                  selectedGroupId: selectedGroupId,
                  formKey: _formKey,
                  onDisciplineChanged: (value) {
                    setState(() {
                      selectedDisciplineIndex = value;
                    });
                  },
                  onClose: () {
                    setState(() {
                      showDisciplineSelect = false;
                      selectedGroupId = null;
                    });
                  },
                  onSubmit: (groupId) async {
                    setState(() {
                      showDisciplineSelect = false;
                      isLoading = true;
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
