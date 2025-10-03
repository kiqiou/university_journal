import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/components/widgets/menu_arrow.dart';
import 'package:university_journal/shared/theme_table/theme_screen.dart';

import '../../../bloc/attestation/attestation_bloc.dart';
import '../../../bloc/auth/authentication_bloc.dart';
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
import '../../../shared/journal/journal_screen.dart';
import '../../../shared/utils/session_utils.dart';

enum StudentContentScreen { journal, theme, attestation }

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
  late bool isGroupSplit;
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
    groupSessions();
    getUserInfo();
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

  void getUserInfo() {
    final authState = context.read<AuthenticationBloc>().state;
    isHeadman = authState.user!.isHeadman;
    selectedGroupId = authState.user!.groupId;
  }

  void getAccessToken() {
    final userRepository = UserRepository();
    userRepository.getAccessToken().then((value) {
      setState(() {
        token = value;
      });
    });
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

  void _showThemeScreen() {
    setState(() {
      currentScreen = StudentContentScreen.theme;
    });
  }

  void _showAttestationScreen() {
    setState(() {
      currentScreen = StudentContentScreen.attestation;
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
                    child: Builder(builder: (context) {
                      switch (currentScreen) {
                        case StudentContentScreen.theme:
                          return ThemeScreen(
                              isEditable: false, isGroupSplit: isGroupSplit);
                        case StudentContentScreen.journal:
                          return selectedDisciplineIndex != null
                              ? JournalScreen(
                                  selectedGroupId: selectedGroupId,
                                  selectedSessionsType: selectedSessionsType,
                                  selectedDisciplineIndex:
                                      selectedDisciplineIndex,
                                  disciplines: disciplines,
                                  token: token,
                                  tableKey: tableKey,
                                  isEditable: false,
                                  isHeadman: isHeadman,
                                )
                              : Center(
                                  child: Text('Выберите дисциплину и группу'),
                                );
                        case StudentContentScreen.attestation:
                          return AttestationScreen(
                            isEditable: false,
                            attestationType:
                                disciplines[selectedDisciplineIndex!]
                                    .attestationType,
                          );
                      }
                    }),
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
                  showTeacherSelect: false,
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
                      isGroupSplit =
                          disciplines[selectedDisciplineIndex!].isGroupSplit;
                    });

                    context.read<JournalBloc>().add(
                          LoadSessions(
                            disciplineId:
                                disciplines[selectedDisciplineIndex!].id,
                            groupId: groupId,
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
