import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/journal/journal_bloc.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/discipline_repository.dart';
import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/constants/constants.dart';
import '../../../components/widgets/side_navigation_menu.dart';
import '../../../shared/journal/widgets/journal_table.dart';
import '../../../shared/theme_table/theme_table.dart';
import '../../../components/widgets/discipline_and_group_select.dart';
import '../../../components/widgets/menu_arrow.dart';
import '../../../shared/journal/journal_screen.dart';
import '../../../shared/utils/session_utils.dart';

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
  int? pendingSelectedGroupId;
  String selectedSessionsType = 'Все';
  List<Session> sessions = [];
  List<Session> filteredSessions = [];
  late Map<String, List<Session>> groupedSessions;
  List<MyUser> students = [];
  List<MyUser> teachers = [];
  List<Discipline> disciplines = [];

  @override
  void initState() {
    super.initState();
    groupSessions();
  }

  void groupSessions() {
    groupedSessions = {
      'Все': sessions,
      for (final type in {'Лекция', 'Семинар', 'Практика', 'Лабораторная'})
        type: sessions.where((s) => s.type == type).toList(),
    };
    filteredSessions = groupedSessions['Все']!;
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

    return SessionUtils().buildSessionStatsText(
      selectedType: selectedSessionsType,
      discipline: currentDiscipline,
      sessions: sessions,
    );
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
                            return selectedGroupId != null
                                ? JournalScreen(
                              selectedGroupId: selectedGroupId,
                              selectedSessionsType: selectedSessionsType,
                              selectedDisciplineIndex: selectedDisciplineIndex,
                              disciplines: disciplines,
                              tableKey: tableKey,
                              buildSessionStatsText:
                              _buildSessionStatsText,
                              isEditable: false,
                            )
                                : Center(
                              child:
                              Text('Выберите дисциплину и группу'),
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
                  selectedGroupId: pendingSelectedGroupId,
                  formKey: _formKey,
                  onDisciplineChanged: (value) {
                    setState(() {
                      selectedDisciplineIndex = value;
                      selectedGroupId = null;
                    });
                  },
                  onGroupChanged: (value) {
                    setState(() {
                      pendingSelectedGroupId = value;
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
                      selectedGroupId = pendingSelectedGroupId;
                    });

                    context.read<JournalBloc>().add(
                          LoadSessions(
                            disciplineId:
                                disciplines[selectedDisciplineIndex!].id,
                            groupId: selectedGroupId!,
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
