import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/shared/theme_table/theme_screen.dart';

import '../../../bloc/attestation/attestation_bloc.dart';
import '../../../bloc/journal/journal_bloc.dart';
import '../../../bloc/services/attestation/attestation_repository.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/discipline_repository.dart';
import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/widgets/side_navigation_menu.dart';
import '../../../shared/attestation/attestation_screen.dart';
import '../../../shared/journal/widgets/journal_table.dart';
import '../../../components/widgets/discipline_and_group_select.dart';
import '../../../components/widgets/menu_arrow.dart';
import '../../../shared/journal/journal_screen.dart';
import '../../../shared/utils/session_utils.dart';

enum DeanContentScreen { journal, theme, attestation }

class DeanMainScreen extends StatefulWidget {
  const DeanMainScreen({super.key});

  @override
  State<DeanMainScreen> createState() => _DeanMainScreenState();
}

class _DeanMainScreenState extends State<DeanMainScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  DeanContentScreen currentScreen = DeanContentScreen.journal;
  final _formKey = GlobalKey<FormState>();
  final userRepository = UserRepository();
  Future<Map<String, dynamic>>? journalDataFuture;
  late Map<String, List<Session>> groupedSessions;
  List<Session> filteredSessions = [];
  List<Session> sessions = [];
  List<Discipline> disciplines = [];
  List<MyUser> students = [];
  List<MyUser> teachers = [];
  bool isLoading = true;
  bool isMenuExpanded = false;
  bool showTeacherDisciplineGroupSelect = false;
  int? selectedDisciplineIndex;
  int? selectedTeacherIndex;
  int? pendingTeacherIndex;
  int? selectedGroupId;
  int? pendingSelectedGroupId;
  String selectedSessionsType = 'Все';
  late bool isGroupSplit;

  @override
  void initState() {
    super.initState();
    loadTeachers();
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

  Future<void> loadTeachers() async {
    try {
      final list = await userRepository.getTeacherList();
      setState(() {
        teachers = list!..sort((a, b) => a.username.compareTo(b.username));
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке преподавателей: $e");
      setState(() {
        isLoading = false;
      });
    }
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

  void _showThemeScreen() {
    setState(() {
      currentScreen = DeanContentScreen.theme;
    });
  }

  void _showAttestationScreen() {
    setState(() {
      currentScreen = DeanContentScreen.attestation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => JournalBloc(
            journalRepository: JournalRepository(),
            userRepository: UserRepository(),
          ),
        ),
        BlocProvider(
          create: (_) => AttestationBloc(repository: USRRepository()),
        ),
      ],
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
                    onAttestationTap: _showAttestationScreen,
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
                            return selectedGroupId != null
                                ? ThemeScreen(
                                    isEditable: false,
                                    isGroupSplit: isGroupSplit)
                                : Center(
                                    child: Text('Выберите дисциплину и группу'),
                                  );
                          case DeanContentScreen.journal:
                            return selectedGroupId != null
                                ? JournalScreen(
                                    selectedGroupId: selectedGroupId,
                                    selectedSessionsType: selectedSessionsType,
                                    selectedDisciplineIndex:
                                        selectedDisciplineIndex,
                                    disciplines: disciplines,
                                    tableKey: tableKey,
                                    isEditable: false,
                                  )
                                : Center(
                                    child: Text('Выберите дисциплину и группу'),
                                  );
                          case DeanContentScreen.attestation:
                            return selectedGroupId != null
                                ? AttestationScreen(
                                    isEditable: false,
                                    attestationType:
                                        disciplines[selectedDisciplineIndex!]
                                            .attestationType,
                                  )
                                : Center(
                                    child: Text('Выберите дисциплину и группу'),
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
                  showTeacherSelect: true,
                  showGroupSelect: true,
                  show: showTeacherDisciplineGroupSelect,
                  disciplines: disciplines,
                  teachers: teachers,
                  selectedTeacherIndex: pendingTeacherIndex,
                  selectedDisciplineIndex: selectedDisciplineIndex,
                  selectedGroupId: pendingSelectedGroupId,
                  formKey: _formKey,
                  onTeacherChanged: (value) {
                    setState(() {
                      selectedDisciplineIndex = null;
                      selectedGroupId = null;
                      pendingTeacherIndex = value;
                    });
                  },
                  onDisciplineChanged: (value) {
                    setState(() {
                      selectedGroupId = null;
                      selectedDisciplineIndex = value;
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
                      isGroupSplit =
                          disciplines[selectedDisciplineIndex!].isGroupSplit;
                      selectedTeacherIndex = pendingTeacherIndex;
                    });

                    context.read<JournalBloc>().add(
                          LoadSessions(
                            disciplineId:
                                disciplines[selectedDisciplineIndex!].id,
                            groupId: selectedGroupId!,
                          ),
                        );

                    context.read<AttestationBloc>().add(
                          LoadAttestations(
                              groupId: selectedGroupId!,
                              disciplineId:
                                  disciplines[selectedDisciplineIndex!].id),
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
