import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:university_journal/bloc/discipline/discipline_repository.dart';

import '../../../bloc/discipline/discipline.dart';
import '../../../bloc/journal/journal.dart';
import '../../../bloc/journal/journal_repository.dart';
import '../../../bloc/user/user.dart';
import '../../../bloc/user/user_repository.dart';
import '../../../components/journal_table.dart';
import '../../teacher/home_screen/components/side_navigation_menu.dart';
import '../../../components/theme_table.dart';

enum DekanContentScreen { journal, theme }

class DekanHomeScreen extends StatefulWidget {
  const DekanHomeScreen({super.key});

  @override
  State<DekanHomeScreen> createState() => _DekanHomeScreenState();
}

class _DekanHomeScreenState extends State<DekanHomeScreen> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  final _formKey = GlobalKey<FormState>();
  DekanContentScreen currentScreen = DekanContentScreen.journal;

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

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadSessions() async {
    log("Загрузка данных сессий...");
    final journalRepository = JournalRepository();
    final list = await journalRepository.journalData(
      courseId: disciplines[selectedDisciplineIndex!].id,
      groupId: selectedGroupId!,
    );
    setState(() {
      sessions = list;
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tableKey.currentState?.updateDataSource(sessions);
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadStudents(groupId) async {
    try {
      final userRepository = UserRepository();
      final list = await userRepository.getStudentsByGroupList(groupId);
      setState(() {
        students = list!;
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
      final list = await disciplinesRepository.getCoursesList();
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
      currentScreen = DekanContentScreen.journal;
    });

    final filtered = type == 'Все' ? sessions : sessions.where((s) => s.sessionType == type).toList();

    tableKey.currentState?.updateDataSource(filtered);
  }

  void _showThemeScreen() {
    setState(() {
      currentScreen = DekanContentScreen.theme;
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
                      case DekanContentScreen.theme:
                        return ThemeTable(
                          sessions: sessions,
                          onUpdate: (sessionId, date, type, topic) async {
                            final repository = JournalRepository();
                            final success = await repository.updateSession(
                              sessionId: sessionId,
                              date: date,
                              type: type,
                              topic: topic,
                            );

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Не удалось обновить данные')),
                              );
                            }
                            return success;
                          }, isEditable: false,
                        );
                      case DekanContentScreen.journal:
                        return selectedGroupId != null
                            ? Column(
                                children: [
                                  Expanded(
                                    child: JournalTable(
                                      key: tableKey,
                                      isLoading: isLoading,
                                      sessions: sessions,
                                      onSessionsChanged: (updatedSessions) {
                                        setState(() {
                                          sessions = updatedSessions;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Text('Выберите группу');
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
                        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
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
            Positioned(
              top: 32,
              right: 32,
              child: Builder(
                builder: (context) {
                  final media = MediaQuery.of(context).size;
                  final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
                  (media.height - 64).clamp(480, 1100);
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;

                  if (screenWidth < 500 || screenHeight < 500) return const SizedBox.shrink();

                  return Material(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 60),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: dialogWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Заголовок и кнопка закрытия ---
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Выберите дисциплину и группу',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 28, color: Colors.black54),
                                        splashRadius: 24,
                                        onPressed: () {
                                          setState(() {
                                            showGroupSelect = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  // --- Форма ---
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Название группы
                                        const Text(
                                          'Выберите дисциплину*',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        DropdownButtonFormField<int>(
                                          value: selectedDisciplineIndex,
                                          decoration: _inputDecoration('Выберите курс'),
                                          items: List.generate(disciplines.length, (index) {
                                            return DropdownMenuItem<int>(
                                              value: index,
                                              child: Text(
                                                disciplines[index].name,
                                                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                                              ),
                                            );
                                          }),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedDisciplineIndex = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Выберите дисциплину';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        if (selectedDisciplineIndex != null)
                                          DropdownButtonFormField<int>(
                                            decoration: _inputDecoration('Выберите группу'),
                                            items: disciplines[selectedDisciplineIndex!].groups.map((group) {
                                              return DropdownMenuItem<int>(
                                                value: group.id,
                                                child: Text(group.name),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedGroupId = value;
                                              });
                                              print('Выбрана группа с ID: $value');
                                            },
                                            validator: (value) {
                                              if (value == null) return 'Выберите группу';
                                              return null;
                                            },
                                          ),
                                        const SizedBox(height: 18),
                                        ElevatedButton(
                                          onPressed: () async {
                                            showGroupSelect = false;
                                            loadSessions();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF4068EA),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                            minimumSize: const Size.fromHeight(55),
                                          ),
                                          child: const Text('Сохранить', style: TextStyle(fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
    );
  }
}
