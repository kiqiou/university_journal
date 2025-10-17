import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/menu_arrow.dart';
import 'package:university_journal/screens/admin_2/components/admin_2_side_navigation_menu.dart';
import 'package:university_journal/screens/admin_2/views/student_list.dart';
import 'package:university_journal/screens/admin_2/views/group_list.dart';

import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/group/group_repository.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';

enum Admin2ContentScreen { groups }

class Admin2MainScreen extends StatefulWidget {
  const Admin2MainScreen({super.key});

  @override
  State<Admin2MainScreen> createState() => _Admin2MainScreenState();
}

class _Admin2MainScreenState extends State<Admin2MainScreen> {
  final userRepository = UserRepository();
  final groupRepository = GroupRepository();
  Admin2ContentScreen currentScreen = Admin2ContentScreen.groups;
  List<MyUser> students = [];
  List<Group> groups = [];
  bool isLoading = true;
  bool isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadGroups({
    Set<String>? faculties,
    Set<int>? courses,
  }) async {
    try {
      final list = await groupRepository.getGroupsList(
        faculties?.toList(),
        courses?.toList(),
      );
      setState(() {
        groups = list ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке групп: $e");
      setState(() => isLoading = false);
    }
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
                  await loadGroups();
                },
                onGroupAdded: () async {
                  await loadGroups();
                },
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
                      case Admin2ContentScreen.groups:
                        return GroupsExpandableList(
                          groups: groups,
                          loadGroups: loadGroups,
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
