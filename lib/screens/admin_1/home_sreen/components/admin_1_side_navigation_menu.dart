import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/components/icon_container.dart';

import 'add_teacher.dart';

class Admin1SideNavigationMenu extends StatefulWidget {
  final Future<void> Function() onTeacherAdded;
  const Admin1SideNavigationMenu({super.key, required this.onTeacherAdded});

  @override
  State<Admin1SideNavigationMenu> createState() => _Admin1SideNavigationMenuState();
}

class _Admin1SideNavigationMenuState extends State<Admin1SideNavigationMenu> {
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

  bool _isExpanded = false;
  bool isHovered = false;
  final double _collapsedWidth = 100;
  final double _expandedWidth = 250;

  @override
  Widget build(BuildContext context) {
    // ВАЖНО: функции должны быть внутри build, чтобы был доступ к context
    final List<VoidCallback> _functions = [
          () => print('бля бя'),
          () => print('функция 2'),
          () {
        showDialog(
          context: context,
          builder: (context) => AddTeacherDialog(onTeacherAdded: widget.onTeacherAdded),
        );
      },
          () => print('функция 4'),
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
                  : const SizedBox(
                height: 24,
                width: 24,
              ),
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
                              onTap: _functions[index],
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