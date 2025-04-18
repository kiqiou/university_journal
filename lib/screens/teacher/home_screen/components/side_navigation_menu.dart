import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/user_info_getter/user_info_getter.dart';
import 'package:university_journal/components/icon_container.dart';
import 'package:university_journal/screens/teacher/auth/bloc/sign_in/sign_in_bloc.dart';
import 'package:university_journal/screens/teacher/auth/view/welcome_screen.dart';


class TeacherSideNavigationMenu extends StatefulWidget {
  const TeacherSideNavigationMenu({super.key});

  @override
  State<TeacherSideNavigationMenu> createState() =>
      _TeacherSideNavigationMenuState();
}

class _TeacherSideNavigationMenuState extends State<TeacherSideNavigationMenu> {
  final List<IconData> _icons = [
    Icons.book,
    Icons.library_books,
    Icons.folder_shared,
    Icons.computer,
    Icons.create,
    Icons.menu_book,
    Icons.my_library_books,
  ];

  final List<String> _texts = [
    'Журнал',
    'Лекции',
    'Практика',
    'Семинары',
    'Лабораторные',
    'Аттестация',
    'Темы',
  ];

  bool _isExpanded = false;
  bool isHovered = false;
  final double _collapsedWidth = 100;
  final double _expandedWidth = 250;

  @override
  Widget build(BuildContext context) {
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
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
                  : SizedBox(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 4.0),
                        child: IconContainer(
                          icon: Icons.menu,
                          width: (_isExpanded ? 250 : 50),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: _isExpanded
                        ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Профиль',
                        style:
                        TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                        : Divider(
                      height: 1,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomeScreen(),
                        ),
                      );
                    },
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: fetchUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return IconContainer(
                            icon: Icons.account_circle_outlined,
                            width: (_isExpanded ? 250 : 50),
                            withText: _isExpanded ? true : false,
                            text: 'Загрузка...',
                          );
                        } else if (snapshot.hasError) {
                          return IconContainer(
                            icon: Icons.account_circle_outlined,
                            width: (_isExpanded ? 250 : 50),
                            withText: _isExpanded ? true : false,
                            text: 'Ошибка',
                          );
                        } else if (snapshot.hasData) {
                          var userData = snapshot.data!;
                          return IconContainer(
                            icon: Icons.account_circle_outlined,
                            width: (_isExpanded ? 250 : 50),
                            withText: _isExpanded ? true : false,
                            text: userData['username'] ?? 'Гость',
                          );
                        } else {
                          return IconContainer(
                            icon: Icons.account_circle_outlined,
                            width: (_isExpanded ? 250 : 50),
                            withText: _isExpanded ? true : false,
                            text: 'Нет данных',
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: _isExpanded
                        ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Панель навигации',
                        style:
                        TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                        : Divider(
                      height: 1,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _icons.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 4.0),
                            child: InkWell(
                              onTap: () {},
                              child: IconContainer(
                                icon: _icons[index],
                                width: (_isExpanded ? 250 : 50),
                                text: _texts[index],
                                withText: _isExpanded ? true : false,
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
                    horizontal: 4.0, vertical: 4.0),
                child: InkWell(
                  onHover: (hovering) {
                    setState(() {
                      isHovered = true;
                    });
                  },
                  onTap: () {
                    context.read<SignInBloc>().add(SignOutRequired());
                  },
                  child: IconContainer(
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