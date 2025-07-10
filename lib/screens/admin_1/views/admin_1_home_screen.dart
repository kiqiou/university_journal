import 'package:flutter/material.dart';
import 'package:university_journal/screens/admin_1/components/admin_1_side_navigation_menu.dart';
import 'package:university_journal/screens/admin_1/views/teacher_list.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/discipline_repository.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/group/group_repository.dart';
import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/widgets/menu_arrow.dart';
import 'disciplines_list.dart';

enum Admin1ContentScreen { teachers, courses }

class Admin1MainScreen extends StatefulWidget {
  const Admin1MainScreen({super.key});

  @override
  State<Admin1MainScreen> createState() => _Admin1MainScreenState();
}

class _Admin1MainScreenState extends State<Admin1MainScreen> {
  final groupRepository = GroupRepository();
  final journalRepository = JournalRepository();
  final userRepository = UserRepository();
  final disciplineRepository = DisciplineRepository();
  Admin1ContentScreen currentScreen = Admin1ContentScreen.teachers;
  List<MyUser> teachers = [];
  List<Discipline> disciplines = [];
  List<Group> groups = [];
  bool isLoading = true;
  bool isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    loadTeachers();
    loadDisciplines();
    loadGroups();
  }

  void _showTeachersList() {
    setState(() {
      currentScreen = Admin1ContentScreen.teachers;
    });
  }

  void _showCoursesList() {
    setState(() {
      currentScreen = Admin1ContentScreen.courses;
    });
  }

  Future<void> loadGroups() async {
    try {
      final list = await groupRepository.getGroupsList();
      setState(() {
        groups = list!;
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке групп: $e");
      isLoading = false;
    }
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
      final list = await disciplineRepository.getDisciplinesList();
      setState(() {
        disciplines = list!..sort((a, b) => a.name.compareTo(b.name));
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке преподавателей: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Admin1SideNavigationMenu(
                onTeacherAdded: () async {
                  await loadTeachers();
                },
                onCourseAdded: () async {
                  await loadDisciplines();
                },
                onTeacherListTap: _showTeachersList,
                onCoursesListTap: _showCoursesList,
                groups: groups,
                teachers: teachers,
                isExpanded: isMenuExpanded,
                onToggle: () {
                  setState(() {
                    isMenuExpanded = !isMenuExpanded;
                  });
                },
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    switch (currentScreen) {
                      case Admin1ContentScreen.teachers:
                        return TeachersList(
                          loadTeachers: loadTeachers,
                          teachers: teachers,
                          disciplines: disciplines,
                          loadDisciplines: loadDisciplines,
                        );
                      case Admin1ContentScreen.courses:
                        return CoursesList(
                          loadCourses: loadDisciplines,
                          disciplines: disciplines,
                          groups: groups,
                          teachers: teachers,
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
                  left: 270,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
