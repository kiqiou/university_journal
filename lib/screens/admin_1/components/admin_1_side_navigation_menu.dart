import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/components/widgets/icon_container.dart';

import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/models/user.dart';
import 'add_discipline.dart';
import 'add_teacher.dart';

class Admin1SideNavigationMenu extends StatefulWidget {
  final Future<void> Function() onTeacherAdded;
  final Future<void> Function() onCourseAdded;
  final VoidCallback onToggle;
  final VoidCallback onTeacherListTap;
  final VoidCallback onCoursesListTap;
  final List<GroupSimple> groups;
  final List<MyUser> teachers;
  final bool isExpanded;

  const Admin1SideNavigationMenu({
    super.key,
    required this.onTeacherAdded,
    required this.onTeacherListTap,
    required this.onCoursesListTap,
    required this.groups,
    required this.teachers,
    required this.onCourseAdded,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<Admin1SideNavigationMenu> createState() =>
      _Admin1SideNavigationMenuState();
}

class _Admin1SideNavigationMenuState extends State<Admin1SideNavigationMenu> {
  final double _collapsedWidth = 100;
  final double _expandedWidth = 300;
  bool isHovered = false;
  int? selectedIndex;

  final List<IconData> _icons = [
    Icons.groups_outlined,
    Icons.library_books,
    Icons.add_circle_outline,
    Icons.add_circle_outline,
  ];

  final List<String> _texts = [
    'Список преподавателей',
    'Список дисциплин',
    'Добавить преподавателя',
    'Добавить дисциплину',
  ];

  @override
  Widget build(BuildContext context) {
    final List<VoidCallback> functions = [
      widget.onTeacherListTap,
      widget.onCoursesListTap,
      () {
        showDialog(
          context: context,
          builder: (context) =>
              AddTeacherDialog(onTeacherAdded: widget.onTeacherAdded),
        );
      },
      () {
        showDialog(
          context: context,
          builder: (context) => AddDisciplineDialog(
            onCourseAdded: () => widget.onCourseAdded(),
            teachers: widget.teachers.toList(),
            groups: widget.groups.toList(),
          ),
        );
      }
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          TweenAnimationBuilder<double>(
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
                          ? Column(
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
        ],
      ),
    );
  }
}
