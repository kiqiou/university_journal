import 'package:flutter/material.dart';
import 'package:university_journal/components/icon_container.dart';
import 'package:university_journal/screens/auth/view/welcome_screen.dart';
import 'package:university_journal/screens/home_screen/components/side_navigation_menu.dart';
import 'package:university_journal/screens/home_screen/components/table.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigationMenu(),
          SizedBox(
            width: 30,
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                    child: Text(
                      'Добавить занятие',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DataTableScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
