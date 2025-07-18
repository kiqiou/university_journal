import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:university_journal/components/widgets/menu_arrow.dart';
import 'package:university_journal/shared/theme_table/theme_screen.dart';

import '../../../../bloc/auth/authentication_bloc.dart';
import '../../../bloc/services/discipline/models/discipline_plan.dart';
import '../../../components/constants/constants.dart';
import '../../../components/widgets/side_navigation_menu.dart';
import '../../../shared/journal/widgets/journal_table.dart';
import '../../../bloc/journal/journal_bloc.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/widgets/discipline_and_group_select.dart';
import '../../../shared/journal/journal_screen.dart';
import '../../../shared/utils/session_utils.dart';
import 'account_screen.dart';
import '../components/add_session_dialog.dart';
import '../../../shared/theme_table/theme_table.dart';

enum TeacherContentScreen { journal, account, theme }

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  final _formKey = GlobalKey<FormState>();
  final userRepository = UserRepository();
  TeacherContentScreen currentScreen = TeacherContentScreen.journal;
  DateTime? _selectedDate;
  String? _selectedEventType;
  String? token;
  bool isLoading = true;
  bool isMenuExpanded = false;
  bool showDisciplineAndGroupSelect = false;
  late bool isGroupSplit;
  int? selectedDisciplineIndex;
  int? selectedGroupId;
  int? pendingGroupId;
  int? _selectedSubgroup;
  int? selectedColumnIndexGeneral;
  int? selectedColumnIndexFirstSubgroup;
  int? selectedColumnIndexSecondSubgroup;
  String selectedSessionsType = 'Все';
  List<Session> sessions = [];
  List<Session> filteredSessions = [];
  List<MyUser> students = [];
  List<Discipline> disciplines = [];
  late Map<String, List<Session>> groupedSessions;

  @override
  void initState() {
    super.initState();
    groupSessions();
    getAccessToken();
  }

  void groupSessions() {
    groupedSessions = {
      'Все': sessions,
      for (final type in {'Лекция', 'Семинар', 'Практика', 'Лабораторная'})
        type: sessions.where((s) => s.type == type).toList(),
    };
    filteredSessions = groupedSessions['Все']!;
  }

  void getAccessToken() {
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
    final newFilteredSessions = groupedSessions[type] ?? [];

    setState(() {
      selectedSessionsType = type;
      currentScreen = TeacherContentScreen.journal;
      filteredSessions = newFilteredSessions;
    });

    tableKey.currentState?.updateDataSource(newFilteredSessions, students);
  }

  // String _buildSessionStatsText() {
  //   if (selectedSessionsType == 'Все') return '';
  //
  //   final currentDiscipline = disciplines[selectedDisciplineIndex!];
  //
  //   return SessionUtils().buildSessionStatsText(
  //     selectedType: selectedSessionsType,
  //     discipline: currentDiscipline,
  //     sessions: filteredSessions,
  //   );
  // }

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
                              return ThemeScreen(
                                isEditable: true,
                                onUpdate: (sessionId, topic) async {
                                  final success = context
                                      .read<JournalBloc>()
                                      .add(UpdateSession(
                                          groupId: selectedGroupId!,
                                          disciplineId: disciplines[
                                                  selectedDisciplineIndex!]
                                              .id,
                                          sessionId: sessionId,
                                          topic: topic));
                                  return success;
                                },
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
                                isGroupSplit: isGroupSplit,
                              );

                            case TeacherContentScreen.journal:
                              return selectedGroupId != null
                                  ? JournalScreen(
                                      selectedGroupId: selectedGroupId,
                                      selectedSessionsType:
                                          selectedSessionsType,
                                      selectedDisciplineIndex:
                                          selectedDisciplineIndex,
                                      disciplines: disciplines,
                                      token: token,
                                      tableKey: tableKey,
                                      selectedColumnIndex: isGroupSplit
                                          ? null
                                          : selectedColumnIndexGeneral,
                                      selectedColumnIndexFirst: isGroupSplit
                                          ? selectedColumnIndexFirstSubgroup
                                          : null,
                                      selectedColumnIndexSecond: isGroupSplit
                                          ? selectedColumnIndexSecondSubgroup
                                          : null,
                                      onColumnSelected: isGroupSplit
                                          ? null
                                          : (index) {
                                              setState(() {
                                                selectedColumnIndexGeneral =
                                                    index;
                                              });
                                            },
                                      onColumnSelectedFirst: isGroupSplit
                                          ? (index) {
                                              setState(() {
                                                selectedColumnIndexFirstSubgroup =
                                                    index;
                                                selectedColumnIndexSecondSubgroup =
                                                    null;
                                              });
                                            }
                                          : null,
                                      onColumnSelectedSecond: isGroupSplit
                                          ? (index) {
                                              setState(() {
                                                selectedColumnIndexSecondSubgroup =
                                                    index;
                                                selectedColumnIndexFirstSubgroup =
                                                    null;
                                              });
                                            }
                                          : null,
                                      onDeleteSession: (session) {
                                        context
                                            .read<JournalBloc>()
                                            .add(DeleteSession(
                                              sessionId: session.id,
                                              disciplineId: disciplines[
                                                      selectedDisciplineIndex!]
                                                  .id,
                                              groupId: selectedGroupId!,
                                            ));
                                        setState(() {
                                          selectedColumnIndexGeneral = null;
                                          selectedColumnIndexFirstSubgroup =
                                              null;
                                          selectedColumnIndexSecondSubgroup =
                                              null;
                                        });
                                      },
                                      onEditSession: (session) {
                                        showAddEventDialog(
                                          dateToEdit: DateFormat('dd.MM.yyyy')
                                              .parse(session.date),
                                          typeToEdit: session.type,
                                          subGroupToEdit: session.subGroup,
                                          context: context,
                                          isEditing: true,
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
                                          onSubgroupSelected: (subGroupId) {
                                            setState(() {
                                              _selectedSubgroup = subGroupId;
                                            });
                                          },
                                          onSavePressed: () {
                                            context.read<JournalBloc>().add(
                                                  UpdateSession(
                                                    disciplineId: disciplines[
                                                            selectedDisciplineIndex!]
                                                        .id,
                                                    groupId: selectedGroupId!,
                                                    sessionId: session.id,
                                                    date: _selectedDate != null
                                                        ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                                                        : null,
                                                    type: _selectedEventType,
                                                    subGroup: _selectedSubgroup,
                                                  ),
                                                );
                                            setState(() {
                                              selectedColumnIndexGeneral = null;
                                              selectedColumnIndexFirstSubgroup =
                                                  null;
                                              selectedColumnIndexSecondSubgroup =
                                                  null;
                                            });
                                          },
                                          isGroupSplit: disciplines[
                                                  selectedDisciplineIndex!]
                                              .isGroupSplit,
                                        );
                                      },
                                      onAddSession: () => showAddEventDialog(
                                        context: context,
                                        isEditing: false,
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
                                        onSubgroupSelected: (subgroup) {
                                          setState(() {
                                            _selectedSubgroup = subgroup;
                                          });
                                        },
                                        onSavePressed: () {
                                          if (_selectedDate != null &&
                                              _selectedEventType != null) {
                                            String formattedDate =
                                                "${_selectedDate?.year}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.day.toString().padLeft(2, '0')}";
                                            context.read<JournalBloc>().add(
                                                  AddSession(
                                                    disciplineId: disciplines[
                                                            selectedDisciplineIndex!]
                                                        .id,
                                                    groupId: selectedGroupId!,
                                                    date: formattedDate,
                                                    type: _selectedEventType!,
                                                    subgroupId:
                                                        _selectedSubgroup,
                                                  ),
                                                );
                                          }
                                        },
                                        isGroupSplit: disciplines[
                                                selectedDisciplineIndex!]
                                            .isGroupSplit,
                                      ),
                                      buildSessionStatsText:
                                          _buildSessionStatsText,
                                      isEditable: true,
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
                if (showDisciplineAndGroupSelect)
                  GroupSelectDialog(
                    showTeacherSelect: false,
                    showGroupSelect: true,
                    show: showDisciplineAndGroupSelect,
                    disciplines: disciplines,
                    selectedDisciplineIndex: selectedDisciplineIndex,
                    selectedGroupId: pendingGroupId,
                    formKey: _formKey,
                    onDisciplineChanged: (value) {
                      setState(() {
                        selectedGroupId = null;
                        pendingGroupId = null;
                        selectedDisciplineIndex = value;
                      });
                    },
                    onGroupChanged: (value) {
                      setState(() {
                        pendingGroupId = value;
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
                        selectedGroupId = pendingGroupId;
                        isGroupSplit =
                            disciplines[selectedDisciplineIndex!].isGroupSplit;
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
        },
      ),
    );
  }
}
