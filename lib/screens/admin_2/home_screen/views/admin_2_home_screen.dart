import 'package:flutter/material.dart';
import 'package:university_journal/bloc/journal/journal_repository.dart';
import '../../../../bloc/journal/group.dart';
import '../../../../bloc/user/user.dart';
import 'package:university_journal/screens/admin_2/home_screen/components/admin_2_side_navigation_menu.dart';
import 'package:university_journal/screens/admin_2/home_screen/views/student_list.dart';
import 'package:university_journal/screens/admin_2/home_screen/views/group_list.dart';

enum Admin2ContentScreen { students, groups }

class Admin2HomeScreen extends StatefulWidget {
  const Admin2HomeScreen({Key? key}) : super(key: key);

  @override
  State<Admin2HomeScreen> createState() => _Admin2HomeScreenState();
}

class _Admin2HomeScreenState extends State<Admin2HomeScreen> {
  final JournalRepository journalRepository = JournalRepository();

  Admin2ContentScreen currentScreen = Admin2ContentScreen.students;

  List<MyUser> students = [];
  List<Group> groups = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
    loadGroups();
  }

  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;
    });
    try {
      final list = await journalRepository.getStudentList();
      setState(() {
        students = list ?? [];
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке студентов: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadGroups() async {
    setState(() {
      isLoading = true;
    });
    try {
      final list = await journalRepository.getGroupsList();
      setState(() {
        groups = list ?? [];
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке групп: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showStudentsList() {
    setState(() {
      currentScreen = Admin2ContentScreen.students;
    });
  }

  void _showGroupsList() {
    setState(() {
      currentScreen = Admin2ContentScreen.groups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Admin2SideNavigationMenu(
            onStudentAdded: () async {
              await loadStudents();
            },
            onGroupAdded: () async {
              await loadGroups();
            },
            onStudentsListTap: _showStudentsList,
            onGroupsListTap: _showGroupsList,
            groups: groups,
            students: students,
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
              builder: (context) {
                switch (currentScreen) {
                  case Admin2ContentScreen.students:
                    return StudentsList(
                      students: students,
                      loadStudents: loadStudents,
                    );
                  case Admin2ContentScreen.groups:
                    return GroupsList(
                      groups: groups,
                      loadGroups: loadGroups,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}