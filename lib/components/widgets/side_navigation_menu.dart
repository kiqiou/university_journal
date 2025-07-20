import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/components/widgets/icon_container.dart';

import '../../shared/journal/widgets/journal_table.dart';

class SideNavigationMenu extends StatefulWidget {
  final Function(String type) onSelectType;
  final VoidCallback onProfileTap;
  final VoidCallback onThemeTap;
  final VoidCallback onToggle;
  final VoidCallback onGroupSelect;
  final bool isExpanded;
  final bool showGroupSelect;

  const SideNavigationMenu({
    super.key,
    required this.onSelectType,
    required this.onProfileTap,
    required this.onThemeTap,
    required this.onToggle,
    required this.isExpanded,
    required this.showGroupSelect,
    required this.onGroupSelect,
  });

  @override
  State<SideNavigationMenu> createState() => _SideNavigationMenuState();
}

class _SideNavigationMenuState extends State<SideNavigationMenu> {
  final GlobalKey<JournalTableState> tableKey = GlobalKey<JournalTableState>();
  final double _collapsedWidth = 100;
  final double _expandedWidth = 250;
  bool isHovered = false;
  int? selectedIndex = 0;

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

  final List<String> _filterText = [
    'Все',
    'Лекция',
    'Практика',
    'Семинар',
    'Лабораторная',
    'Аттестация',
    'Текущая Аттестация',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
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
                                      padding: EdgeInsets.only(left: 17.0),
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
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: widget.isExpanded
                                    ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Профиль',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                    : Divider(
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  widget.onProfileTap();
                                  setState(() {
                                    selectedIndex = -2;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: BlocBuilder<AuthenticationBloc,
                                      AuthenticationState>(
                                    builder: (context, state) {
                                      if (state.status ==
                                              AuthenticationStatus
                                                  .authenticated &&
                                          state.user != null) {
                                        return MyIconContainer(
                                          icon: Icons.account_circle_outlined,
                                          width: (widget.isExpanded ? 250 : 50),
                                          withText: widget.isExpanded,
                                          text: state.user!.username,
                                          isSelected: selectedIndex == -2,
                                        );
                                      } else if (state.status ==
                                          AuthenticationStatus
                                              .unauthenticated) {
                                        return MyIconContainer(
                                          icon: Icons.account_circle_outlined,
                                          width: (widget.isExpanded ? 250 : 50),
                                          withText: widget.isExpanded,
                                          text: 'Гость',
                                        );
                                      } else {
                                        return MyIconContainer(
                                          icon: Icons.account_circle_outlined,
                                          width: (widget.isExpanded ? 250 : 50),
                                          withText: widget.isExpanded,
                                          text: 'Загрузка...',
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: widget.isExpanded
                                    ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: state.user?.role == 'Студент'
                                            ? Text(
                                                'Выбор дисциплины',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                              )
                                            : Text(
                                                'Выбор группы',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                              ),
                                      )
                                    : Divider(
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  widget.onGroupSelect();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 4.0),
                                  child: MyIconContainer(
                                    icon: Icons.groups_outlined,
                                    width: (widget.isExpanded ? 250 : 50),
                                    text: state.user?.role == 'Студент'
                                        ? 'Выбор дисциплины'
                                        : 'Выбор группы',
                                    withText: widget.isExpanded,
                                    isSelected: selectedIndex == -1,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: widget.isExpanded
                                    ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Панель навигации',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 13),
                                        ),
                                      )
                                    : Divider(
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _icons.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 4.0),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedIndex = index;
                                            });
                                            if (index == _icons.length - 1) {
                                              widget.onThemeTap();
                                            } else {
                                              final type = _filterText[index];
                                              widget.onSelectType(type);
                                            }
                                          },
                                          child: MyIconContainer(
                                            icon: _icons[index],
                                            width:
                                                (widget.isExpanded ? 250 : 50),
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
      },
    );
  }
}
