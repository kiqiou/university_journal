import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/components/widgets/icon_container.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/models/user.dart';
import 'add_student.dart';
import 'add_group.dart';

class Admin2SideNavigationMenu extends StatefulWidget {
  final Future<void> Function() onStudentAdded;
  final Future<void> Function() onGroupAdded;
  final VoidCallback onToggle;
  final List<Group> groups;
  final List<MyUser> students;
  final bool isExpanded;

  const Admin2SideNavigationMenu({
    super.key,
    required this.onStudentAdded,
    required this.onGroupAdded,
    required this.groups,
    required this.students,
    required this.onToggle,
    required this.isExpanded,
  });

  @override
  State<Admin2SideNavigationMenu> createState() =>
      _Admin2SideNavigationMenuState();
}

class _Admin2SideNavigationMenuState extends State<Admin2SideNavigationMenu> {
  final double _collapsedWidth = 100;
  final double _expandedWidth = 300;
  bool isHovered = false;
  int? selectedIndex;

  final List<IconData> _icons = [
    Icons.groups_outlined,
    Icons.add_circle_outline,
    Icons.add_circle_outline,
  ];

  final List<String> _texts = [
    'Список групп и студентов',
    'Добавить студента',
    'Добавить группу',
  ];

  @override
  Widget build(BuildContext context) {
    final List<VoidCallback> functions = [
      () {},
      () {
        showDialog(
          context: context,
          builder: (context) => AddStudentDialog(
            onStudentAdded: widget.onStudentAdded,
            onSave: (
              String studentName,
              String? group,
            ) {},
            groups: widget.groups,
          ),
        );
      },
      () {
        showDialog(
          context: context,
          builder: (context) => AddGroupDialog(
            onGroupAdded: widget.onGroupAdded,
            students: widget.students,
          ),
        );
      },
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: widget.isExpanded ? _collapsedWidth : _expandedWidth,
          end: widget.isExpanded ? _expandedWidth : _collapsedWidth,
        ),
        duration: const Duration(milliseconds: 300),
        builder: (context, width, child) {
          return Container(
            width: width,
            color: Colors.grey.shade300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: widget.isExpanded
                      ? const Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Text(
                                  'МИТСО',
                                  style: TextStyle(
                                    fontSize: 40,
                                  ),
                                ),
                              ),
                              Text(
                                'Международный\nуниверситет',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (!widget.isExpanded)
                        InkWell(
                          onTap: () {
                            widget.onToggle();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 4.0),
                            child: MyIconContainer(
                              icon: Icons.menu,
                              width: (widget.isExpanded ? 250 : 50),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: widget.isExpanded
                            ? const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Панель навигации',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : const Divider(
                                height: 1,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _icons.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 4.0),
                                child: InkWell(
                                  onTap: () {
                                    functions[index]();
                                    if (index < 2) {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    }
                                  },
                                  child: MyIconContainer(
                                    icon: _icons[index],
                                    width: (widget.isExpanded ? 250 : 50),
                                    text: _texts[index],
                                    withText: widget.isExpanded,
                                    isSelected: selectedIndex == index,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 50.0),
                    child: InkWell(
                      onHover: (hovering) {
                        setState(() {
                          isHovered = hovering;
                        });
                      },
                      onTap: () {
                        context
                            .read<AuthenticationBloc>()
                            .add(AuthenticationLogoutRequested());
                        log('➡️ Состояние: ${context.read<AuthenticationBloc>().state}');
                      },
                      child: MyIconContainer(
                        borderRadius: 100,
                        icon: Icons.arrow_back,
                        width: (widget.isExpanded ? 250 : 50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
