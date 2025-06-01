import 'package:flutter/material.dart';
import 'package:university_journal/bloc/journal/journal_repository.dart';
import 'package:university_journal/screens/admin_1/home_sreen/components/admin_1_side_navigation_menu.dart';
import 'package:university_journal/screens/admin_1/home_sreen/views/teacher_list.dart';

import '../../../../bloc/journal/course.dart';
import '../../../../bloc/journal/group.dart';
import '../../../../bloc/user/user.dart';
import 'course_list.dart';

enum Admin1ContentScreen { teachers, courses }

class Admin1HomeScreen extends StatefulWidget {
  const Admin1HomeScreen({super.key});

  @override
  State<Admin1HomeScreen> createState() => _Admin1HomeScreenState();
}

class _Admin1HomeScreenState extends State<Admin1HomeScreen> {
  final journalRepository = JournalRepository();
  Admin1ContentScreen currentScreen = Admin1ContentScreen.teachers;
  List<MyUser> teachers = [];
  List<Course> courses = [];
  List<Group> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeachers();
    loadCourses();
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
      final list = await journalRepository.getGroupsList();
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
      final list = await journalRepository.getTeacherList();
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

  Future<void> loadCourses() async {
    try {
      final list = await journalRepository.getCoursesList();
      setState(() {
        courses = list!;
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
      body: Row(
        children: [
          Admin1SideNavigationMenu(
            onTeacherAdded: () async {
              await loadTeachers();
            },
            onCourseAdded: () async {
              await loadCourses();
            },
            onTeacherListTap: _showTeachersList,
            onCoursesListTap: _showCoursesList,
            groups: groups,
            teachers: teachers,
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                switch (currentScreen) {
                  case Admin1ContentScreen.teachers:
                    return TeachersList(loadTeachers: loadTeachers, teachers: teachers,);
                  case Admin1ContentScreen.courses:
                    return CoursesList(loadCourses: loadCourses, courses: courses, groups: groups, teachers: teachers,);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
