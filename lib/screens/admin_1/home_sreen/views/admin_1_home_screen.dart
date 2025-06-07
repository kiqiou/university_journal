import 'package:flutter/material.dart';
import 'package:university_journal/bloc/discipline/discipline_repository.dart';
import 'package:university_journal/bloc/journal/journal_repository.dart';
import 'package:university_journal/screens/admin_1/home_sreen/components/admin_1_side_navigation_menu.dart';
import 'package:university_journal/screens/admin_1/home_sreen/views/teacher_list.dart';

import '../../../../bloc/discipline/discipline.dart';
import '../../../../bloc/group/group.dart';
import '../../../../bloc/group/group_repository.dart';
import '../../../../bloc/user/user.dart';
import '../../../../bloc/user/user_repository.dart';
import 'disciplines_list.dart';

enum Admin1ContentScreen { teachers, courses }

class Admin1HomeScreen extends StatefulWidget {
  const Admin1HomeScreen({super.key});

  @override
  State<Admin1HomeScreen> createState() => _Admin1HomeScreenState();
}

class _Admin1HomeScreenState extends State<Admin1HomeScreen> {
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
        teachers = list!;
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
      final list = await disciplineRepository.getCoursesList();
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
                        return TeachersList(loadTeachers: loadTeachers, teachers: teachers, disciplines: disciplines, loadDisciplines: loadDisciplines,);
                      case Admin1ContentScreen.courses:
                        return CoursesList(loadCourses: loadDisciplines, disciplines: disciplines, groups: groups, teachers: teachers,);
                    }
                  },
                ),
              ),
            ],
          ),
          isMenuExpanded ?
          Positioned(
            top: 40,
            left: 270,
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
          ) : SizedBox(),
        ],
      ),
    );
  }
}
