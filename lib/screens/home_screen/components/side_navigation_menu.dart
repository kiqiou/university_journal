import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/components/icon_container.dart';
import 'package:university_journal/screens/auth/bloc/sign_in/sign_in_bloc.dart';
import 'package:university_journal/screens/auth/view/welcome_screen.dart';

class SideNavigationMenu extends StatefulWidget {
  SideNavigationMenu({super.key});

  @override
  State<SideNavigationMenu> createState() => _SideNavigationMenu();
}

class _SideNavigationMenu extends State<SideNavigationMenu> {
  final List<IconData> _icons = [
    Icons.book,
    Icons.library_books,
    Icons.folder_shared,
    Icons.computer,
    Icons.create,
    Icons.menu_book,
    Icons.my_library_books,
  ];

  bool _isExpanded = false;
  bool isHovered = false;
  double _collapsedWidth = 100;
  double _expandedWidth = 250;

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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: IconContainer(
                    icon: Icons.menu,
                    width: _isExpanded ? 300 : 50,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Divider(
                  color: Colors.grey.shade400,
                ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: IconContainer(
                    icon: Icons.account_circle_outlined,
                    width: _isExpanded ? 300 : 50,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Divider(
                  color: Colors.grey.shade400,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _icons.length,
                itemBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: InkWell(
                          onTap: () {},
                          child: IconContainer(
                            icon: _icons[index],
                            width: _isExpanded ? 300 : 50,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
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
                width: _isExpanded ? 300 : 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
