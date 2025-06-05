import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/components/icon_container.dart';
import '../../../../bloc/journal/group.dart';
import '../../../../bloc/user/user.dart';
import 'add_student.dart';
import 'add_group.dart';

class Admin2SideNavigationMenu extends StatefulWidget {
  final Future<void> Function() onStudentAdded;
  final Future<void> Function() onGroupAdded;
  final VoidCallback onStudentsListTap;
  final VoidCallback onGroupsListTap;
  final List<Group> groups;
  final List<MyUser> students;

  const Admin2SideNavigationMenu({
    super.key,
    required this.onStudentAdded,
    required this.onGroupAdded,
    required this.onStudentsListTap,
    required this.onGroupsListTap,
    required this.groups,
    required this.students,
  });

  @override
  State<Admin2SideNavigationMenu> createState() => _Admin2SideNavigationMenuState();
}

class _Admin2SideNavigationMenuState extends State<Admin2SideNavigationMenu> {
  final List<IconData> _icons = [
    Icons.person_outline,
    Icons.groups_outlined,
    Icons.add_circle_outline,
    Icons.add_circle_outline,
  ];

  final List<String> _texts = [
    'Список студентов',
    'Список групп',
    'Добавить студента',
    'Добавить группу',
  ];

  bool _isExpanded = false;
  bool isHovered = false;
  final double _collapsedWidth = 100;
  final double _expandedWidth = 250;

  @override
  Widget build(BuildContext context) {
    final List<VoidCallback> functions = [
      widget.onStudentsListTap,
      widget.onGroupsListTap,
          () {
        showDialog(
          context: context,
          builder: (context) => AddStudentDialog(
            onStudentAdded: widget.onStudentAdded, onSave: (String studentName, String? group,) {  }, groups:widget.groups,
          ),
        );
      },
          () {
        showDialog(
          context: context,
          builder: (context) => AddGroupDialog(
            onGroupAdded: widget.onGroupAdded, onSave: (String groupName, String? course) {  },
          ),
        );
      },
    ];

    return GestureDetector(
      onTap: () {
        if (_isExpanded) {
          setState(() {
            _isExpanded = false;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        color: Colors.grey.shade300,
        duration: const Duration(milliseconds: 300),
        width: _isExpanded ? _expandedWidth : _collapsedWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isExpanded
                  ? const Text(
                'МИТСО\nМеждународный\nУниверситет',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
                  : const SizedBox(height: 24, width: 24),
            ),
            Expanded(
              child: Column(
                children: [
                  if (!_isExpanded)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                        child: MyIconContainer(
                          icon: Icons.menu,
                          width: (_isExpanded ? 250 : 50),
                        ),
                      ),
                    ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: _isExpanded
                        ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Панель навигации',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                        : const Divider(height: 1),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _icons.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                            child: InkWell(
                              onTap: functions[index],
                              child: MyIconContainer(
                                icon: _icons[index],
                                width: (_isExpanded ? 250 : 50),
                                text: _texts[index],
                                withText: _isExpanded,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: InkWell(
                  onHover: (hovering) {
                    setState(() {
                      isHovered = hovering;
                    });
                  },
                  onTap: () {
                    context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
                    log('➡️ Состояние: ${context.read<AuthenticationBloc>().state}');
                  },
                  child: MyIconContainer(
                    borderRadius: 100,
                    icon: Icons.arrow_back,
                    width: (_isExpanded ? 250 : 50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}