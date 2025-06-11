import 'package:flutter/material.dart';
import 'package:university_journal/bloc/group/group_repository.dart';
import '../../../../bloc/group/group.dart';
import '../../../../bloc/user/user.dart';
import 'package:university_journal/screens/admin_2/home_screen/components/admin_2_side_navigation_menu.dart';
import 'package:university_journal/screens/admin_2/home_screen/views/student_list.dart';
import 'package:university_journal/screens/admin_2/home_screen/views/group_list.dart';

import '../../../../bloc/user/user_repository.dart';

enum Admin2ContentScreen { students, groups }

class Admin2HomeScreen extends StatefulWidget {
  const Admin2HomeScreen({super.key});

  @override
  State<Admin2HomeScreen> createState() => _Admin2HomeScreenState();
}

class _Admin2HomeScreenState extends State<Admin2HomeScreen> {
  final userRepository = UserRepository();
  final groupRepository = GroupRepository();
  Admin2ContentScreen currentScreen = Admin2ContentScreen.students;
  List<MyUser> students = [];
  List<Group> groups = [];
  bool isLoading = true;
  bool isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    loadStudents();
    loadGroups();
  }

  Future<void> loadStudents() async {
    try {
      final list = await userRepository.getStudentList();
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
      body: Stack(
        children: [
          Row(
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
                      case Admin2ContentScreen.students:
                        return StudentsList(students: students, loadStudents: loadStudents, groups: groups,);
                      case Admin2ContentScreen.groups:
                        return GroupsList(groups: groups, loadGroups: loadGroups, students: students,);
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
