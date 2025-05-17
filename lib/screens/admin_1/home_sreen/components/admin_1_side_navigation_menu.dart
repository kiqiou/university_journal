import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/components/icon_container.dart';
import 'package:university_journal/screens/auth/view/sign_up_screen.dart';

class Admin1SideNavigationMenu extends StatefulWidget {
  const Admin1SideNavigationMenu({super.key});

  @override
  State<Admin1SideNavigationMenu> createState() => _Admin1SideNavigationMenu();
}

class _Admin1SideNavigationMenu extends State<Admin1SideNavigationMenu> {
  final List<IconData> _icons = [
    Icons.groups_outlined,
    Icons.library_books,
    Icons.add_circle_outline,
    Icons.add_circle_outline,
  ];

  final List<String> _texts = [
    'Журнал',
    'Лекции',
    'Практика',
    'Семинары',
  ];

  bool _isExpanded = false;
  bool isHovered = false;
  final double _collapsedWidth = 100;
  final double _expandedWidth = 250;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      color: Colors.grey.shade300,
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? _expandedWidth : _collapsedWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
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
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _isExpanded
                    ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Профиль',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : Divider(
                  height: 1,
                ),
              ),
              SizedBox(
                height: 10,
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
                child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    if (state.status == AuthenticationStatus.authenticated && state.user != null) {
                      return MyIconContainer(
                        icon: Icons.account_circle_outlined,
                        width: (_isExpanded ? 250 : 50),
                        withText: _isExpanded,
                        text: state.user!.username,
                      );
                    } else if (state.status == AuthenticationStatus.unauthenticated) {
                      return MyIconContainer(
                        icon: Icons.account_circle_outlined,
                        width: (_isExpanded ? 250 : 50),
                        withText: _isExpanded,
                        text: 'Гость',
                      );
                    } else {
                      return MyIconContainer(
                        icon: Icons.account_circle_outlined,
                        width: (_isExpanded ? 250 : 50),
                        withText: _isExpanded,
                        text: 'Загрузка...',
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
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : Divider(
                  height: 1,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _icons.length,
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                      child: InkWell(
                        onTap: () {},
                        child: MyIconContainer(
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: InkWell(
              onHover: (hovering) {
                setState(() {
                  isHovered = true;
                });
              },
              onTap: () {

              },
              child: MyIconContainer(
                borderRadius: 100,
                icon: Icons.arrow_back,
                width: (_isExpanded ? 250 : 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}